# Evals

Two deliberately small sets. They exist to catch regressions in the skill, not
to run an optimization loop.

## Trigger eval

`eval_queries.json` holds 12 queries — 6 that should load the skill, 6
near-misses that should not. The negatives share keywords with the skill
(`review`, `claude`, `Anthropic`, `ask`) but need something else: a local edit,
a config change, or the user's own decision. Those are the cases a too-broad
description gets wrong.

```bash
agents/skills/ask-claude/evals/run_trigger_eval.sh
```

Pass a queries file and a run count to narrow it while iterating:

```bash
agents/skills/ask-claude/evals/run_trigger_eval.sh evals/eval_queries.json 1
```

A query passes when its trigger rate lands on the correct side of 0.5. The set
is intentionally not split into train/validation — at 12 queries the split costs
more signal than the overfitting it prevents. Treat a full pass as a sanity
check, and rewrite the queries before trusting a description that was tuned
against them.

Runs cost real tokens. Only the `Skill` tool is allowed, so a run cannot spawn a
nested `claude -p` or touch files, and it stops at the first tool call.

### What this harness cannot measure

The harness is `claude -p`, but the skill's audience is Codex and Cursor. Two
consequences, both learned by diagnosing failures that looked like description
problems and were not:

- Wording that addresses Claude directly ("ask Claude", "Claude Code's read on
  this") is read by this harness as addressing *itself*, so it answers instead
  of delegating — which is what the skill's own guidance tells Claude Code to
  do. Such queries carry `"audience": "non-claude"` and are skipped. Measuring
  them needs a Codex-side runner.
- Queries that name a concrete file send the run hunting for it, because the
  scratch workspace is empty. Keep code inline in the query, or the result
  measures the missing file rather than the description.

Diagnose a failure before rewriting the description against it. Check the run's
tool calls: no tool call at all means the description lost, while a `Bash` or
`Read` call first usually means the query, not the description, is at fault.

## Behavior eval

`evals.json` holds three cases, graded by reading the run transcript against
each assertion. They target the failure modes that motivate the skill:
reporting an unretrieved run as "no issues", building a packet that omits
untracked files, and applying delegated findings without checking them. Grade a
case as passing only with concrete evidence from the transcript.

Run each case twice — once with the skill, once without — when judging whether a
change to `SKILL.md` earned its tokens. Assertions that pass in both
configurations should be replaced; they measure the model, not the skill.
