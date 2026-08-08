# Claude CLI Reference

Use this reference when delegating a code review to Claude Code (`claude`).

Core principle: **a run that exits 0 is not proof of a review.** Treat the review
as retrieved only when the CLI returns a valid, schema-conforming structured
result with an explicit verdict. An empty, malformed, or `unable_to_review`
result means the review was **not retrieved** — never report it as "no issues".

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
- `--tools ""`: disable all built-in tools for a self-contained packet review.
- `--allowedTools <names...>`: allowlist specific tools (comma/space separated),
  e.g. `Read Grep Glob` for a read-only workspace review.
- `--safe-mode`: disable CLAUDE.md, skills, plugins, hooks, MCP, custom
  commands/agents, themes, and keybindings. Auth, model, built-in tools, and
  permissions still work normally.
- `--no-session-persistence`: do not save the session to disk (needs `--print`).
- `--system-prompt <prompt>`: replace the default system prompt.
- `--model <model>`: pin the reviewer model (see the cost note below).
- `--debug-file <path>`: write debug logs to a file (used on the single retry).

Do **not** use `--bare` for this: it forces `ANTHROPIC_API_KEY`/apiKeyHelper auth
and never reads OAuth or the keychain, so it breaks subscription/OAuth users.
`--safe-mode` gives the same clean, uncontaminated reviewer while leaving auth
intact.

Why `--safe-mode` matters here: without it, the delegated reviewer loads the
host's `CLAUDE.md`, skills, and hooks. Personal instructions (answer language,
formatting rules, commit conventions) can reshape the review text and fight the
JSON schema. `--safe-mode` yields a deterministic, uncontaminated review.

Do **not** use `--permission-mode plan` for a packet review. In print mode, plan
mode routes the deliverable through the `ExitPlanMode` tool; with `--tools ""`
that tool is disabled, so a real review prompt can exit 0 with empty or degraded
output. Omit it entirely for packet mode.

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

## Structured Review Contract

Ask the reviewer for a structured result so success can be verified mechanically.
Use this schema (store it in a file to pass it cleanly):

```json
{
  "type": "object",
  "properties": {
    "verdict": {
      "type": "string",
      "enum": ["sound", "findings", "unable_to_review"]
    },
    "summary": { "type": "string" },
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
    }
  },
  "required": ["verdict", "summary", "findings"]
}
```

Verdict meaning:

- `sound`: reviewed successfully, no actionable findings. `findings` is empty.
- `findings`: reviewed successfully, `findings` is non-empty.
- `unable_to_review`: the packet or context was insufficient. This is a
  **not-retrieved** outcome, not a clean bill of health.

## Packet Review (default)

Build a self-contained packet (scope + relevant diff and file excerpts) and pass
it on stdin. Disable tools so the reviewer works only from the packet. Wrap with
`timeout`/`gtimeout` when available; otherwise poll and terminate only the stuck
`claude -p` command.

```zsh
review_dir=$(mktemp -d "${TMPDIR:-/tmp}/claude-review.XXXXXX")
# write the schema above to "$review_dir/schema.json"
# write the self-contained packet to "$review_dir/packet.txt"

timeout <seconds> claude -p \
  --output-format json \
  --json-schema "$(cat "$review_dir/schema.json")" \
  --safe-mode \
  --tools "" \
  --no-session-persistence \
  --system-prompt "You are a code reviewer. You have only this packet and no tools. Do not request tool use. Base every finding on the packet. If the packet is insufficient to review, set verdict to unable_to_review and say what is missing in summary." \
  < "$review_dir/packet.txt" \
  > "$review_dir/out.json" 2> "$review_dir/err.log"
```

Start the packet body with: `You have no tools. Use only this packet. Do not
request tool use.` Frame diffs clearly (label added/removed lines) so a leading
`+`/`-` is not mistaken for source.

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

The review is retrieved only if **all** of these hold. Otherwise report it as
not retrieved — do not present local analysis as delegated feedback.

```zsh
out="$review_dir/out.json"

# 1. Shell exit code was 0 (check right after the command).
# 2. The run itself succeeded.
jq -e '.is_error == false and .subtype == "success"' "$out" >/dev/null

# 3. Read the verdict from the parsed structured object (not from `.result`).
verdict=$(jq -r '.structured_output.verdict // "missing"' "$out")

case "$verdict" in
  sound)    echo "reviewed: no actionable findings" ;;
  findings) jq -e '(.structured_output.findings | length) > 0' "$out" >/dev/null \
              && echo "reviewed: findings present" \
              || echo "NOT retrieved: findings verdict but empty list" ;;
  unable_to_review) echo "NOT retrieved: reviewer could not review the packet" ;;
  *)        echo "NOT retrieved: no valid structured verdict" ;;
esac
```

Notes:

- Read `structured_output` (the parsed object), not `.result` (a stringified
  duplicate).
- Do **not** gate on `stop_reason`. With `--json-schema` the result is delivered
  via a synthetic tool call, so `stop_reason` is `tool_use` even on success.
- `permission_denials` in the envelope is a useful signal: a non-empty array
  means the reviewer tried a blocked tool, so the review may be degraded.

## Single Retry

On a not-retrieved outcome, retry **once** with diagnostics and a smaller,
clearer packet:

```zsh
timeout <seconds> claude -p \
  --output-format json \
  --json-schema "$(cat "$review_dir/schema.json")" \
  --safe-mode --tools "" --no-session-persistence \
  --debug-file "$review_dir/debug.log" \
  --system-prompt "<same reviewer instruction>" \
  < "$review_dir/packet-small.txt" \
  > "$review_dir/out2.json" 2>> "$review_dir/err.log"
```

If the retry is still not retrieved, report that the delegated review did not
run and why. Do not keep probing unrelated invocations.

## Workspace Review (fallback)

Use this only when the packet would be too large or incomplete. Grant read-only
tools and keep the same schema. Read tools must be allowlisted or print mode will
auto-deny them.

```zsh
claude -p \
  --output-format json \
  --json-schema "$(cat "$review_dir/schema.json")" \
  --safe-mode \
  --allowedTools Read Grep Glob \
  --no-session-persistence \
  --system-prompt "You are a code reviewer. Read only; never edit. Base findings on the repository. If you cannot determine the scope, set verdict to unable_to_review." \
  "Review the current working-tree and branch changes against the base branch. Return only the structured verdict." \
  > "$review_dir/out.json" 2> "$review_dir/err.log"
```

Verify the result with the same checks. Prefer read/search tools; avoid `Bash`,
which can trigger approval loops inside the delegated session.

## Cost

The nested `claude -p` inherits the default model, which may be a large model.
For routine reviews, pin a cheaper/faster model with `--model` when appropriate,
and keep the packet tight. `--effort` is not set here: a review is the whole
value, so do not force it to `low`.

## ultrareview (optional, paid)

`claude ultrareview [target]` runs a cloud-hosted multi-agent review of the
current branch (or a PR number / base branch). It sends the branch to the cloud
and incurs cost, so treat it as an explicit, user-approved supplement — not the
default mode of this skill. Do not run it without approval.

## Capturing Output

Keep raw reviewer output in the temporary directory (`$review_dir` above) or a
path that is already gitignored. Do not commit raw output. Quote shell paths that
may contain spaces, parentheses, or glob characters.
