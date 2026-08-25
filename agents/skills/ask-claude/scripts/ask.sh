#!/usr/bin/env bash
# Ask Claude Code one packet-mode question and verify an answer actually came back.
#
#   scripts/ask.sh [--model <model>] [--effort <level>] [--timeout <seconds>] < packet.txt
#
# Reads the packet on stdin. Prints the structured answer object and exits 0 when
# the answer is retrieved; otherwise prints a one-line diagnosis on stderr and
# exits 1. The caller decides whether to retry once with a smaller packet — that
# needs judgment about what to cut, so this script never retries on its own.
#
# The invocation and the checks are the ones described in
# references/claude-cli.md. Read that file before changing anything here.

set -u

# Pinned rather than inherited: the reasoning is the deliverable here, and the
# CLI default drifts — when it happens to match the caller's own model, a second
# opinion silently becomes an echo. Override per call for routine questions.
model="claude-opus-5"
effort="max"
timeout_secs=300

while [ $# -gt 0 ]; do
  case "$1" in
    --model) model=${2:?--model needs a value}; shift 2 ;;
    --effort) effort=${2:?--effort needs a value}; shift 2 ;;
    --timeout) timeout_secs=${2:?--timeout needs a value}; shift 2 ;;
    *) printf 'unknown argument: %s\n' "$1" >&2; exit 2 ;;
  esac
done

command -v claude >/dev/null || { echo "claude not found on PATH" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq not found on PATH" >&2; exit 1; }

dir=$(mktemp -d "${TMPDIR:-/tmp}/claude-ask.XXXXXX")
trap 'rm -rf "$dir"' EXIT
cat > "$dir/packet.txt"

cat > "$dir/schema.json" <<'SCHEMA'
{
  "type": "object",
  "properties": {
    "status": { "type": "string", "enum": ["answered", "unable_to_answer"] },
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
SCHEMA

system_prompt="You are answering a question from another coding agent. You have only this packet and no tools. Do not request tool use. Base every claim on the packet. Do not propose edits unless the packet asks for them. If the packet is insufficient to answer, set status to unable_to_answer and say what is missing in summary."

runner=()
if command -v timeout >/dev/null; then
  runner=(timeout "$timeout_secs")
elif command -v gtimeout >/dev/null; then
  runner=(gtimeout "$timeout_secs")
fi

args=(-p
  --output-format json
  --json-schema "$(cat "$dir/schema.json")"
  --safe-mode
  --tools ""
  --no-session-persistence
  --system-prompt "$system_prompt")
[ -n "$model" ] && args+=(--model "$model")
[ -n "$effort" ] && args+=(--effort "$effort")

"${runner[@]}" claude "${args[@]}" < "$dir/packet.txt" > "$dir/out.json" 2> "$dir/err.log"
status=$?

fail() {
  printf 'NOT RETRIEVED: %s\n' "$1" >&2
  [ -s "$dir/err.log" ] && tail -n 3 "$dir/err.log" >&2
  exit 1
}

[ $status -eq 0 ] || fail "claude exited $status"
jq -e '.is_error == false and .subtype == "success"' "$dir/out.json" >/dev/null 2>&1 \
  || fail "run did not succeed (is_error/subtype)"

answer_status=$(jq -r '.structured_output.status // "missing"' "$dir/out.json")
case "$answer_status" in
  answered)
    jq -e '(.structured_output.answer | length) > 0' "$dir/out.json" >/dev/null \
      || fail "answered status but empty answer"
    ;;
  unable_to_answer) fail "responder could not answer from the packet: $(jq -r '.structured_output.summary // ""' "$dir/out.json")" ;;
  *) fail "no valid structured status in the envelope" ;;
esac

# A blocked tool means the responder wanted context the packet lacked.
denied=$(jq -r '(.permission_denials // []) | length' "$dir/out.json")
[ "$denied" -gt 0 ] && printf 'warning: %s blocked tool call(s); the answer may be degraded\n' "$denied" >&2

jq '.structured_output' "$dir/out.json"
