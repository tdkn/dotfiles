---
name: raycast-ai-command
description: >-
  Use this skill when the user wants to create, improve, or troubleshoot a
  paste-ready prompt for a Raycast AI Command, especially one that uses Dynamic
  Placeholders such as {selection}, {argument}, {clipboard}, or {browser-tab}.
  Apply for vague requests like "make a Raycast command that..." and ask
  targeted questions when missing details would materially reduce prompt
  quality.
---

# Raycast AI Command

## Overview

Create concise, reliable prompts for Raycast AI Commands. The primary
deliverable is an English prompt that the user can paste into the **Prompt**
field of Raycast's Create AI Command form.

Keep the skill lightweight: use this file for the workflow and read
`references/ai-command.md` only when placeholder syntax,
Raycast settings, or examples are needed.

## Workflow

1. Clarify the command's job.
   - Identify the input source: selected text, clipboard, focused browser tab,
     runtime arguments, or AI Extension output.
   - Identify the transformation, audience, tone, language, and expected output
     shape.
   - Ask up to three focused questions when the request is too ambiguous to
     produce a durable command. If a reasonable default is obvious, proceed and
     state the assumption briefly.

2. Choose Raycast context deliberately.
   - Prefer `{selection}` for commands that operate on highlighted text.
   - Use `{argument name="..."}` for values the user should provide at runtime;
     keep to Raycast's maximum of three different arguments.
   - Use `{browser-tab}` only when the command should read the focused browser
     tab and the Browser Extension requirement is acceptable.
   - Read `references/ai-command.md` before using less common
     placeholders, modifiers, browser-tab selectors, or AI Extension patterns.

3. Draft the Raycast prompt in English.
   - Make it self-contained; it should still work weeks later without this
     conversation.
   - Name the input source explicitly before the placeholder.
   - Include only constraints that improve repeatable behavior: scope, tone,
     output format, preservation rules, and fallback behavior.
   - For in-place rewrite commands, usually request only the final replacement
     text so Raycast can paste or apply it cleanly.

4. Return a copy-friendly result.
   - Put the prompt first, in a plain text code block.
   - Add optional Raycast form suggestions only when useful: command name,
     placeholder choices, model/creativity notes, tags, or whether to enable
     Highlight Editing Changes.
   - Keep explanations outside the prompt short and in the conversation
     language; keep the prompt itself in English.

## Prompt Shape

Use this shape as a default, then trim unnecessary parts:

```text
You are [role].

Use the following [input source]:
{selection}

Task:
- [specific transformation]
- [important constraints]
- [output format]

If the input is empty or unusable, reply with one concise sentence explaining what input is needed.
```

Adapt the placeholder and labels to the user's command. Remove the role line
when it adds no useful behavior.

## Quality Checklist

- The generated Raycast prompt is in English.
- The prompt is paste-ready for the Raycast **Prompt** field.
- Dynamic Placeholders are valid for AI Commands and use exact Raycast syntax.
- The prompt avoids hidden assumptions about selected text, clipboard contents,
  browser access, or installed AI Extensions.
- Runtime arguments have clear names, defaults/options when helpful, and do not
  exceed three distinct arguments.
- The prompt asks for output that matches the command's real use: replacement
  text for edits, bullets for summaries, JSON only when the user needs JSON, and
  no extra commentary when the result will be pasted into another app.

## References

- `references/ai-command.md`: Raycast AI Command form facts,
  AI Command-safe Dynamic Placeholders, modifiers, and compact prompt examples.
