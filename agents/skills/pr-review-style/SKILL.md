---
name: pr-review-style
description: >-
  Output format and tone for GitHub pull request reviews. Use when writing,
  drafting, or posting a review on a GitHub pull request. Covers the Summary,
  inline comments, courteous wording, the labels [ISSUE] with [P0] to [P3],
  [IMO], [NIT], [ASK], and [BLOCKING], placement, and deduplication. Defines
  format and tone only; review scope, finding criteria, and how the review is
  posted come from elsewhere.
---

# PR Review Style

This skill sets only the format and tone of a GitHub pull request review. It
does not widen or narrow review scope or finding criteria, which come from
repository instructions, the user's request, and the review procedure in use.

A review is a Summary plus inline comments. Labels, placement, and the
first-line format are fixed. Body length and supporting format fit the content.
Write in the language of the PR description and existing reviews, and keep
labels in English.

## Tone

People read these comments, and flat, mechanical wording reads as cold or
rude. Write as a considerate colleague would. Politeness shapes wording only.
It never changes a label, blurs a fact, or hides what must happen before merge.

- Write about the code, not the author: "This loop never exits when ...", not
  "You forgot to ...".
- Phrase requested changes as requests or proposals with a reason, such as
  "Could we ...?" or "How about ...?", not bare commands such as "Fix this."
- Leave out words that blame or belittle, such as "obviously", "clearly",
  "just", "simply", "wrong", or "should have".
- Phrase an `[ASK]` as a genuine question, not a rhetorical one that implies a
  mistake, such as "Why didn't you ...?".
- Use the polite register when the language has one, such as です/ます in
  Japanese.
- State confirmed problems plainly. Hedging a confirmed defect with "might" or
  "maybe" makes it harder to act on, not kinder. Save hedges for real
  uncertainty.
- Keep courtesy short. Long apologies, repeated thanks, and stacked hedges bury
  the point and break the Summary length limit.

## Summary

- Open with one sentence stating the review's overall outcome, taking the
  highest item below that applies. The list gives the meaning, not the
  wording: write "There is one point I'd like you to address before merge.",
  not "Changes required before merge."
  - Changes required before merge. A comment carries `[BLOCKING]`.
  - Verdict on hold. A limit on the review side, which no answer from the
    author can resolve, keeps the verdict from being settled. Next, state what
    the verdict needs, such as "I'll take another look once CI finishes.", not
    what was left undone.
  - Changes recommended but not required before merge. There is an `[ISSUE]`
    without `[BLOCKING]`.
  - Optional comments only. Every comment is `[IMO]`, `[NIT]`, or an `[ASK]`
    without `[BLOCKING]`.
  - No findings. There are no comments.
- A short thanks such as "Thanks for the fix." may lead in and does not count
  toward the sentence limit. Skip praise that is generic or not backed by the
  review.
- After the opening sentence, add only what the author needs to act on the
  review, such as an assumption the findings depend on. Keep the Summary to one
  to three sentences in total, with no habitual headings or bullet lists.
- Do not repeat inline content, titles, counts, categories, or per-file lists.
  Do not list what the PR changes, which checks found nothing, or what the
  review did or did not check, such as tests not run. Report the review's
  verification scope to the user, not in the review.
- Handle points that cannot go inline, such as cross-cutting concerns or
  findings on lines outside the diff, in the Summary without duplicating them
  inline. Give each the same first line as an inline comment and name its file
  and line. They do not count toward the sentence limit.
- Use wording that implies approval, such as "LGTM" or "ready to merge", only
  when the outcome is optional comments only or no findings.

## Inline comments

Each comment makes one point. Its first line is a single bold line of the fixed
labels and the specific point. After a blank line come the evidence, impact,
and fix as needed. A reader must be able to judge and act on the comment
without the Summary or other comments.

### Labels

Use only these labels, spelled exactly as shown.

- `[ISSUE]` is a problem backed by evidence, prefixed with a priority from
  `[P0]` to `[P3]`.
- `[IMO]` is an optional improvement the author may decline.
- `[NIT]` is a very minor preference or polish the author may decline.
- `[ASK]` is a question needed to reach a judgment. It does not assert a
  defect.

### Priority

Only `[ISSUE]` takes a priority.

- `P0` blocks release or operation and needs an immediate fix.
- `P1` has serious impact and needs an early fix.
- `P2` is worth fixing at normal priority.
- `P3` has small impact and can wait.

### Blocking

Append `[BLOCKING]` to an `[ISSUE]` or `[ASK]` that must be resolved before
merge, and explain why in the body. Only `[BLOCKING]` comments must be resolved
before merge. Priority does not decide blocking, except that `P0` is always
`[BLOCKING]`. `[IMO]` and `[NIT]` never take `[BLOCKING]`.

### First line

```markdown
**[P1][ISSUE][BLOCKING] Specific problem or requested change**
**[P2][ISSUE] Specific problem or requested change**
**[ASK][BLOCKING] Question that must be answered before merge**
**[ASK] Question needed to reach a judgment**
**[IMO] Specific improvement**
**[NIT] Very minor adjustment**
```

### Body

- Do not put headings such as "Problem", "Reason", or "Fix" in every comment.
- Use a bullet list for multiple conditions and a code example when it shows
  the change better than prose.
- Say each thing once across prose, bullets, and code.
- Use a `suggestion` block only when replacing the commented lines is the whole
  fix. Put a fix that also needs changes outside the range, or an example that
  only shows the direction, in an ordinary code block.

````markdown
**[P2][ISSUE] `retries` is never decremented, so the loop never ends while the API is down**

`fetchWithRetry` retries until a request succeeds, so while the API is
unreachable the call never returns and the caller never sees the transport
error. Could we decrement it in the loop condition?

```suggestion
  while (retries-- > 0) {
```
````

## Placement and duplicates

- Attach each comment to the diff line that causes the problem, with the
  smallest possible line range. If the cause is outside the diff, comment on a
  diff line that shows it, or else handle the point in the Summary.
- When one cause produces the same problem in several places, comment at one
  representative place and list the others in the body.
- Do not repost a point that an existing review comment or unresolved thread
  already makes.

## Choosing labels

- `[ISSUE]` means the current code has an error, a convention violation, or an
  unmet requirement. If the code is correct and could only be better, use
  `[IMO]`.
- Do not post an unconfirmed defect as `[IMO]`. Use `[ASK]` only when a
  specific question would settle the judgment. Otherwise drop the point.
- A written-convention violation that meets the finding criteria is an
  `[ISSUE]`, not a `[NIT]`, however small the change.
- Do not invent findings to fill every label, and do not treat `[IMO]` or
  `[NIT]` as license to always post optional suggestions or style comments.
  Review scope and finding criteria come first.
