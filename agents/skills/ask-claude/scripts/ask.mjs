import { spawn } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { linkSync, renameSync, rmSync, writeFileSync } from 'node:fs';
import { basename, dirname, join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

const levels = ['high', 'medium', 'low'];
const schema = {
  type: 'object',
  properties: {
    status: { type: 'string', enum: ['answered', 'unable_to_answer'] },
    summary: { type: 'string' },
    answer: { type: 'string' },
    confidence: { type: 'string', enum: levels },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          severity: { type: 'string', enum: levels },
          file: { type: 'string' },
          line: { type: 'string' },
          issue: { type: 'string' },
          why: { type: 'string' },
          fix: { type: 'string' },
        },
        required: ['severity', 'issue', 'why'],
      },
    },
    open_questions: { type: 'array', items: { type: 'string' } },
  },
  required: ['status', 'summary', 'answer', 'findings'],
};

const systemPrompt = 'You are answering a question from another coding agent. You have only this packet and no tools. Do not request tool use. Base every claim on the packet. Do not propose edits unless the packet asks for them. If the packet is insufficient to answer, set status to unable_to_answer and say what is missing in summary.';
const signalExitCodes = { SIGINT: 130, SIGTERM: 143, SIGHUP: 129 };
const terminalStates = { max_duration_exceeded: 'timed_out', cancelled: 'cancelled' };
const blockPhases = new Map([
  ['thinking', 'thinking'], ['redacted_thinking', 'thinking'],
  ['text', 'answering'], ['tool_use', 'answering'],
]);

export function parseArgs(argv) {
  const options = { model: 'claude-opus-5', effort: 'max', timeoutSeconds: 1800 };
  const keys = { '--model': 'model', '--effort': 'effort', '--timeout': 'timeoutSeconds', '--status-file': 'statusFile' };
  for (let index = 0; index < argv.length; index += 1) {
    const flag = argv[index];
    if (flag === '--help' || flag === '-h') return { help: true };
    if (!Object.hasOwn(keys, flag)) throw new Error(`unknown argument: ${flag}`);
    const value = argv[++index];
    if (!value || value.startsWith('--')) throw new Error(`${flag} needs a value`);
    options[keys[flag]] = value;
  }
  if (!/^[1-9]\d*$/.test(String(options.timeoutSeconds)) ||
      !Number.isSafeInteger(Number(options.timeoutSeconds) * 1000)) {
    throw new Error('--timeout must be a positive integer number of seconds');
  }
  options.timeoutSeconds = Number(options.timeoutSeconds);
  return options;
}

function matchesSchema(value, definition) {
  if (definition.enum && !definition.enum.includes(value)) return false;
  if (definition.type === 'string') return typeof value === 'string';
  if (definition.type === 'array') {
    return Array.isArray(value) && value.every(item => matchesSchema(item, definition.items));
  }
  if (!value || typeof value !== 'object' || Array.isArray(value)) return false;
  return definition.required.every(key => Object.hasOwn(value, key)) &&
    Object.entries(definition.properties).every(([key, child]) =>
      !Object.hasOwn(value, key) || matchesSchema(value[key], child));
}

function failureReason(exitCode, result) {
  if (exitCode !== 0) return 'process_failed';
  const output = result?.structured_output;
  if (result?.is_error !== false || result.subtype !== 'success' || !matchesSchema(output, schema)) {
    return 'response_invalid';
  }
  if (output.status === 'unable_to_answer') return 'unable_to_answer';
  return output.answer.trim() ? null : 'response_invalid';
}

