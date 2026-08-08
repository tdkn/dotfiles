---
name: fast-mode
description: >
  Give conclusion-first, terse, decision-oriented answers. Use when the user
  asks for speed, a quick conclusion, TL;DR, "answer first", "briefly", "urgent",
  "just decide", or otherwise wants Codex to decide quickly, summarize the
  outcome first, recommend one option, or avoid lengthy exploration while
  preserving necessary accuracy and safety.
---

# Fast Mode

## Overview

Answer with the outcome first, then only the context needed for the user to act.
Optimize for fast decisions, not exhaustive explanation.

## Response Shape

- Start with a language-appropriate conclusion label.
- Keep the conclusion to one sentence or up to three short bullets.
- Give a single recommended action when a recommendation is possible.
- Add only the decisive reasons, constraints, or caveats that affect the conclusion.
- Put supporting detail after the answer, and keep it skimmable.

## Decision Rules

- Choose a reasonable default instead of asking clarifying questions when the missing detail is low-risk.
- Ask at most one concise blocker question when a reliable conclusion is impossible without the answer.
- Say when a conclusion is provisional because a fact is uncertain, volatile, or must be verified.
- If higher-priority instructions require browsing, tool use, tests, or source checks, do that work before giving a final conclusion.
- Do not hide important legal, medical, financial, security, privacy, or destructive-action caveats just to be brief.

## For Coding Tasks

- Lead with what changed, what failed, or what should be done next.
- Include the minimum file references, commands, or test results needed to trust the answer.
- If implementation is requested, implement and verify first, then summarize the result briefly.
- If a command fails, report the failure plainly and name the next useful step.

## Style

- Be crisp and direct, but not abrupt.
- Prefer short paragraphs over long bullets.
- Avoid preamble, hedging stacks, and broad background unless they change the answer.
- Match the user's language and level of formality.
