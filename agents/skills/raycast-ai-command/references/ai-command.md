# Raycast AI Command Reference

Read this reference when choosing Dynamic Placeholders, suggesting Raycast form
settings, or drafting examples. Official sources:

- https://manual.raycast.com/ai/ai-commands.md
- https://manual.raycast.com/dynamic-placeholders.md

## Contents

- AI Command Form
- AI Command-Safe Dynamic Placeholders
- Modifiers
- Prompt Examples

## AI Command Form

- **Prompt** is the required field and receives the instructions sent to the
  model. Type `{` in Raycast to insert Dynamic Placeholders.
- Type `@` in the prompt when an installed AI Extension should supply context or
  perform an action. Do not invent extension names; ask or use known Raycast
  extension handles only when the user requests them.
- **Name & Icon**, **Model**, **Creativity**, **Reasoning Effort**, **Highlight
  Editing Changes**, **Tags**, and **Organization** are form settings outside
  the Prompt field.
- **Highlight Editing Changes** is useful for commands that rewrite selected
  text in place. The prompt should still return clean replacement text unless
  the user asks for a diff or explanation.

## AI Command-Safe Dynamic Placeholders

Use exact placeholder syntax.

| Need | Placeholder | Notes |
| --- | --- | --- |
| Selected text or focused-field content | `{selection}` | Best default for rewrite, summarize, translate, critique, or explain commands. |
| Runtime input | `{argument}` or `{argument name="Tone"}` | Raycast supports up to three different arguments. Reuse a named argument when the same value appears more than once. |
| Optional/default runtime input | `{argument name="Tone" default="professional"}` | A default makes the argument optional. |
| Runtime choice list | `{argument name="Output" options="bullets, paragraph, checklist"}` | Use for small controlled vocabularies. |
| Clipboard text | `{clipboard}` | Useful when the command should act on copied content instead of selection. |
| Older clipboard item | `{clipboard offset=1}` | Requires Clipboard History. Offset `1` is the second most recent item. |
| Focused browser tab | `{browser-tab}` | Requires the Raycast Browser Extension. Default format is Markdown. |
| Browser tab as text or HTML | `{browser-tab format="text"}` / `{browser-tab format="html"}` | Use text for clean prose extraction; use HTML only when markup matters. |
| Specific browser element | `{browser-tab selector="main"}` | Uses a CSS selector to target part of the page. |
| Calculation result | `{calculator}` | Evaluates a math expression. Use only when the command's input truly is a calculation. |
| Snippet content | `{snippet name="Snippet Name"}` | Inserts a Raycast snippet's content. Referenced snippets cannot reference other snippets. |

Avoid placeholders documented only for Snippets or Quicklinks when generating AI
Command prompts, including `{date}`, `{time}`, `{datetime}`, `{day}`, `{uuid}`,
and `{cursor}`, unless Raycast documentation has been rechecked and now supports
them for AI Commands.

## Modifiers

Modifiers transform placeholder values:

- `{clipboard | trim}`
- `{selection | lowercase}`
- `{argument name="Query" | percent-encode}`
- `{selection | json-stringify}`

Common modifiers: `uppercase`, `lowercase`, `trim`, `percent-encode`,
`json-stringify`, and `raw`. Modifiers can be chained.

Raycast wraps AI Command placeholder values with triple quotes by default to
delimit them for the model. Do not manually add triple quotes around
placeholders unless the user specifically needs literal quotes in the final
prompt. Use `raw` only when the default placeholder wrapping would break the
intended prompt.

## Prompt Examples

### Rewrite Selected Text

```text
Rewrite the selected text to sound clear, concise, and professional while preserving the original meaning.

Selected text:
{selection}

Return only the rewritten text. If the selected text is empty, reply with: Select the text you want me to rewrite.
```

### Summarize Focused Browser Tab

```text
Summarize the focused browser tab for a busy reader.

Page content:
{browser-tab format="markdown"}

Return:
- 3 bullet summary
- Key decisions or claims
- Open questions or follow-ups
```

### Translate With Runtime Language

```text
Translate the selected text into {argument name="Target language" default="English"}.

Selected text:
{selection}

Preserve names, URLs, code, and formatting where possible. Return only the translation.
```

### Draft Reply From Selected Message

```text
Draft a concise reply to the selected message.

Selected message:
{selection}

Use a {argument name="Tone" options="friendly, professional, direct" default="friendly"} tone. Keep it under {argument name="Length" options="1 sentence, 3 sentences, short paragraph" default="3 sentences"}.

Return only the reply text.
```