function classifyEvent(message) {
  if (message.type === 'result') return { phase: 'completing', result: message };
  if (message.type === 'system' && message.subtype === 'init') return { phase: 'waiting' };
  if (message.type === 'system' && message.subtype === 'api_retry') {
    return {
      phase: 'retrying',
      retry: {
        attempt: Number.isInteger(message.attempt) ? message.attempt : null,
        max_retries: Number.isInteger(message.max_retries) ? message.max_retries : null,
        retry_delay_ms: Number.isFinite(message.retry_delay_ms) && message.retry_delay_ms >= 0 ? message.retry_delay_ms : 0,
        error: typeof message.error === 'string' && /^[a-z_]+$/.test(message.error) ? message.error : 'unknown',
      },
    };
  }
  if (message.type === 'assistant' && Array.isArray(message.message?.content)) {
    return { progress: message.message.content.length > 0 };
  }
  const event = message.type === 'stream_event' ? message.event : null;
  if (event?.type === 'content_block_start') {
    return { progress: true, phase: blockPhases.get(event.content_block?.type) };
  }
  if (event?.type === 'content_block_stop') return { progress: true };
  const delta = event?.type === 'content_block_delta' ? event.delta : null;
  if (delta?.type === 'thinking_delta' && delta.thinking?.length) {
    return { progress: true, phase: 'thinking' };
  }
  if ((delta?.type === 'text_delta' && delta.text?.length) ||
      (delta?.type === 'input_json_delta' && delta.partial_json?.length)) {
    return { progress: true, phase: 'answering' };
  }
  return {};
}

function writeStatus(path, status, initial) {
  const temporary = join(dirname(path), `.${basename(path)}.${randomUUID()}.tmp`);
  try {
    writeFileSync(temporary, `${JSON.stringify(status)}\n`, { mode: 0o600, flag: 'wx' });
    // A fresh run must not replace another run's status or follow a symlink.
    if (initial) linkSync(temporary, path);
    else renameSync(temporary, path);
  } finally {
    rmSync(temporary, { force: true });
  }
}

