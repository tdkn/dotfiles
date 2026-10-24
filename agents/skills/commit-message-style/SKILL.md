---
name: commit-message-style
description: >-
  Write or revise commit messages using Conventional Commits and a structured
  body. Use when creating a commit, drafting a commit message, or amending
  or rewording an existing message.
---

# Commit message style

- Follow Conventional Commits.
- Follow the repository's existing language and conventions for commit messages.

## Body

Include a commit body using this template. Fill the relevant sections and remove
unnecessary sections, including their headings.

```markdown
## Why

## What changed

## Testing
```

## Commit attribution

### Codex

- Include a `Co-authored-by: Codex (<model-id>) <noreply@openai.com>` trailer
  in commit messages, replacing `<model-id>` with the exact active model identifier
  explicitly provided by the runtime for the current turn, e.g.
  `Co-authored-by: Codex (gpt-6.1-sol) <noreply@openai.com>`.
- Never guess the model identifier or infer it from configuration defaults,
  available model lists, previous turns, or existing commits. If it is unavailable,
  use `Co-authored-by: Codex <noreply@openai.com>` without asking the user.

### Claude Code

Leave commit attribution to Claude Code's built-in `attribution` setting.
