# Claude CLI Reference

Use this reference when asking Claude Code (`claude`) a question from another
agent.

Core principle: **a run that exits 0 is not proof of an answer.** Treat the
answer as retrieved only when the CLI returns a valid, schema-conforming
structured result with `status: answered`. An empty, malformed, or
`unable_to_answer` result means the answer was **not retrieved** — never report
it as "no issues" or as agreement.

## CLI Help

Flags change between versions. Confirm before relying on one, especially after an
upgrade:

```zsh
claude --help
claude auth --help
```

Flags this skill depends on (all present in current builds):

- `-p, --print`: non-interactive; print the result and exit.
- `--output-format stream-json --verbose --include-partial-messages`: emit
  newline-delimited events while Claude runs, including partial messages and
  a final `result` envelope. Requires `--print`.
- `--json-schema <schema>`: constrain the result to a JSON Schema. The parsed
  object comes back in the envelope's `structured_output` field.
- `--tools ""`: disable all built-in tools for a self-contained packet question.
- `--allowedTools <names...>`: allowlist specific tools (comma/space separated),
  e.g. `Read Grep Glob` for a read-only workspace question.
- `--safe-mode`: disable CLAUDE.md, skills, plugins, hooks, MCP, custom
  commands/agents, themes, and keybindings. Auth, model, built-in tools, and
  permissions still work normally.
- `--no-session-persistence`: do not save the session to disk (needs `--print`).
- `--system-prompt <prompt>`: replace the default system prompt.
- `--model <model>`: pin the responder model (see the cost note below). Takes an
  alias (`opus`) or a full name (`claude-opus-5`).
- `--effort <level>`: reasoning effort — `low`, `medium`, `high`, `xhigh`, `max`.
- `--debug-file <path>`: write debug logs to a file (used on the single retry).

Do **not** use `--bare` for this: it forces `ANTHROPIC_API_KEY`/apiKeyHelper auth
and never reads OAuth or the keychain, so it breaks subscription/OAuth users.
`--safe-mode` gives the same clean, uncontaminated responder while leaving auth
intact.

Why `--safe-mode` matters here: without it, the delegated run loads the host's
`CLAUDE.md`, skills, and hooks. Personal instructions (answer language,
formatting rules, commit conventions) can reshape the answer text and fight the
JSON schema. `--safe-mode` yields a deterministic, uncontaminated answer.

Do **not** use `--permission-mode plan` for a packet question. In print mode,
plan mode routes the deliverable through the `ExitPlanMode` tool; with
`--tools ""` that tool is disabled, so a real prompt can exit 0 with empty or
degraded output. Omit it entirely for packet mode.

`claude -p` skips the interactive workspace-trust dialog. Use it only after the
user has approved sending the scoped material to Claude Code.

## Preflight

Read both this file and [sandbox.md](sandbox.md) before any preflight or Claude
invocation. Check availability and auth only when needed:

```zsh
command -v claude
claude auth status
```

Interpret these checks according to their execution boundary:

- A host/native `command -v claude` failure is `cli_missing`; stop and report
  it. A sandbox-only failure is not enough to prove the CLI is absent.
- A sandbox `claude auth status` result such as `loggedIn: false`, a failed
  status command, or denied credential-store access leaves auth **unknown**. It
  is not `auth_missing`.
- For an unknown sandbox result, use the host's narrow escalation mechanism to
  run the exact `claude auth status` command. That check needs the installed CLI
  and its existing credential store, not the packet or workspace files. Never
  start an interactive login flow.
- If the host/native check reports authenticated, continue. If the sandbox
  cannot use that auth state, run the Claude question at the host boundary too.
- Only a host/native check that explicitly reports unauthenticated is
  `auth_missing`; stop and report it without starting login.
- If the host/native check is unavailable or denied, report not retrieved with
  reason `sandbox_auth_unverified`, not `auth_missing`.

