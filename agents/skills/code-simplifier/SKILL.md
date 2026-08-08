---
name: code-simplifier
description: Use when simplifying, refactoring, or reviewing code for clarity, consistency, maintainability, reduced complexity, duplicate removal, or behavior-preserving cleanup in local changes, branch diffs, selected files, or another author's PR.
---

# Code Simplifier

## Overview

Improve code clarity and maintainability without changing behavior. Prefer
boring, explicit code that fits the project over clever compression or broad
refactors.

Use this skill in two modes:

- **Edit mode**: apply behavior-preserving simplifications to code you are
  allowed to change.
- **Review mode**: identify simplification opportunities in a diff, PR, or
  selected files and report them as actionable review feedback unless the user
  explicitly asks for edits.

## Scope

1. Define the review or edit target: working tree changes, branch diff, PR diff,
   selected files, or a specific concern.
2. Read nearby code and project guidance before changing or judging style:
   `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, formatter/linter config, and
   established patterns in adjacent modules.
3. Keep the scope narrow. Do not use simplification as a reason to redesign
   unrelated modules, rename public APIs, reformat whole files, or change
   behavior outside the target.
4. For another author's PR, preserve author intent and review etiquette: propose
   small, justified improvements; do not turn style preference into blocking
   feedback unless it creates real maintenance risk.

## Simplification Rules

Apply these only when they improve readability or reduce real complexity:

- Flatten unnecessary nesting with early returns, guard clauses, or extracted
  helpers.
- Remove duplicate logic when the duplicate code represents the same concept.
- Delete dead code, unused variables, redundant branches, and comments that only
  narrate obvious code.
- Rename variables or helpers when the new name makes intent clearer.
- Replace dense expressions, nested ternaries, or clever one-liners with clear
  `if`/`else`, `switch`, or named intermediate values.
- Inline abstractions that hide simple logic without adding meaning.
- Keep useful abstractions that separate concerns, encode domain language, or
  make testing and debugging easier.
- Preserve error handling, concurrency, security, privacy, accessibility, and
  performance constraints unless the user asks to change them.

## Workflow

1. Establish a behavior baseline.
   - Identify tests, snapshots, type checks, linters, or manual reproduction
     steps that cover the target.
   - If no verification exists, inspect call sites and document the residual
     risk before editing or reviewing.

2. Find simplification candidates.
   - Look for accidental complexity: repeated branches, temporary abstractions,
     overly broad functions, mixed concerns, and local inconsistency.
   - Prefer the smallest change that removes the complexity.

3. Apply or report improvements.
   - In edit mode, make focused edits and keep unrelated formatting churn out of
     the diff.
   - In review mode, lead with concrete findings that include file/line
     anchors, the maintenance risk, and a suggested simpler shape.

4. Verify behavior preservation.
   - Run the narrowest meaningful checks first, then broader checks when the
     change touches shared behavior.
   - Compare before/after behavior when tests are missing or weak.
   - If verification cannot run, say exactly what was not verified and why.

5. Summarize only meaningful changes.
   - Explain what became simpler and how behavior was preserved.
   - Avoid narrating cosmetic edits that are obvious from the diff.

## Review Feedback Shape

For PR or code review use:

```markdown
[P2] Simplify duplicated validation branches

The two branches now perform the same normalization before returning. Extracting
that normalization once would reduce the chance of future behavior drift while
keeping the existing validation order unchanged.
```

Good simplification feedback is specific, behavior-preserving, and tied to a
maintainability risk. Avoid broad comments like "clean this up" without showing
what should change and why it matters.

## Common Mistakes

| Mistake | Better approach |
| --- | --- |
| Chasing fewer lines | Prefer code that is easier to read, test, and debug. |
| Flattening all abstractions | Keep abstractions that carry domain meaning or isolate concerns. |
| Mixing cleanup with feature work | Separate behavior changes from simplification unless explicitly requested. |
| Ignoring project guidance | Let local `AGENTS.md` and adjacent patterns decide style. |
| Blocking on preference in someone else's PR | Mark preference-level ideas as optional unless they reduce real risk. |
