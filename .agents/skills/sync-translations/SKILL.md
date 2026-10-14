---
name: sync-translations
description: >-
  Keep English/Japanese Markdown pairs in this dotfiles repository aligned.
  Use when editing either file in a .ja.md pair, updating translations, or
  maintaining a private skill's Japanese reading aid.
metadata:
  internal: true
---

# Sync translations

## Scope

- Maintain existing translation pairs, such as `README.md` and `README.ja.md`,
  including pairs in hidden or ignored directories.
- Keep `SKILL.md` as the canonical source for skill instructions. For private
  skills in parenthesized directories such as `(example)`, create `SKILL.ja.md`
  if missing and synchronize it as a Japanese reading aid.
- For other Markdown files, create Japanese counterparts only when requested.
- `.agents/skills/` holds repository guidance; `agents/skills/` holds locally
  authored skills linked into global skill directories. Skill edits alone do
  not require README updates.

## Workflow

1. Before editing, locate the counterpart by adding or removing `.ja` before
   `.md`. Inspect ignored directories directly when needed.
2. Read both files and apply semantic additions, removals, and corrections to
   both in the same change, unless the edit is language-specific. Preserve the
   Japanese document's established structure, headings, and tone where they
   intentionally differ from the English source.
3. Keep commands, paths, filenames, product names, and checklist meaning
   accurate. Verify that translated links resolve to the intended targets.
4. Review the final diff for information parity, valid links, and balanced code
   fences. Inspect ignored translations directly because Git may omit them.
   Briefly report which translations changed or why no update was needed.
