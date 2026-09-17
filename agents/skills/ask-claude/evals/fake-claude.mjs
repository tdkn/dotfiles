#!/usr/bin/env node
import { spawn } from 'node:child_process';
import { renameSync, writeFileSync } from 'node:fs';

const scenario = process.env.ASK_TEST_SCENARIO;
const answer = { status: 'answered', summary: 'Summary', answer: 'Verified answer.', findings: [] };
const result = (value = answer) => ({ type: 'result', subtype: 'success', is_error: false, structured_output: value });
const emit = (value) => process.stdout.write(`${JSON.stringify(value)}\n`);
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const progress = (kind = 'thinking') => emit({
  type: 'stream_event',
  event: { type: 'content_block_delta', index: 0, delta: { type: `${kind}_delta`, [kind]: `PRIVATE_${kind}_CONTENT` } },
});
const retry = (delay = 5000) => emit({
  type: 'system', subtype: 'api_retry', attempt: 1, max_retries: 3,
  retry_delay_ms: delay, error: 'overloaded_error',
});

const { summary, ...withoutSummary } = answer;
const invalidAnswers = {
  missing_summary: withoutSummary,
  wrong_findings: { ...answer, findings: 'none' },
  invalid_finding: { ...answer, findings: [{ severity: 'urgent', issue: 'Issue', why: 'Reason' }] },
  invalid_optional: { ...answer, confidence: 1 },
  invalid_questions: { ...answer, open_questions: [false] },
  invalid_location: { ...answer, findings: [{ severity: 'high', issue: 'Issue', why: 'Reason', line: 12 }] },
  missing_finding_reason: { ...answer, findings: [{ severity: 'high', issue: 'Issue' }] },
  blank: { ...answer, answer: ' \n\t ' },
  unable: { ...answer, status: 'unable_to_answer', answer: '' },
};

function writePids(pids) {
  const path = process.env.ASK_TEST_PIDS;
  writeFileSync(path + '.tmp', JSON.stringify(pids));
  renameSync(path + '.tmp', path);
}

let packet = '';
for await (const chunk of process.stdin) packet += chunk;
writePids([process.pid]);
if (process.env.ASK_TEST_CAPTURE) {
  writeFileSync(process.env.ASK_TEST_CAPTURE, JSON.stringify({ args: process.argv.slice(2), packet }));
}

if (Object.hasOwn(invalidAnswers, scenario)) {
  emit(result(invalidAnswers[scenario]));
} else switch (scenario) {
  case 'success':
    emit({ type: 'system', subtype: 'init' });
    emit({ type: 'stream_event', event: { type: 'content_block_start', index: 0, content_block: { type: 'thinking', thinking: '' } } });
    progress();
    await sleep(70);
    progress('text');
    emit(result());
    break;
  case 'silent':
    emit({ type: 'system', subtype: 'init' });
    await sleep(250);
    emit(result());
    break;
  case 'retry':
    progress();
    await sleep(60);
    retry();
    await sleep(250);
    emit(result());
    break;
  case 'active_timeout':
    progress();
    setInterval(() => { progress(); retry(); }, 60);
    break;
  case 'chunks': {
    const data = Buffer.from(`${JSON.stringify({ type: 'future_event', payload: 'ignored' })}\n${JSON.stringify(result({ ...answer, answer: '答え 🙂 café' }))}`);
    for (let index = 0; index < data.length; index += 1) {
      process.stdout.write(data.subarray(index, index + 1));
      if (index % 7 === 0) await sleep(1);
    }
    break;
  }
  case 'missing':
    progress('text');
    break;
  case 'invalid_json':
    process.stdout.write('{not-json}\n');
    emit(result());
    break;
  case 'duplicate_result':
    emit(result());
    emit(result());
    break;
  case 'not_result':
    emit({ ...result(), type: 'assistant' });
    break;
  case 'result_error':
    emit({ ...result(), is_error: true });
    break;
  case 'result_failure':
    emit({ ...result(), subtype: 'error_during_execution' });
    break;
  case 'nonzero':
    emit(result());
    process.exitCode = 9;
    break;
  case 'stderr':
    for (let index = 0; index < 512; index += 1) process.stderr.write('diagnostic '.repeat(1024));
    emit(result());
    break;
  case 'descendants':
  case 'orphan_pipe':
  case 'orphan_unterminated':
  case 'orphan_no_pipes': {
    process.on('SIGINT', () => {});
    process.on('SIGTERM', () => {});
    const childOutput = scenario === 'orphan_no_pipes' ? 'ignore' : 'inherit';
    const descendant = spawn(process.execPath, ['-e', `
      process.on('SIGINT', () => {});
      process.on('SIGTERM', () => {});
      process.send('ready');
      setInterval(() => {}, 1000);
    `], { stdio: ['ignore', childOutput, childOutput, 'ipc'] });
    await new Promise((resolve) => descendant.once('message', resolve));
    writePids([process.pid, descendant.pid]);
    if (scenario !== 'descendants') {
      if (scenario === 'orphan_unterminated') process.stdout.write(JSON.stringify(result()));
      else emit(result());
      process.exit(0);
    }
    setInterval(() => {}, 1000);
    break;
  }
  default:
    throw new Error(`Unknown fake Claude scenario: ${scenario}`);
}