export async function run(options, timingOverrides = {}) {
  const timings = {
    warnAfterMs: 600_000, idleWarnMs: 600_000, heartbeatMs: 30_000,
    tickMs: 1000, signalGraceMs: 5000, drainGraceMs: 5000, statusIntervalMs: 1000,
    ...timingOverrides,
  };
  const start = performance.now();
  const age = (time, now) => time === null ? null : Math.max(0, Math.round(now - time) / 1000);
  let state = 'running';
  let phase = 'starting';
  let reason = null;
  let lastEvent = null;
  let lastProgress = null;
  let progressEvents = 0;
  let retry = null;
  let retryUntil = 0;
  let elapsedWarned = false;
  let idleWarned = false;
  let lastNotice = start;
  let lastStatus = start;
  let statusPath = options.statusFile ? resolve(options.statusFile) : null;
  let stderrAvailable = true;

  function diagnostic(text) {
    if (stderrAvailable) process.stderr.write(text);
  }

  function snapshot(now = performance.now()) {
    return {
      state, last_observed_phase: phase, elapsed_seconds: age(start, now),
      seconds_since_last_event: age(lastEvent, now),
      seconds_since_last_progress: age(lastProgress, now),
      progress_events: progressEvents,
      retry: retry ? { ...retry, seconds_until_retry: Math.max(0, Math.ceil((retryUntil - now) / 1000)) } : null,
      reason,
    };
  }
  function notice(message) {
    const now = performance.now();
    const status = snapshot(now);
    const idle = status.seconds_since_last_progress ?? status.elapsed_seconds;
    const retryNote = retry ? ` retry_in=${status.retry.seconds_until_retry}s attempt=${retry.attempt}` : '';
    diagnostic(`[ask-claude] ${message} elapsed=${status.elapsed_seconds}s last_phase=${phase} progress_age=${idle}s${retryNote}\n`);
    lastNotice = now;
  }
  function saveStatus(initial = false) {
    lastStatus = performance.now();
    try {
      if (statusPath) writeStatus(statusPath, snapshot(), initial);
      return true;
    } catch {
      statusPath = null;
      return false;
    }
  }
  if (!saveStatus(true)) {
    process.stderr.write('NOT RETRIEVED: status_file_error (use a new file in an existing writable directory)\n');
    return 1;
  }

  const args = [
    '-p', '--output-format', 'stream-json', '--verbose', '--include-partial-messages',
    '--json-schema', JSON.stringify(schema), '--safe-mode', '--tools', '',
    '--no-session-persistence', '--system-prompt', systemPrompt,
    '--model', options.model, '--effort', options.effort,
  ];
  let child;
  try { child = spawn('claude', args, { detached: true, stdio: ['pipe', 'pipe', 'pipe'] }); }
  catch {
    state = 'failed';
    reason = 'process_failed';
    saveStatus();
    diagnostic('NOT RETRIEVED: process_failed\n');
    return 1;
  }
  let result = null;
  let buffer = '';
  let diagnosticTail = '';
  let exitCode = null;
  let closed = false;
  let stopping = false;
  let stopSignal = null;
  let tick;
  let childClosed = false;
  const timers = [];

  return await new Promise(resolveRun => {
    function later(delay, action) { timers.push(setTimeout(action, delay)); }
    function closeInput() {
      process.stdin.pause();
      if (child.stdin) {
        process.stdin.unpipe(child.stdin);
        child.stdin.destroy();
      }
    }
    function signalGroup(signal) {
      if (!child.pid) return;
      try { process.kill(-child.pid, signal); }
      catch (error) { if (error.code !== 'ESRCH') notice(`could not send ${signal}`); }
    }
    function groupExists() {
      if (!child.pid) return false;
      try { process.kill(-child.pid, 0); return true; }
      catch (error) { return error.code !== 'ESRCH'; }
    }
    function settle() {
      function release() {
        // Stream write callbacks can precede their corresponding error event.
        setImmediate(() => {
          process.stdout.off('error', outputError);
          process.stderr.off('error', diagnosticError);
          resolveRun(signalExitCodes[stopSignal] ?? (reason ? 1 : 0));
        });
      }
      if (stderrAvailable) process.stderr.write('', release);
      else release();
    }
    function finish() {
      if (closed) return;
      closed = true;
      clearInterval(tick);
      timers.forEach(clearTimeout);
      for (const [signal, handler] of Object.entries(handlers)) process.off(signal, handler);
      closeInput();
      process.stdin.off('error', inputError);
      child.stdout?.destroy();
      child.stderr?.destroy();

      reason ??= failureReason(exitCode, result);
      state = reason ? terminalStates[reason] ?? 'failed' : 'succeeded';
      if (!saveStatus()) { reason = 'status_file_error'; state = 'failed'; }
      if (reason) {
        diagnostic(`NOT RETRIEVED: ${reason}\n`);
        if (diagnosticTail.trim()) diagnostic(`${diagnosticTail.trim().split('\n').slice(-3).join('\n')}\n`);
        settle();
        return;
      }
      if (Array.isArray(result.permission_denials) && result.permission_denials.length) {
        notice(`warning: ${result.permission_denials.length} blocked tool call(s)`);
      }
      process.stdout.write(`${JSON.stringify(result.structured_output, null, 2)}\n`, error => {
        if (error) {
          reason = 'output_failed';
          state = 'failed';
          saveStatus();
          diagnostic('NOT RETRIEVED: output_failed\n');
        } else notice('completed');
        settle();
      });
    }
    function fail(cause, signal = null) {
      if (closed || reason) return;
      reason = cause;
      stopSignal = signal;
      if (stopping) {
        notice(`stopping: ${cause}`);
        saveStatus();
      } else terminate();
    }
    function escalate(signal) {
      if (childClosed && !groupExists()) { finish(); return; }
      signalGroup(signal);
    }
    function terminate() {
      if (closed || stopping) return;
      stopping = true;
      state = 'stopping';
      closeInput();
      notice(reason ? `stopping: ${reason}` : 'cleaning up remaining processes');
      if (!saveStatus()) reason ??= 'status_file_error';
      signalGroup('SIGINT');
      later(timings.signalGraceMs, () => escalate('SIGTERM'));
      later(timings.signalGraceMs * 2, () => {
        escalate('SIGKILL');
        // A descendant may keep a pipe open after the direct child exits.
        if (!closed) later(timings.drainGraceMs, finish);
      });
    }
    const handlers = Object.fromEntries(Object.keys(signalExitCodes).map(signal =>
      [signal, () => fail('cancelled', signal)]));
    for (const [signal, handler] of Object.entries(handlers)) process.on(signal, handler);
    function outputError() { fail('output_failed'); }
    function diagnosticError() {
      stderrAvailable = false;
      if (!closed) fail('output_failed');
      else if (!reason) {
        reason = 'output_failed';
        state = 'failed';
        saveStatus();
      }
    }
    process.stdout.on('error', outputError);
    process.stderr.on('error', diagnosticError);
    function inputError() { fail('input_failed'); }
    process.stdin.on('error', inputError);
    child.on('error', error => {
      if (closed) return;
      reason = error.code === 'ENOENT' ? 'cli_missing' : 'process_failed';
      finish();
    });
    // Resource exhaustion can return a ChildProcess without any stdio streams.
    if (!child.stdin || !child.stdout || !child.stderr) {
      reason = 'process_failed';
      finish();
      return;
    }
    child.stdin.on('error', error => {
      if (error.code !== 'EPIPE') fail('input_failed');
    });

    function observe(message) {
      if (!message || typeof message !== 'object' || Array.isArray(message)) {
        fail('response_invalid');
        return;
      }
      const now = performance.now();
      lastEvent = now;
      const observed = classifyEvent(message);
      if (observed.result) {
        if (result) { fail('response_invalid'); return; }
        result = observed.result;
      }
      if (observed.retry) {
        retry = observed.retry;
        retryUntil = now + retry.retry_delay_ms;
      }
      if (observed.progress) {
        lastProgress = now;
        progressEvents += 1;
        idleWarned = false;
        retryUntil = 0;
      }
      if (observed.phase && observed.phase !== phase) {
        phase = observed.phase;
        notice('phase observed');
      }
    }
    function consume(line) {
      if (!line.trim() || reason || closed) return;
      let message;
      try { message = JSON.parse(line); }
      catch { fail('response_invalid'); return; }
      observe(message);
    }
    child.stdout.setEncoding('utf8');
    child.stdout.on('data', chunk => {
      if (reason || closed) return;
      const lines = (buffer + chunk).split('\n');
      buffer = lines.pop();
      lines.forEach(consume);
      if (buffer.length > 16 * 1024 * 1024) fail('response_invalid');
    });
    child.stdout.on('end', () => { consume(buffer); buffer = ''; });
    child.stdout.on('error', () => fail('process_failed'));
    child.stderr.setEncoding('utf8');
    child.stderr.on('data', chunk => { diagnosticTail = (diagnosticTail + chunk).slice(-8192); });
    child.stderr.on('error', () => fail('process_failed'));
    child.on('exit', code => {
      exitCode = code;
      if (!stopping) later(timings.drainGraceMs, terminate);
    });
    child.on('close', () => {
      childClosed = true;
      if (!groupExists()) finish();
      else terminate();
    });
    tick = setInterval(() => {
      const now = performance.now();
      if (stopping) {
        if (now - lastNotice >= timings.heartbeatMs) notice('stopping');
        return;
      }
      if (now - start >= options.timeoutSeconds * 1000) {
        fail('max_duration_exceeded');
        return;
      }
      if (!elapsedWarned && now - start >= timings.warnAfterMs) {
        elapsedWarned = true;
        notice('warning: elapsed threshold reached; continuing');
      }
      if (!idleWarned && now - (lastProgress ?? start) >= timings.idleWarnMs && now >= retryUntil) {
        idleWarned = true;
        notice('warning: no recent progress observed; continuing');
      }
      if (now - lastNotice >= timings.heartbeatMs) notice('waiting');
      if (now - lastStatus >= timings.statusIntervalMs && !saveStatus()) fail('status_file_error');
    }, timings.tickMs);
    notice('started');
    process.stdin.pipe(child.stdin);
  });
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  let options;
  try { options = parseArgs(process.argv.slice(2)); }
  catch (error) { process.stderr.write(`${error.message}\n`); process.exitCode = 2; }
  if (options?.help) {
    process.stdout.write('Usage: ask.sh [--model MODEL] [--effort LEVEL] [--timeout SECONDS] [--status-file PATH] < packet.txt\nDefault timeout: 1800 seconds. Status file must not already exist.\n');
  } else if (options) {
    process.exitCode = await run(options);
  }
}
