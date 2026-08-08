---
name: maintain-translations
description: Maintain this repository's English/Japanese documentation pairs and translation-sensitive catalog entries. Use when working in tdkn/agent-skills on README.md, README.ja.md, any *.md file with a *.ja.md counterpart, adding or materially changing skills under skills/, editing AGENTS.md or public docs, or when the user mentions ja.md, Japanese docs, translations, localization, or mirrored documentation.
metadata:
  internal: true
---

# Maintain Translations

## Overview

Keep Japanese translation files and English source documentation aligned as part of the same change. Treat public `*.ja.md` updates as required deliverables, not optional cleanup.

## Translation Contract

- Maintain information parity between English docs and their Japanese counterparts.
- Preserve the target document's established structure and tone when it intentionally differs from the English source.
- Translate meaning, links, command names, paths, and checklist semantics accurately; do not add placeholder translation text.
- Keep `skills/<skill-name>/SKILL.md` as the English source of truth. `SKILL.ja.md` files are ignored local verification aids, not published skill files; do not create them by default or treat them as required PR deliverables.
- Treat `.agents/skills/` as local agent guidance. Do not add local-only skills to the public README skill catalog unless the user asks.

## Workflow

1. Detect translation pairs before editing:
   - List Markdown files with `rg --files -g '*.md'`.
   - For each English source, check for a sibling Japanese file by inserting `.ja` before `.md`, such as `README.md` -> `README.ja.md`.
   - For each touched `*.ja.md`, inspect the corresponding English source by removing `.ja`.

2. Classify the requested change:
   - If `README.md` changes, update `README.ja.md` in the same turn.
   - If `README.ja.md` changes, inspect `README.md` and keep the two documents semantically aligned.
   - If a public skill is added, renamed, removed, or materially changed under `skills/`, update both README skill listings.
   - If a changed public skill already has a local `SKILL.ja.md`, use it as local verification context when helpful, but do not treat it as a published translation or required PR artifact.
   - If another Markdown file has a `*.ja.md` counterpart, update both files unless the change is language-specific.
   - If a Markdown source has no Japanese counterpart, decide whether a counterpart should exist based on the document's public/user-facing role.

3. Edit with translation integrity:
   - Keep links, paths, command examples, filenames, and product names copy-paste accurate.
   - Mirror added, removed, or reordered information even when the Japanese file uses prose instead of the English table layout.
   - Preserve Japanese headings already used in `README.ja.md` unless a source change makes a heading stale.
   - Avoid broad rewrites that make review harder unless the user requested a translation refresh.

4. Verify before finishing:
   - Review the diff and confirm every changed English Markdown file has a handled Japanese counterpart or a clear reason no counterpart is needed.
   - Confirm every changed `*.ja.md` file still matches the English source's current facts.
   - For skill catalog changes, confirm both `README.md` and `README.ja.md` mention the same public skills and valid links.
   - State in the final response which translation files were updated, or why no translation update was needed.

## Repository-Specific Rules

- Public catalog source: `skills/<skill-name>/SKILL.md`
- Local skill verification aid: `skills/<skill-name>/SKILL.ja.md` when already present and ignored by git
- Published English catalog: `README.md`
- Published Japanese catalog: `README.ja.md`
- Local agent-only skills: `.agents/skills/<skill-name>/SKILL.md`

When changing a public skill under `skills/`, do not stop after editing `README.md`. Update `README.ja.md` in the same change and use Japanese descriptions that reflect the updated behavior.

If a public skill has an existing `SKILL.ja.md`, remember that it is local-only and ignored by git. Inspect it directly with `rg --files -g '*.ja.md'` when local Japanese wording helps, but do not rely on `git status` or PR diffs to show it.

When changing local repo guidance under `.agents/skills/`, keep the skill body in English and skip README catalog updates unless the user explicitly wants the local guidance documented publicly.

## Final Check Prompts

Before responding, ask:

- Did this change touch English docs, Japanese docs, or public skill metadata?
- Did I update the counterpart translation file in this same turn?
- If I skipped a translation update, is the reason concrete and safe to tell the user?
- Did I avoid confusing `.agents/skills/` local guidance with published `skills/` catalog entries?
