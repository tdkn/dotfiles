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
- `--output-format json`: wrap the result in a JSON envelope (needs `--print`).
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

Check availability and auth only when needed:

```zsh
command -v claude
claude auth status
```

If authentication is missing, stop and report the blocker. Do not start an
interactive login flow.

If your own shell runs sandboxed without network access — the default in several
coding agents — `claude -p` fails on the API call, not on the prompt. Request
the escalation your harness provides, or report the sandbox as the blocker.
Do not retry the same sandboxed command.

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

`scripts/ask.sh` runs exactly this and applies the checks below; reach for the
raw command when you need to change the schema, the tools, or the mode.

Build a self-contained packet (question + scope + relevant code or diff
excerpts) and pass it on stdin. Disable tools so the responder works only from
the packet. Wrap with `timeout`/`gtimeout` when available; otherwise poll and
terminate only the stuck `claude -p` command.

```zsh
ask_dir=$(mktemp -d "${TMPDIR:-/tmp}/claude-ask.XXXXXX")
# write the schema above to "$ask_dir/schema.json"
# write the self-contained packet to "$ask_dir/packet.txt"

timeout <seconds> claude -p \
  --output-format json \
  --json-schema "$(cat "$ask_dir/schema.json")" \
  --safe-mode \
  --tools "" \
  --no-session-persistence \
  --system-prompt "You are answering a question from another coding agent. You have only this packet and no tools. Do not request tool use. Base every claim on the packet. Do not propose edits unless the packet asks for them. If the packet is insufficient to answer, set status to unable_to_answer and say what is missing in summary." \
  < "$ask_dir/packet.txt" \
  > "$ask_dir/out.json" 2> "$ask_dir/err.log"
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

## Verifying the Result

The answer is retrieved only if **all** of these hold. Otherwise report it as
not retrieved — do not present your own analysis as the delegated answer.

```zsh
out="$ask_dir/out.json"

# 1. Shell exit code was 0 (check right after the command).
# 2. The run itself succeeded.
jq -e '.is_error == false and .subtype == "success"' "$out" >/dev/null

# 3. Read the status from the parsed structured object (not from `.result`).
status=$(jq -r '.structured_output.status // "missing"' "$out")

case "$status" in
  answered)
    jq -e '(.structured_output.answer | length) > 0' "$out" >/dev/null \
      && echo "answered: $(jq -r '.structured_output.findings | length' "$out") finding(s)" \
      || echo "NOT retrieved: answered status but empty answer" ;;
  unable_to_answer) echo "NOT retrieved: responder could not answer from the packet" ;;
  *)                echo "NOT retrieved: no valid structured status" ;;
esac
```

Notes:

- Read `structured_output` (the parsed object), not `.result` (a stringified
  duplicate).
- Do **not** gate on `stop_reason`. With `--json-schema` the result is delivered
  via a synthetic tool call, so `stop_reason` is `tool_use` even on success.
- `permission_denials` in the envelope is a useful signal: a non-empty array
  means the responder tried a blocked tool, so the answer may be degraded.
- `answered` with an empty `findings` array is a real result for `review` mode:
  reviewed, nothing actionable. That is not the same as a missing status.

## Single Retry

On a not-retrieved outcome, retry **once** with diagnostics and a smaller,
clearer packet:

```zsh
timeout <seconds> claude -p \
  --output-format json \
  --json-schema "$(cat "$ask_dir/schema.json")" \
  --safe-mode --tools "" --no-session-persistence \
  --debug-file "$ask_dir/debug.log" \
  --system-prompt "<same responder instruction>" \
  < "$ask_dir/packet-small.txt" \
  > "$ask_dir/out2.json" 2>> "$ask_dir/err.log"
```

If the retry is still not retrieved, report that the delegated question did not
run and why. Do not keep probing unrelated invocations.

## Workspace Mode (fallback)

Use this only when the packet would be too large or too incomplete to answer
from. Grant read-only tools and keep the same schema. Read tools must be
allowlisted or print mode will auto-deny them.

```zsh
claude -p \
  --output-format json \
  --json-schema "$(cat "$ask_dir/schema.json")" \
  --safe-mode \
  --allowedTools Read Grep Glob \
  --no-session-persistence \
  --system-prompt "You are answering a question from another coding agent. Read only; never edit. Base every claim on the repository. If you cannot determine the scope, set status to unable_to_answer." \
  "<the question, with repo-relative scope>" \
  > "$ask_dir/out.json" 2> "$ask_dir/err.log"
```

Verify the result with the same checks. Prefer read/search tools; avoid `Bash`,
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

Keep raw output in the temporary directory (`$ask_dir` above) or a path that is
already gitignored. Do not commit raw output. Quote shell paths that may contain
spaces, parentheses, or glob characters.