Moving an unchanged auth check or Claude command across the sandbox boundary is
not the single response retry. Follow `sandbox.md` for the complete decision
table, narrow-access rules, and stop conditions.

## Structured Answer Contract

Ask for a structured result so success can be verified mechanically. One schema
covers every mode; `findings` stays empty when the question is not about defects
(store the schema in a file to pass it cleanly):

```json
{
  "type": "object",
  "properties": {
    "status": {
      "type": "string",
      "enum": ["answered", "unable_to_answer"]
    },
    "summary": { "type": "string" },
    "answer": { "type": "string" },
    "confidence": { "type": "string", "enum": ["high", "medium", "low"] },
    "findings": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "severity": { "type": "string", "enum": ["high", "medium", "low"] },
          "file": { "type": "string" },
          "line": { "type": "string" },
          "issue": { "type": "string" },
          "why": { "type": "string" },
          "fix": { "type": "string" }
        },
        "required": ["severity", "issue", "why"]
      }
    },
    "open_questions": { "type": "array", "items": { "type": "string" } }
  },
  "required": ["status", "summary", "answer", "findings"]
}
```

Field meaning:

- `status: answered`: the question was answered from the material provided.
- `status: unable_to_answer`: the packet or context was insufficient. This is a
  **not-retrieved** outcome, not agreement and not a clean bill of health.
- `summary`: one or two sentences, the headline.
- `answer`: the substance — reasoning, recommendation, or explanation.
- `findings`: defect-shaped items. Non-empty for `review` and often for `debug`;
  empty for `decide` and `explain`.
- `open_questions`: what the responder would need to be more certain.

## Packet Mode (default)

Use `scripts/ask.sh` for the standard schema and packet mode. It launches a
Node.js supervisor using only standard libraries. Neither `jq` nor an external
`timeout` command is needed for this helper.

```zsh
ask_dir=$(mktemp -d "${TMPDIR:-/tmp}/claude-ask.XXXXXX")
"<skill-dir>/scripts/ask.sh" --status-file "$ask_dir/status.json" \
  < packet.txt > "$ask_dir/answer.json"
```

The helper prints only the verified structured answer object on stdout.
Progress and failure reasons go to stderr. It never retries a question itself.
Use `--timeout <seconds>` to change the 1800-second hard limit; the value must
be a positive integer. See the monitoring policy below before running it.

Use a raw command only when changing the schema, tools, or mode. The following
transport example extracts the final envelope without saving partial content.
Its `jq` filter is not the helper's supervisor: the caller must supervise the
process, preserve progress metadata before filtering if needed, and enforce
the same time and cleanup policy.

Build a self-contained packet (question + scope + relevant code or diff
excerpts) and pass it on stdin. Disable tools so the responder works only from
the packet.

```zsh
set -o pipefail
ask_dir=$(mktemp -d "${TMPDIR:-/tmp}/claude-ask.XXXXXX")
# write the schema above to "$ask_dir/schema.json"
# write the self-contained packet to "$ask_dir/packet.txt"

claude -p \
  --output-format stream-json --verbose --include-partial-messages \
  --json-schema "$(cat "$ask_dir/schema.json")" \
  --safe-mode \
  --tools "" \
  --no-session-persistence \
  --system-prompt "You are answering a question from another coding agent. You have only this packet and no tools. Do not request tool use. Base every claim on the packet. Do not propose edits unless the packet asks for them. If the packet is insufficient to answer, set status to unable_to_answer and say what is missing in summary." \
  < "$ask_dir/packet.txt" 2> "$ask_dir/err.log" \
  | jq --unbuffered -c 'select(.type == "result")' > "$ask_dir/out.json"
run_status=$?
```

Start the packet body with: `You have no tools. Use only this packet. Do not
request tool use.` Then state the mode and the question in the first lines, so
the answer is aimed before the context arrives. Frame diffs clearly (label
added/removed lines) so a leading `+`/`-` is not mistaken for source.

### Untracked files in the packet

`git diff` omits untracked new files — often the most relevant ones for a new
skill or document. Include them explicitly:

