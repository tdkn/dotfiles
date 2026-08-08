---
name: delegate-code-review
description: Delegate code review to Claude Code, verify the review was actually returned, then collect and triage its feedback. Use when the user asks to run Claude Code review, ask Claude to review a diff or change, gather a second opinion from Claude Code, or summarize delegated Claude review findings.
---

# Delegate Code Review

## Overview

Ask Claude Code to review the current code change without editing it, verify that
a real review came back, then merge its findings into a concise, actionable
summary.

Core principle: **distinguish "not retrieved" from "no findings".** A delegated
run can exit 0 yet return nothing usable. Never present an unretrieved review as a
clean bill of health. A review counts as retrieved only when the CLI returns a
valid, schema-conforming structured result with an explicit verdict.

Keep this file as the dispatcher. Load `references/claude-cli.md` before running
Claude Code.

## References

- `references/claude-cli.md`: Claude Code CLI facts, the structured review
  contract and schema, packet and workspace patterns, result verification, the
  single-retry rule, and output capture.

## Choose How to Delegate

- If you are **not** Claude Code (e.g. another agent wanting Claude's opinion),
  shell out to `claude -p` as described in `references/claude-cli.md`.
- If you **are** Claude Code, prefer an in-session review — a review subagent or
  the built-in `/code-review` — over spawning `claude -p`. A nested `claude -p`
  is slower and more brittle (subprocess, auth, and trust edge cases) and gives
  only a same-model second opinion. Shell out only when an external, separate
  Claude run is specifically wanted.

## Workflow

1. Define the review scope.
   - Identify what to review: current branch, working tree, a PR, selected
     files, or a specific concern.
   - Identify what to return: bugs only, maintainability, security, test gaps, or
     all actionable findings.
   - Claude Code may receive code, diffs, prompts, and repo metadata. If private
     workspace data may leave the environment, get explicit approval that names
     Claude Code and the scoped material.
   - If the scope is ambiguous and no reasonable default exists, ask one short
     question before running.

2. Prepare a review packet.
   - Include the repo-relative scope, baseline if known, user intent, and any
     files or risks to prioritize.
   - Explicitly instruct the reviewer to review only and not edit files.
   - Prefer a self-contained packet with the relevant diff or file excerpts, so
     the reviewer does not rediscover scope through shell commands.
   - Include untracked new files. A plain tracked diff omits the files most
     relevant to a new skill or document.
   - Use `references/claude-cli.md` for the schema, prompt, and command patterns.

3. Run Claude Code.
   - Use packet mode from `references/claude-cli.md` by default: structured
     output (`--output-format json --json-schema ...`), `--safe-mode`, and tools
     disabled. Fall back to read-only workspace mode only when the packet would
     be too large.
   - Keep raw reviewer output distinct from local verification notes.

4. Verify the result was retrieved.
   - Require: shell exit 0, `is_error == false`, `subtype == "success"`, a
     schema-valid `structured_output`, and a `verdict` of `sound`, `findings`, or
     `unable_to_review`. When `verdict` is `findings`, the findings array must be
     non-empty.
   - Treat empty output, parse failure, a missing verdict, or `unable_to_review`
     as **not retrieved**. Do not report it as "no issues".
   - On a not-retrieved outcome, retry once with diagnostics and a smaller packet
     (see the reference). If it still fails, report that the delegated review did
     not run and why.

5. Triage the feedback.
   - Deduplicate overlapping findings.
   - Verify plausible findings against the local code before presenting them.
   - Separate confirmed issues, uncertain items needing follow-up, and
     non-actionable style preferences.

6. Report results.
   - Lead with confirmed actionable findings ordered by severity.
   - Attribute findings to Claude Code when useful.
   - Include file and line evidence when available.
   - State plainly when the review could not be retrieved and why — never
     substitute your own local analysis for the delegated review.

## Guardrails

- Do not let Claude Code modify files unless the user explicitly asks for
  implementation work.
- Do not paste secrets, private logs, or environment-specific paths into prompts
  or summaries.
- Prefer current `--help` output over memorized flags whenever a command fails or
  looks version-sensitive.
- Keep raw reviewer output in temporary or already-ignored local files.
- `claude ultrareview` sends the branch to the cloud and costs money; use it only
  as an explicitly approved supplement, never as the default.
- Quote shell paths that may contain spaces, parentheses, or glob characters.
