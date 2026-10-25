---
name: sync-translations
description: >-
  Keep English/Japanese Markdown pairs aligned one to one in content and
  structure across projects.
  Use when editing either file in a .ja.md pair, updating translations, or
  maintaining a private skill's Japanese reading aid.
---

# Sync translations

## Scope

- Maintain existing translation pairs, such as `README.md` and `README.ja.md`,
  including pairs in hidden or ignored directories.
- Keep `SKILL.md` as the canonical source for skill instructions. For private
  skills in parenthesized directories such as `(example)`, create `SKILL.ja.md`
  if missing and synchronize it as a Japanese reading aid.
- For other Markdown files, create Japanese counterparts only when requested.

## Workflow

1. Before editing, locate the counterpart by adding or removing `.ja` before
   `.md`. Read both files in full, including ignored files when needed.
2. Treat the original document as the source of truth. For translation-only
   requests, update the translation without changing the original. When editing
   shared content, apply additions, removals, and corrections to both files in
   the same change, unless the edit is language-specific.
3. Translate the original one to one. Match its heading hierarchy, section
   order, paragraph boundaries, list items and nesting, tables, and code blocks.
   Each heading and content block must have a faithful counterpart in the same
   position. Do not retain outdated translated headings or structure, or split,
   merge, reorder, summarize, or duplicate content. Line wrapping may differ
   for natural Japanese.
4. Include only content present in the original. Do not add introductions,
   translator notes, reading-aid explanations, source-of-truth notices, or
   links to the original unless they are in the original. Remove existing
   translation-only additions during synchronization.
5. Preserve commands, paths, filenames, product names, and checklist meaning.
   Verify that translated links resolve to the intended targets.
6. Compare the complete original and translation block by block, including
   unchanged sections, for omissions, additions, and structural differences.
   Matching heading or list counts alone does not establish translation parity.
   Review the final diff, links, and code fences. Inspect ignored translations
   directly because Git may omit them. Briefly report which translations
   changed or why no update was needed.
