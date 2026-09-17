import assert from 'node:assert/strict';
import { spawn, spawnSync } from 'node:child_process';
import { once } from 'node:events';
import { chmod, copyFile, mkdtemp, readFile, rm, stat, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { parseArgs } from '../scripts/ask.mjs';

const runnerUrl = new URL('../scripts/ask.mjs', import.meta.url);
const fixtureUrl = new URL('./fake-claude.mjs', import.meta.url);
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const timings = {
  warnAfterMs: 80, idleWarnMs: 80, heartbeatMs: 40, tickMs: 10,
  signalGraceMs: 50, drainGraceMs: 80, statusIntervalMs: 10,
};

async function launch(t, scenario, options = {}) {
  const directory = await mkdtemp(join(tmpdir(), 'ask-claude-test-'));
  const statusFile = join(directory, options.statusFile ?? 'status.json');
  if (options.existingStatus) await writeFile(statusFile, options.existingStatus);
  const pidsFile = join(directory, 'pids.json');
  const captureFile = join(directory, 'capture.json');
  const executable = join(directory, 'claude');
  const driver = join(directory, 'driver.mjs');
  if (!options.noClaude) {
    await copyFile(fixtureUrl, executable);
    await chmod(executable, 0o700);
  }
  const spawnFailure = options.spawnFailure ? `
    import childProcess from 'node:child_process';
    import { EventEmitter } from 'node:events';
    import { syncBuiltinESMExports } from 'node:module';
    childProcess.spawn = () => {
      const error = Object.assign(new Error('spawn failed'), { code: 'EMFILE' });
      if (${JSON.stringify(options.spawnFailure)} === 'throw') throw error;
      const child = new EventEmitter();
      child.stdin = child.stdout = child.stderr = null;
      process.nextTick(() => child.emit('error', error));
      return child;
    };
    syncBuiltinESMExports();
  ` : '';
  await writeFile(driver, `${spawnFailure}
    import {parseArgs,run} from ${JSON.stringify(runnerUrl.href)};
    process.exitCode = await run(parseArgs(process.argv.slice(2)), JSON.parse(process.env.ASK_TEST_TIMINGS));\n`);
  const child = spawn(process.execPath, [driver, '--status-file', statusFile, ...(options.args ?? [])], {
    env: {
      ...process.env, PATH: options.noClaude ? directory : `${directory}:${process.env.PATH}`,
      ASK_TEST_SCENARIO: scenario, ASK_TEST_TIMINGS: JSON.stringify({ ...timings, ...options.timings }),
      ASK_TEST_PIDS: pidsFile, ASK_TEST_CAPTURE: captureFile,
    },
    stdio: ['pipe', 'pipe', 'pipe'],
  });
  const completion = once(child, 'close');
  let stdout = '';
  let stderr = '';
  child.stdout.setEncoding('utf8').on('data', (chunk) => { stdout += chunk; });
  child.stderr.setEncoding('utf8').on('data', (chunk) => { stderr += chunk; });
  child.stdin.end('A synthetic test packet.\n');
  const watchdog = setTimeout(() => child.kill('SIGKILL'), 8000);
  t.after(async () => {
    clearTimeout(watchdog);
    child.kill('SIGKILL');
    try {
      for (const pid of JSON.parse(await readFile(pidsFile, 'utf8'))) {
        try { process.kill(pid, 'SIGKILL'); } catch (error) { if (error.code !== 'ESRCH') throw error; }
      }
    } catch (error) { if (error.code !== 'ENOENT') throw error; }
    await rm(directory, { recursive: true, force: true });
  });
  async function exited() {
    const [code, signal] = await completion;
    clearTimeout(watchdog);
    assert.equal(signal, null, `runner was killed by ${signal}: ${stderr}`);
    return { code, stdout, stderr };
  }
  return {
    child, directory, statusFile, pidsFile, captureFile, exited,
    get stderr() { return stderr; },
    async finished() {
      return { ...await exited(), status: JSON.parse(await readFile(statusFile, 'utf8')) };
    },
  };
}

async function waitForJson(path, predicate = () => true) {
  for (let attempt = 0; attempt < 200; attempt += 1) {
    try {
      const value = JSON.parse(await readFile(path, 'utf8'));
      if (predicate(value)) return value;
    } catch (error) { if (error.code !== 'ENOENT') throw error; }
    await sleep(10);
  }
  throw new Error('Timed out waiting for JSON file');
}

function isAlive(pid) {
  try { process.kill(pid, 0); } catch (error) { if (error.code === 'ESRCH') return false; throw error; }
  const status = spawnSync('ps', ['-p', String(pid), '-o', 'stat='], { encoding: 'utf8' });
  return status.status === 0 && !status.stdout.trim().startsWith('Z');
}

async function assertStopped(pids) {
  for (let attempt = 0; attempt < 100; attempt += 1) {
    if (pids.every((pid) => !isAlive(pid))) return;
    await sleep(10);
  }
  assert.fail(`Processes remain alive: ${pids.filter(isAlive).join(', ')}`);
}

test('arguments keep model defaults and require a positive integer timeout', () => {
  const defaults = parseArgs([]);
  assert.equal(defaults.model, 'claude-opus-5');
  assert.equal(defaults.effort, 'max');
  assert.equal(defaults.timeoutSeconds, 1800);
  assert.deepEqual(parseArgs(['--help']), { help: true });
  const overridden = parseArgs(['--model', 'sonnet', '--effort', 'medium', '--timeout', '42', '--status-file', 'state.json']);
  assert.equal(overridden.model, 'sonnet');
  assert.equal(overridden.effort, 'medium');
  assert.equal(overridden.timeoutSeconds, 42);
  assert.equal(overridden.statusFile, 'state.json');
  for (const timeout of ['0', '-1', '1.5', 'NaN', 'Infinity', '1e3', '9007199254740992']) {
    assert.throws(() => parseArgs(['--timeout', timeout]));
  }
  for (const args of [['--timeout'], ['--status-file'], ['--model'], ['--unknown']]) {
    assert.throws(() => parseArgs(args));
  }
});

test('streams progress privately and outputs only the validated final answer', async (t) => {
  const run = await launch(t, 'success');
  const observed = await waitForJson(run.statusFile, (status) => status.last_observed_phase === 'thinking');
  assert.ok(observed.progress_events > 0);
  const { code, stdout, stderr, status } = await run.finished();
  assert.equal(code, 0, stderr);
  assert.equal(JSON.parse(stdout).answer, 'Verified answer.');
  assert.equal(status.state, 'succeeded');
  assert.doesNotMatch(stderr, /PRIVATE_(thinking|text)_CONTENT/);
  assert.doesNotMatch(await readFile(run.statusFile, 'utf8'), /PRIVATE_(thinking|text)_CONTENT/);
  const { args, packet } = JSON.parse(await readFile(run.captureFile, 'utf8'));
  assert.equal(packet, 'A synthetic test packet.\n');
  assert.equal(args[args.indexOf('--output-format') + 1], 'stream-json');
  for (const flag of ['--verbose', '--include-partial-messages', '--safe-mode', '--no-session-persistence']) assert.ok(args.includes(flag), flag);
  assert.equal(args[args.indexOf('--tools') + 1], '');
});

test('silence causes warnings and heartbeat messages but does not discard a later answer', async (t) => {
  const run = await launch(t, 'silent');
  const waiting = await waitForJson(run.statusFile, (status) => status.state === 'running' && status.elapsed_seconds > 0.15);
  assert.equal(waiting.progress_events, 0);
  const { code, stdout, stderr } = await run.finished();
  assert.equal(code, 0, stderr);
  assert.equal(JSON.parse(stdout).status, 'answered');
  assert.match(stderr, /warn|no.*progress|without.*progress/i);
  assert.ok(stderr.trim().split('\n').length >= 3);
});

test('retry waits retain the last progress age and suppress idle warnings', async (t) => {
  const run = await launch(t, 'retry', { timings: { warnAfterMs: 5000, idleWarnMs: 100 } });
  await waitForJson(run.statusFile, (status) => status.retry);
  const beforeRetryWait = run.stderr.length;
  const waiting = await waitForJson(run.statusFile, (status) => status.retry && status.seconds_since_last_progress > 0.15);
  assert.equal(waiting.retry.attempt, 1);
  assert.equal(waiting.retry.max_retries, 3);
  assert.equal(waiting.retry.retry_delay_ms, 5000);
  assert.ok(waiting.retry.seconds_until_retry > 0);
  assert.equal(waiting.progress_events, 1);
  assert.ok(waiting.seconds_since_last_progress > 0.1);
  assert.ok(waiting.seconds_since_last_progress >= waiting.seconds_since_last_event);
  const { code, stderr } = await run.finished();
  assert.equal(code, 0, stderr);
  assert.doesNotMatch(stderr.slice(beforeRetryWait), /warning[^\n]*(?:no.*progress|without.*progress|idle)/i);
});

test('ongoing progress and retries cannot extend the hard deadline', async (t) => {
  const started = performance.now();
  const run = await launch(t, 'active_timeout', { args: ['--timeout', '1'] });
  const { code, stdout, status } = await run.finished();
  assert.equal(code, 1);
  assert.equal(stdout, '');
  assert.equal(status.state, 'timed_out');
  assert.equal(status.reason, 'max_duration_exceeded');
  assert.ok(status.progress_events > 1);
  assert.ok(performance.now() - started < 3500);
});

test('handles split JSON and UTF-8, unknown events, and a final line without newline', async (t) => {
  const run = await launch(t, 'chunks');
  const { code, stdout, stderr } = await run.finished();
  assert.equal(code, 0, stderr);
  assert.equal(JSON.parse(stdout).answer, '答え 🙂 café');
});

for (const scenario of [
  'missing', 'invalid_json', 'duplicate_result', 'not_result', 'missing_summary', 'wrong_findings',
  'invalid_finding', 'invalid_optional', 'invalid_questions', 'invalid_location', 'missing_finding_reason',
  'blank', 'unable', 'result_error', 'result_failure', 'nonzero',
]) {
  test(`rejects ${scenario} without printing a partial answer`, async (t) => {
    const run = await launch(t, scenario);
    const { code, stdout, stderr, status } = await run.finished();
    const reason = { unable: 'unable_to_answer', nonzero: 'process_failed' }[scenario] ?? 'response_invalid';
    assert.equal(code, 1);
    assert.equal(stdout, '');
    assert.equal(status.state, 'failed');
    assert.equal(status.reason, reason);
    assert.ok(stderr.includes(`NOT RETRIEVED: ${reason}`));
  });
}

test('drains large stderr concurrently with stdout', async (t) => {
  const run = await launch(t, 'stderr');
  const { code, stdout, stderr } = await run.finished();
  assert.equal(code, 0, stderr.slice(-1000));
  assert.equal(JSON.parse(stdout).answer, 'Verified answer.');
  assert.ok(stderr.length < 100000, 'raw diagnostics should not flood the progress channel');
});

for (const ending of ['timeout', 'cancel']) {
  test(`${ending} kills descendants that ignore SIGINT and SIGTERM`, async (t) => {
    const run = await launch(t, 'descendants', { args: ['--timeout', ending === 'timeout' ? '1' : '10'] });
    const pids = await waitForJson(run.pidsFile, (value) => value.length === 2);
    if (ending === 'cancel') run.child.kill('SIGINT');
    const { code, stdout, status } = await run.finished();
    assert.equal(code, ending === 'cancel' ? 130 : 1);
    assert.equal(stdout, '');
    assert.equal(status.state, ending === 'timeout' ? 'timed_out' : 'cancelled');
    assert.equal(status.reason, ending === 'timeout' ? 'max_duration_exceeded' : 'cancelled');
    await assertStopped(pids);
  });
}

for (const scenario of ['orphan_pipe', 'orphan_unterminated', 'orphan_no_pipes']) {
  test(`bounds successful cleanup with a surviving ${scenario} descendant`, async (t) => {
    const started = performance.now();
    const run = await launch(t, scenario);
    const pids = await waitForJson(run.pidsFile, (value) => value.length === 2);
    const { code, stdout, stderr } = await run.finished();
    assert.equal(code, 0, stderr);
    assert.equal(JSON.parse(stdout).answer, 'Verified answer.');
    assert.ok(performance.now() - started < 3500);
    await assertStopped(pids);
  });
}

for (const ending of ['signal', 'output_error']) {
  test(`${ending} during successful cleanup prevents a success result`, async (t) => {
    const run = await launch(t, 'orphan_pipe', { timings: { signalGraceMs: 200 } });
    const pids = await waitForJson(run.pidsFile, (value) => value.length === 2);
    await waitForJson(run.statusFile, (status) => status.state === 'stopping');
    if (ending === 'signal') run.child.kill('SIGTERM');
    else run.child.stderr.destroy();
    const { code, stdout, status } = await run.finished();
    assert.equal(code, ending === 'signal' ? 143 : 1);
    assert.equal(stdout, '');
    assert.equal(status.reason, ending === 'signal' ? 'cancelled' : 'output_failed');
    await assertStopped(pids);
  });
}

for (const stream of ['stdout', 'stderr']) {
  test(`closing supervisor ${stream} fails and leaves no detached descendants`, async (t) => {
    const run = await launch(t, stream === 'stdout' ? 'orphan_pipe' : 'descendants');
    const pids = await waitForJson(run.pidsFile, (value) => value.length === 2);
    run.child[stream].destroy();
    const { code, status } = await run.finished();
    assert.equal(code, 1);
    assert.equal(status.state, 'failed');
    assert.equal(status.reason, 'output_failed');
    await assertStopped(pids);
  });
}

test('reports a missing Claude CLI without waiting for a timeout', async (t) => {
  const run = await launch(t, 'success', { noClaude: true });
  const { code, stdout, status } = await run.finished();
  assert.equal(code, 1);
  assert.equal(stdout, '');
  assert.equal(status.state, 'failed');
  assert.equal(status.reason, 'cli_missing');
});

for (const spawnFailure of ['throw', 'missing_stdio']) {
  test(`records ${spawnFailure} spawn failures without an uncaught error`, async (t) => {
    const run = await launch(t, 'success', { spawnFailure });
    const { code, stdout, stderr, status } = await run.finished();
    assert.equal(code, 1);
    assert.equal(stdout, '');
    assert.equal(status.state, 'failed');
    assert.equal(status.reason, 'process_failed');
    assert.match(stderr, /NOT RETRIEVED: process_failed/);
    await assert.rejects(readFile(run.captureFile), { code: 'ENOENT' });
  });
}

test('status remains valid JSON during updates, is private, and preserves terminal state', async (t) => {
  const run = await launch(t, 'silent');
  await waitForJson(run.statusFile);
  for (let index = 0; index < 60; index += 1) {
    assert.equal((await stat(run.statusFile)).mode & 0o777, 0o600);
    const status = JSON.parse(await readFile(run.statusFile, 'utf8'));
    assert.equal(typeof status.elapsed_seconds, 'number');
    assert.ok(['running', 'succeeded'].includes(status.state));
    await sleep(2);
  }
  const { status } = await run.finished();
  assert.equal(status.state, 'succeeded');
  await sleep(50);
  assert.deepEqual(JSON.parse(await readFile(run.statusFile, 'utf8')), status);
});

test('rejects an unusable status destination before launching Claude', async (t) => {
  const run = await launch(t, 'success', { statusFile: 'missing/status.json' });
  const { code, stderr } = await run.exited();
  assert.equal(code, 1);
  assert.match(stderr, /NOT RETRIEVED: status_file_error/);
  await assert.rejects(readFile(run.captureFile), { code: 'ENOENT' });
});

test('does not overwrite an existing status file or launch Claude', async (t) => {
  const run = await launch(t, 'success', { existingStatus: 'Existing status.\n' });
  const { code, stderr } = await run.exited();
  assert.equal(code, 1);
  assert.match(stderr, /NOT RETRIEVED: status_file_error/);
  assert.equal(await readFile(run.statusFile, 'utf8'), 'Existing status.\n');
  await assert.rejects(readFile(run.captureFile), { code: 'ENOENT' });
});