```zsh
git diff -- <paths>
git ls-files --others --exclude-standard -- <paths>
```

For each untracked file in scope, include its repo-relative path and full
contents (or a labeled excerpt cut only at a clean boundary — never mid-sentence
or mid-code-fence).

## Progress and time limits

Keep the execution session returned by the host tool and poll it every 30–60
seconds. Short tool waits should yield a session to resume, not kill the
process. Do not wrap the helper in an outer 10-minute timeout. If the tool
requires a hard deadline, allow the configured limit plus at least 15 seconds
for shutdown. Send cancellation to the supervisor so it can stop its process
group; do not kill only the wrapper or abandon the session.

| Observation | Action |
| --- | --- |
| State change or 30 seconds since the last heartbeat | Print concise metadata on stderr. |
| 10 minutes elapsed | Warn once and continue. |
| No content progress for 10 minutes | Warn and continue; silence is not proof of a stalled model. |
| API retry with a reported delay | Show the next retry time and suppress idle warnings during the wait. |
| 30 minutes elapsed, or the configured hard limit | Begin shutdown even if progress is arriving. |
| Caller cancels or Claude fails | Record the reason and clean up. |

Thinking and answer updates count as content progress. Initialization, API
retry events, and the supervisor's heartbeat do not. A phase such as `thinking`
describes the last observed event, so always read it with its age. Events cannot
prove that Claude is currently working or predict when it will finish.

`--status-file <path>` writes a metadata-only JSON snapshot before starting
Claude, on updates, and at completion. It includes execution state, the last
observed phase, elapsed time, event and content-progress ages, API retry
information, and the final outcome. Writes replace the file atomically with
permissions `0600`. Its parent directory must already exist; use a fresh path
per invocation in a private temporary directory. An unusable destination fails
before Claude starts. The caller owns the file and removes it after reading the
terminal state. Neither the status file nor stderr contains thinking text or
partial answer text, and the helper does not save the raw event stream.

Elapsed and idle timers use a monotonic clock. Warnings and retries do not
extend the hard limit. On timeout or cancellation, the supervisor sends SIGINT
to Claude's process group, SIGTERM after 5 seconds, and SIGKILL after another
5 seconds if needed. It drains stdout and stderr concurrently and bounds
cleanup even if a descendant leaves a pipe open. The configured limit is when
shutdown begins, not a promise that cleanup has already finished.

## Verifying the Result

The answer is retrieved only if **all** of these hold. Otherwise report it as
not retrieved — do not present your own analysis as the delegated answer.
For a manual run, validate `structured_output` against the full schema above
as well as checking the envelope and answer below. Stop at any failing check.

```zsh
out="$ask_dir/out.json"

# 1. The pipeline succeeded, including Claude (pipefail was set above).
[ "$run_status" -eq 0 ]
# 2. The run itself succeeded.
jq -e -s 'length == 1 and (.[0] | .type == "result" and
  .is_error == false and .subtype == "success")' "$out" >/dev/null

# 3. Read the status from the parsed structured object (not from `.result`).
status=$(jq -r '.structured_output.status // "missing"' "$out")

case "$status" in
  answered)
    jq -e '.structured_output.answer | type == "string" and test("\\S")' "$out" >/dev/null \
      && echo "answered: $(jq -r '.structured_output.findings | length' "$out") finding(s)" \
      || echo "NOT retrieved: answered status but empty answer" ;;
  unable_to_answer) echo "NOT retrieved: responder could not answer from the packet" ;;
  *)                echo "NOT retrieved: no valid structured status" ;;
esac
```

Notes:

- Schema validation includes optional field types and finding severities. The
  helper performs that validation itself.
- Partial events are progress only. Success requires the final `result` and a
  successful process exit. Do not accept a result from a cancelled or timed-out
  run, even if it appears during shutdown.
- Read `structured_output` (the parsed object), not `.result` (a stringified
  duplicate).
