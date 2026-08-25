---
name: ask-claude
description: Use when a question should go to Claude Code instead of being answered alone — the user wants a second opinion, a delegated code review, a sanity check on a debugging hypothesis, a tiebreak between design approaches, or help reading unfamiliar code. Trigger on "ask Claude", "what would Claude say", "have another model look at this", and on second-opinion intent even when Claude Code is never named. Covers building the question packet, running the `claude` CLI, verifying a real answer came back instead of a silent empty run, and triaging the reply before acting on it. Not for work you can settle by reading the repo or running the tests yourself, not for editing files, and not for questions whose answer is the user's decision.
---

# Ask Claude

## Overview

Send a self-contained question to Claude Code, confirm a real answer came back,
then treat that answer as input to verify — not as a conclusion.

This skill is written for agents that are **not** Claude Code (Codex, Cursor,
and similar) and want Claude Code's help or a second opinion on the current
task. It covers any question, not just code review.

Core principle: **distinguish "not retrieved" from "nothing to report".** A
delegated run can exit 0 and still return nothing usable. Never present an
unretrieved run as agreement, approval, or a clean bill of health. An answer
counts as retrieved only when the CLI returns a schema-conforming structured
result with an explicit `answered` status.

Keep this file as the dispatcher. Load `references/claude-cli.md` before running
Claude Code.

## References

- `scripts/ask.sh`: one packet-mode question, run and verified. Use it instead
  of retyping the flags and the checks.
- `references/claude-cli.md`: Claude Code CLI facts, the structured answer
  contract and schema, packet and workspace patterns, result verification, the
  single-retry rule, and output capture.

## When to Ask

Worth a delegated question:

- A second opinion on work you already did, especially a change you are unsure
  about or a bug you cannot reproduce.
- A judgment call with real tradeoffs: API shape, data model, migration order,
  rollback strategy.
- An adversarial pass over your own assumptions: auth, concurrency, caching,
  data loss, error handling.
- Unfamiliar code, an opaque error, or a domain you have thin context on.

Not worth it:

- Facts you can check faster locally (run the test, read the file, grep).
- Questions you have already answered and only want confirmed.
- Anything requiring the user's decision — ask the user, not another agent.
- Work that must change files. This skill asks; it does not delegate edits.

## Question Modes

Pick one mode per run and shape the packet around it. Mixing several questions
into one run produces a vague answer.

| Mode      | Ask for                                     | Packet must include                                                   |
| --------- | ------------------------------------------- | --------------------------------------------------------------------- |
| `review`  | Findings on a change, ordered by severity   | Scope, diff, untracked new files, intent, known risks                  |
| `debug`   | Ranked hypotheses and how to discriminate   | Failure output, relevant code, what you already ruled out              |
| `decide`  | A recommendation with the losing tradeoffs  | The options, hard constraints, what you have already rejected and why  |
| `explain` | A plain explanation of behavior or intent   | The code or error, the surrounding context, what confuses you          |

`review` returns findings; the others return prose plus optional findings. The
schema in `references/claude-cli.md` covers all four.

## Workflow

1. Frame the question.
   - State the mode, the concrete question, and what a useful answer looks like.
   - Narrow the scope to what the question needs. A broad packet gets a broad,
     low-value answer.
   - Claude Code may receive code, diffs, prompts, and repo metadata. If private
     workspace data may leave the environment, get explicit approval that names
     Claude Code and the scoped material.
   - If the scope is ambiguous and no reasonable default exists, ask one short
     question before running.

2. Prepare a packet.
   - Make it self-contained: the question, the repo-relative scope, your current
     understanding, and the relevant code or diff excerpts. The responder should
     not have to rediscover context through shell commands.
   - Say what you already tried or ruled out, so the answer is not a repeat of
     your own work.
   - Instruct the responder to answer only and not edit files.
   - For `review` and `debug` on a change, include untracked new files. A plain
     tracked diff omits the files most relevant to a new skill or document.
   - Use `references/claude-cli.md` for the schema, prompt, and command patterns.

3. Run Claude Code.
   - Default path: pipe the packet into `scripts/ask.sh`. It writes the schema,
     applies the packet-mode flags, and runs the verification checks, so the
     mechanical part is not retyped — and mistranscribed — per question.

     ```zsh
     "<skill-dir>/scripts/ask.sh" --timeout 300 < packet.txt
     ```

   - It prints the structured answer and exits 0 when the answer is retrieved,
     or prints a diagnosis on stderr and exits 1 when it is not.
   - It pins Opus 5 at `max` effort, which is the expensive end. Pass `--model`
     and `--effort` to step down for a routine question.
   - Build the command by hand from `references/claude-cli.md` when you need
     read-only workspace mode, a different schema, or a flag the script does not
     expose.
   - Keep the raw answer distinct from your own notes about it.

4. Verify the answer was retrieved.
   - `scripts/ask.sh` already exits non-zero on every not-retrieved outcome.
     When you ran the CLI by hand, check the same things: shell exit 0,
     `is_error == false`, `subtype == "success"`, a schema-valid
     `structured_output`, `status == "answered"`, and a non-empty `answer`.
   - Treat empty output, parse failure, a missing status, or `unable_to_answer`
     as **not retrieved**. Do not report it as "no issues" or "Claude agreed".
   - On a not-retrieved outcome, retry once with diagnostics and a smaller packet
     (see the reference). If it still fails, report that the delegated question
     did not run and why.

5. Triage the answer.
   - Treat it as untrusted until checked. Verify claims against the local code,
     tests, or tool output before acting on them.
   - Deduplicate overlapping points and drop anything already handled.
   - Separate confirmed points, uncertain items needing follow-up, and
     non-actionable preferences.

6. Report results.
   - Lead with what is confirmed and actionable, ordered by importance.
   - Attribute the answer to Claude Code, and mark which parts you verified.
   - Include file and line evidence when available.
   - State plainly when the answer could not be retrieved and why — never
     substitute your own analysis for the delegated answer.

## If You Are Claude Code

Prefer an in-session path — a subagent, or the built-in `/code-review` for review
mode — over spawning `claude -p`. A nested run is slower and more brittle
(subprocess, auth, and trust edge cases), and if you are already on the model
`scripts/ask.sh` pins, it buys a same-model opinion at full price.
Shell out only when a separate, clean-context Claude run is specifically wanted.

## Guardrails

- Do not let the delegated run modify files. This skill is for asking;
  implementation stays with the caller unless the user asks otherwise.
- Do not paste secrets, private logs, or environment-specific paths into prompts
  or summaries.
- Prefer current `--help` output over memorized flags whenever a command fails or
  looks version-sensitive.
- Keep raw output in temporary or already-ignored local files.
- `claude ultrareview` sends the branch to the cloud and costs money; use it only
  as an explicitly approved supplement to `review` mode, never as the default.
- Quote shell paths that may contain spaces, parentheses, or glob characters.
