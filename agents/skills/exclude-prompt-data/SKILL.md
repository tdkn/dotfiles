---
name: exclude-prompt-data
description: >
  Write only the resulting content into the artifact. Use when creating or
  editing any file, code comment, document, commit message, or pull request
  body produced from a prompt, and when reviewing a diff for leaked
  instruction text. Strips meta-commentary such as "as requested", comments
  that narrate a change, restated requirements, scaffold labels, and real
  names, emails, hostnames, or paths carried over from the prompt or the local
  environment.
---

# Exclude Prompt Data

## Overview

A prompt supplies instruction and context. The artifact produced from it must
contain only the result. Nothing in the output should reveal that a prompt
existed, how it was phrased, or that it was carried out.

## Core Rule

> Never echo prompt content into the artifact being changed.

Write the outcome. Drop the framing, rationale, and acknowledgment that arrived
with the request.

## Scope

Applies to every artifact an agent authors or edits:

- Source files and code comments
- Documentation, README files, and inline docs
- Configuration, schemas, and fixtures
- Commit messages, pull request bodies, and issue comments
- Generated or scaffolded files

Chat responses are out of scope. Explaining a change to the user is expected;
writing that explanation into the artifact is not.

## What Counts As Prompt Data

- Descriptions of what to add or change (`add a --verbose flag that ...`)
- Rationale or motivation for the request
  (`because the old behavior caused ...`)
- References to the prompt (`as requested`, `per the prompt`, `as you asked`)
- Meta-commentary about the edit (`This section has been updated to reflect ...`)
- Comments that narrate a change instead of describing the code
  (`// Added email validation as requested`)
- Scaffold labels used as template slots — in `## this Title`, `this` is
  scaffolding, not heading text
- Session and environment detail: agent names, tool output, local usernames,
  hostnames, absolute paths, real addresses, or organization identifiers

## What Belongs In The Output

- The feature, fix, or content requested, written as if it always belonged
  there
- Comments and docs that describe behavior, constraints, invariants, or intent
- Cliche placeholder data in examples (`Jane Doe`, `jane.doe@example.com`,
  `Acme Corp`, `example.com`) in place of real values taken from the prompt or
  local configuration
- The formatting conventions the prompt used for terms — when the prompt wraps
  a term in backticks or follows a syntax convention, carry that through

## Output Quality

The prompt's writing quality does not set the bar. However the request was
phrased, the result must be production-ready: correct grammar, capitalization,
and punctuation, with no draft-quality prose. Informal or sloppy phrasing in
the prompt must not carry into the artifact.

## Examples

### Documentation

Prompt: `Add a --new-opt <argument> flag to the CLI and document it in features.md`

Write:

```markdown
### --new-opt

Enables extended output. Requires a value argument.

    cli --new-opt foo
```

Not:

```markdown
### --new-opt

The new feature `--new-opt` requiring an argument has now been added as
requested, and is documented as such.

Enables extended output. Requires a value argument.

    cli --new-opt foo
```

The rejected version echoes the prompt's framing. That language belongs in the
conversation, not the file.

### Code

Prompt: `Add input validation to createUser — email must be a valid format.`

Write:

```js
function createUser(name, email) {
  // Rejects addresses missing a local part, @ sign, or domain
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new Error('Invalid email address.');
  }
}
```

Not:

```js
// Added email validation as requested in the prompt
function createUser(name, email) {
  // Per the instruction, we now validate that email must be a valid format
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new Error('Invalid email address.');
  }
}
```

Comments are encouraged when they describe what the code does or why a
constraint exists. They must never narrate the change or report back to the
requester.

### Commit Message

Prompt: `The retry loop spins forever when the API is down — please cap it.`

Write:

```text
fix(client): cap request retries at five attempts

An unbounded retry loop kept requests alive indefinitely while the API was
unreachable. Attempts are now capped and the last transport error is returned
to the caller.
```

Not:

```text
fix(client): cap request retries as requested

Per the request, the retry loop that spins forever has been fixed.
```

A commit message describes the change and its reason in the codebase's terms,
never the conversation that led to it.

## Exceptions

Treat these as exceptions, not loopholes:

- **Verbatim transcription requested.** The user asks for prompt text to be
  inserted as-is. Insert exactly that and nothing more.
- **The artifact is itself a prompt or instruction file.** Skill definitions,
  agent instruction files, and prompt templates take instructional content as
  their payload. The rule still applies one level up: do not add
  meta-commentary about the current edit into them.
- **Changelog and release-note entries.** A short factual line about the change
  is appropriate (`Added --verbose flag`, not
  `Added --verbose flag as requested`).

## Self-Check Before Saving

Scan the diff and remove what you find:

- Phrases such as `as requested`, `per the prompt`, `per your instruction`,
  `as you asked`
- Sentences that announce a change rather than describe the subject
  (`This section now covers ...`, `Updated to include ...`)
- Comments explaining why an edit was made instead of what the code does
- Restatement of the request inside the artifact
- Any acknowledgment that a prompt exists
- Real names, addresses, hostnames, absolute paths, or credentials carried in
  from the prompt or the local environment

Rewrite whatever trips the check so a fresh reader with no knowledge of the
prompt finds the content natural and self-contained.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Output contains `as requested` or `per the prompt` | Delete the phrase |
| Docs announce a change instead of documenting the subject | Rewrite as a direct description |
| Comments narrate the edit | Describe the code's behavior or constraint |
| Scaffold labels appear in headings | Replace with the real heading text |
| Example data names a real person, host, or path | Substitute a generic placeholder |

## Summary

Write the result, not the story of how you got there. A reader of the artifact
should see clean, self-contained content with no trace of the prompt that
produced it.