- Do **not** gate on `stop_reason`. With `--json-schema` the result is delivered
  via a synthetic tool call, so `stop_reason` is `tool_use` even on success.
- `permission_denials` in the envelope is a useful signal: a non-empty array
  means the responder tried a blocked tool, so the answer may be degraded.
- `answered` with an empty `findings` array is a real result for `review` mode:
  reviewed, nothing actionable. That is not the same as a missing status.

## Single Retry

Use this retry only after a Claude invocation completed but returned an
unusable result: empty or malformed output, schema mismatch,
`unable_to_answer`, or another missing answer. Do not use it for `cli_missing`,
`auth_missing`, `sandbox_auth_unverified`, `sandbox_blocked`, time limits,
cancellations, or process failures. Moving the same command across the sandbox
boundary does not consume it.

Retry **once** with diagnostics and a smaller, clearer packet:

```zsh
set -o pipefail
claude -p \
  --output-format stream-json --verbose --include-partial-messages \
  --json-schema "$(cat "$ask_dir/schema.json")" \
  --safe-mode --tools "" --no-session-persistence \
  --debug-file "$ask_dir/debug.log" \
  --system-prompt "<same responder instruction>" \
  < "$ask_dir/packet-small.txt" 2>> "$ask_dir/err.log" \
  | jq --unbuffered -c 'select(.type == "result")' > "$ask_dir/out2.json"
run_status=$?
```

Supervise this raw invocation with the same monitoring and time policy. Apply
the result checks to `out2.json`. Debug logs are local diagnostics for this
single retry; do not log raw streaming events or expose their contents. If the
retry is still not retrieved, report that no answer was retrieved and why.
Do not keep probing unrelated invocations.

## Workspace Mode (fallback)

Use this only when the packet would be too large or too incomplete to answer
from. Grant read-only tools and keep the same schema. Read tools must be
allowlisted or print mode will auto-deny them.

```zsh
set -o pipefail
claude -p \
  --output-format stream-json --verbose --include-partial-messages \
  --json-schema "$(cat "$ask_dir/schema.json")" \
  --safe-mode \
  --allowedTools Read Grep Glob \
  --no-session-persistence \
  --system-prompt "You are answering a question from another coding agent. Read only; never edit. Base every claim on the repository. If you cannot determine the scope, set status to unable_to_answer." \
  "<the question, with repo-relative scope>" 2> "$ask_dir/err.log" \
  | jq --unbuffered -c 'select(.type == "result")' > "$ask_dir/out.json"
run_status=$?
```

Supervise this raw invocation with the same monitoring and time policy, then
verify the result with the same checks. Prefer read/search tools; avoid `Bash`,
which can trigger approval loops inside the delegated session.

## Cost

`scripts/ask.sh` pins `--model claude-opus-5 --effort max`. A question is
delegated precisely when the reasoning is the deliverable, and an inherited
default drifts: whenever it happens to match the caller's own model, the second
opinion quietly becomes an echo. Pinning also keeps answers comparable across
runs.

That pin is the expensive end of the range. Override it per call when the
question does not need it:

```zsh
scripts/ask.sh --model sonnet --effort medium < packet.txt
```

Valid effort levels are `low`, `medium`, `high`, `xhigh`, and `max`. A raw
`claude -p` built by hand inherits the CLI default instead, so pass `--model`
and `--effort` explicitly there. Keep the packet tight on any model — a bloated
packet raises cost on every run.

## ultrareview (optional, paid)

`claude ultrareview [target]` runs a cloud-hosted multi-agent review of the
current branch (or a PR number / base branch). It sends the branch to the cloud
and incurs cost, so treat it as an explicit, user-approved supplement to `review`
mode — not a default. Do not run it without approval.

## Capturing Output

Keep packets, final answers, status files, and any retry diagnostics in the
private temporary directory (`$ask_dir` above) or an already-ignored private
path. Do not commit them or save the raw event stream. Quote shell paths that
may contain spaces, parentheses, or glob characters.
