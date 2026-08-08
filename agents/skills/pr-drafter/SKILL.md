---
name: pr-drafter
description: >-
  Use this skill when the user wants a reviewer-ready GitHub pull request body
  that follows the repository PR template, or a concise summary of branch
  changes for reviewers. Apply for informal asks like "write the PR",
  "improve the PR body", or "summarize this branch" even when they do not
  mention templates or GitHub explicitly.
---

# PR Drafter

Build reviewer-ready PR description Markdown from **whatever PR template the repo actually uses** (headings, checklists, HTML comment instructions), then **write it to `.private/pr-drafts/`**, not only in chat. The result should give reviewers enough context to understand the change, evaluate risk, and verify the author's claims without rereading the full diff first.

Follow the **Workflow**, meet the **Quality bar**, apply **Rules for the PR body**, and skim **Common mistakes**.

## Quality bar

A good PR body answers the reviewer's first questions:

- **What changed?** Name the affected feature, behavior, API, command, docs, or files. Avoid vague summaries like "updates docs" when the diff has more specific intent.
- **Why is this change needed?** Explain the problem, missing capability, broken contract, or reviewer-visible outcome. If the reason is inferred from the diff, say it as an inference, not as a fact from an issue.
- **How was it done?** Summarize the implementation shape, not every edited line. Mention important boundaries, constraints, or safety rules.
- **What should reviewers scrutinize?** Call out tricky logic, user-visible behavior, migration risk, compatibility risk, security/privacy implications, or template/checklist decisions when relevant.
- **How was it verified?** List checks actually run and the meaningful result. If no check was run, say `Not run` and give the reason.

## Workflow

### 1. Load `but` skill

GitButler’s CLI and its agent skill are both named **`but`**; resolve the skill by that name.

**MANDATORY**: When available, load and follow the **`but`** skill. If it is missing or you need syntax, use **`but --help`** and **`but <subcommand> --help`**.

```bash
but --help
```

Use **`but`** for workspace state and diffs. **Do not** mutate with `git`; use read-only `git` only to reconcile diff scope with the user’s intent when **`but`** is not enough.

### 2. Confirm PR target

Confirm the **PR head** branch, PR number, or PR URL to draft against. If the user gave one, use it. If not, ask which branch to draft against; do not guess from a busy workspace.

Cross-check with `but status -f` (branches, stacks). If it disagrees with the user, **prefer the user** and mention the mismatch if it matters.

### 3. Resolve template

Resolve explicitly (no fixed layout): **default** `.github/pull_request_template.md`; **else** `.github/PULL_REQUEST_TEMPLATE/*.md`, `docs/`, or a user path; **if none**, ask for path or expected sections. Read end-to-end. **HTML comments** are instructions; if they conflict with generic rules below, **the project wins**.

### 4. Gather facts

Collect commits, changed files, and diffs for the PR head branch.

```bash
but branch show --files <branch-id>  # commits and changed files
but diff --no-tui <branch-id>        # full diff
```

Read focused slices of important files when the diff alone is not enough to understand behavior. Do not rely only on filenames or commit messages for non-trivial changes.

Build a short fact inventory before writing:

- **Scope**: touched files, modules, docs, commands, APIs, or user workflows.
- **Behavior**: what changes for users, maintainers, downstream services, or generated artifacts.
- **Motivation**: issue, bug, missing capability, cleanup goal, or inferred reason.
- **Risk**: compatibility, migrations, performance, security/privacy, rollout, or ambiguity. Use `None obvious from this diff` only when that is defensible.
- **Validation**: commands run, manual checks, screenshots, CI status, or explicit reason checks were not run.
- **Non-goals**: related work intentionally left out when the diff could make reviewers wonder.

### 5. Write reviewer-first content

Using the template from step 3 and the facts from step 4, fill every placeholder. Map scope and type from file paths, commit messages, and the actual diff. Apply **Rules for the PR body**. Only tick checklist items you actually verified.

For common template sections, use this mapping:

- **Summary / What**: reviewer-visible outcome first, then the concrete surfaces changed.
- **Why / Motivation / Context**: the reason the change exists and why the chosen scope is appropriate.
- **Changes / How / Implementation**: the implementation shape, important files, and design constraints.
- **Validation / Testing**: checks actually run and their result; include `Not run` with a reason when applicable.
- **Risks / Rollout / Notes**: likely review concerns, compatibility notes, missing coverage, or follow-up work.

Keep the prose compact but information-dense. Prefer 2-5 bullets per section unless the template asks for prose. Use file paths only when they help reviewers navigate the diff.

### 6. Save and return

Save to **`.private/pr-drafts/YYYY-MM-DD-HHMM-<stem>.md`** (mkdir if needed). `<stem>` = PR head slug (`/` → `-`). Collisions: append `-2`, `-3`, … before `.md`.

Tell the user the saved path and output a paste-ready PR body.

## Rules for the PR body

- **Heading fidelity**: Keep the template’s **`##` / `###` titles and their order** exactly as written. Do not translate, rename, or add sections the template does not define.
- **Template fit**: If the template is minimal (for example `What? / Why? / How?`), still include validation and risk in the best-fitting section instead of dropping them.
- **Reviewer value**: Every section should help a reviewer decide something. Remove filler, restatements of the title, and generic claims like "improves maintainability" unless the diff shows how.
- **Evidence over certainty**: Do not invent issue context, benchmarks, user impact, or test results. If a conclusion is inferred from the diff, phrase it accordingly.
- **Checklists**: If the template includes `- [ ]` lines, **keep every row** unless the template explicitly tells you to drop rows or sections. Leave items **unchecked** when you did not run or verify them; do not tick boxes to “look done.”
- **Placeholders**: Replace issue/PR placeholders such as incomplete `Closes #` or empty `Fixes #` with a real reference when the user confirms one; otherwise **remove the broken line** so GitHub keywords stay valid.
- **Optional sections**: Some templates say to **delete whole sections** when not applicable, such as screenshots. Others want the heading left with “N/A.” **Follow the template comments**, not a global rule.
- **Validation honesty**: List exact commands only when useful. Summarize long output, and do not mark CI, tests, screenshots, or manual QA as done unless they actually happened.
- **Risk honesty**: Mention meaningful uncertainty, omitted checks, migrations, or compatibility concerns. Do not add a risk section if the template forbids extra headings; fold it into the closest section.
- **Deliverable cleanliness**: Strip HTML comments from the **pasted PR body** when they are only agent notes and would clutter the review; keep the structure those comments required.

## Common mistakes

<!-- prettier-ignore -->
| Mistake | Why it hurts |
|:---|:---|
| Inventing headings or reordering the template | Breaks team conventions and review bots. |
| Writing only a changelog | Reviewers still need motivation, risk, and validation context. |
| Repeating the PR title as the summary | Wastes the most important section and hides the actual reviewer-visible outcome. |
| Removing checklist lines to shorten the PR | Violates explicit template rules; reviewers lose signal. |
| Checking verification boxes without evidence | Misleading for CI/review; only check what you or the user confirmed. |
| Saying "tested locally" without commands or scope | Reviewers cannot tell what behavior was exercised. |
| Omitting risk because the change is small | Small changes can still affect contracts, docs consumers, config, or release behavior. |
| Copying a summary from another repo's template shape | Wrong sections, wrong language, or missing required blocks. |
| Asserting a base (“vs `main`”, etc.) in the body that doesn’t match the PR’s actual diff scope | Reviewers see GitHub’s diff; the narrative drifts from what they review. |
| Leaving `Closes #` or similar with no number | Invalid or confusing GitHub linking. |
