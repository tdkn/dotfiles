#!/usr/bin/env bash
# Trigger eval for this skill: does the description fire on the right prompts?
#
#   evals/run_trigger_eval.sh [queries.json] [runs]
#
# Each run allows only the Skill tool, so the eval never spawns a nested paid
# `claude -p` and never edits files, and it stops at the first tool call, which
# keeps a run to roughly one turn. Still, this costs real tokens: 12 queries x 3
# runs is 36 invocations. Start with `runs=1` while iterating on wording.
#
# The skill is linked into a scratch workspace so the eval works before mise has
# deployed it. User-scope skills load too — that is the real triggering
# condition, not a flaw.

set -u

skill_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
skill_name=$(basename "$skill_dir")
queries=${1:-"$skill_dir/evals/eval_queries.json"}
runs=${2:-3}

ws=$(mktemp -d "${TMPDIR:-/tmp}/${skill_name}-eval.XXXXXX")
trap 'rm -rf "$ws"' EXIT
mkdir -p "$ws/.claude/skills"
ln -s "$skill_dir" "$ws/.claude/skills/$skill_name"

# Echoes "<tool>:<skill>" for the first tool call of the run, or nothing.
# `head -n 1` closes the pipe, which ends the run early.
first_tool_call() {
  (cd "$ws" && claude -p "$1" \
    --output-format stream-json --verbose \
    --allowedTools Skill \
    --no-session-persistence 2>/dev/null) \
    | jq -r --unbuffered 'select(.type == "assistant")
        | .message.content[]?
        | select(.type == "tool_use")
        | "\(.name):\(.input.skill // "")"' \
    | head -n 1
}

total=$(jq length "$queries")
passed=0
measured=0

for i in $(seq 0 $((total - 1))); do
  query=$(jq -r ".[$i].query" "$queries")
  want=$(jq -r ".[$i].should_trigger" "$queries")
  hits=0

  # Some queries only make sense from a non-Claude caller. Phrases like "ask
  # Claude" address the harness itself here, so the run answers directly and the
  # result says nothing about the description.
  if [ "$(jq -r ".[$i].audience // \"any\"" "$queries")" = "non-claude" ]; then
    printf 'SKIP  not measurable through claude -p     %s\n' "$query"
    continue
  fi
  measured=$((measured + 1))

  for _ in $(seq 1 "$runs"); do
    [ "$(first_tool_call "$query")" = "Skill:$skill_name" ] && hits=$((hits + 1))
  done

  rate=$(awk -v h="$hits" -v r="$runs" 'BEGIN { printf "%.2f", h / r }')
  result=$(awk -v rate="$rate" -v want="$want" 'BEGIN {
    print ((want == "true" && rate > 0.5) || (want == "false" && rate < 0.5)) ? "PASS" : "FAIL"
  }')
  [ "$result" = "PASS" ] && passed=$((passed + 1))

  # Printed whole: truncating here would cut multibyte queries mid-character.
  printf '%s  rate=%s  want=%-5s  %s\n' "$result" "$rate" "$want" "$query"
done

printf '\n%d/%d measured queries passed (%d runs each, %d skipped)\n' \
  "$passed" "$measured" "$runs" "$((total - measured))"
