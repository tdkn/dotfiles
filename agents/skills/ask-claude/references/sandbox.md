# Sandbox Boundary and Escalation

Read this before any Claude CLI preflight or invocation, even when no sandbox
failure has been identified. A sandbox can return a plausible auth result such
as `loggedIn: false` when it cannot read the host credential store.

Core rule: **a sandbox-local negative is not host-auth evidence.** Change the
execution boundary before concluding that the CLI or authentication is missing.

## Outcome Labels

These are reasons for the caller's not-retrieved report, not fields added to the
Claude structured-answer schema.

| Reason | Conclusive evidence | Required action |
| --- | --- | --- |
| `cli_missing` | Host/native `command -v claude` cannot resolve the CLI. | Stop and report it; do not install the CLI. A sandbox-only lookup is inconclusive. |
| `auth_missing` | Host/native `claude auth status` explicitly reports unauthenticated. | Stop and report it; do not start login. |
| `sandbox_auth_unverified` | Sandbox auth is negative/failed and the host check is unavailable or denied. | Report not retrieved without claiming the user is logged out. |
| `sandbox_blocked` | Permission, DNS, credential-store, or temp-file access prevents preflight or invocation. | Move the unchanged command to a narrowly approved host boundary. |
| `response_invalid` | Claude ran, but output is empty, malformed, or does not match the structured-answer schema. | Use the one normal response retry from `claude-cli.md`. |

`unable_to_answer` is a schema-valid but not-retrieved response. It uses the
same normal response-retry path, but it is not `response_invalid`.

## Verify Authentication Across the Boundary

Resolve CLI availability first. If only the sandbox cannot resolve
`command -v claude`, run that exact lookup at the host boundary. A host failure
is `cli_missing`; an unavailable or denied host lookup is `sandbox_blocked`.

1. Do not label a sandbox `loggedIn: false`, failed auth command, or denied
   credential-store read as `auth_missing`. Authentication is unknown at that
   boundary.
2. Use the host's native escalation mechanism to run exactly:

   ```zsh
   claude auth status
   ```

   Request only execution of the installed CLI and read access to its existing
   credential store. This check needs no packet, prompt contents, workspace
   files, login flow, or broader repository access.
3. Classify the host result:
   - Authenticated: the sandbox result was a false negative. If the sandbox
     still cannot use the auth state, run the actual Claude command through its
     own narrow host escalation.
   - Unauthenticated: report `auth_missing` and stop without starting login.
   - Unavailable or denied: report `sandbox_auth_unverified` and stop without
     claiming the user is logged out.

Moving the auth check or the otherwise unchanged Claude command across the
sandbox boundary is an execution-boundary change, not the single response
retry. Request escalation at most once for each exact command and reason.

## Handle Other Sandbox Blocks

Treat permission, DNS, credential-store, and temp-file errors as
`sandbox_blocked`, not as Claude answers. Use the host's native escalation
mechanism and request only the access required for the exact command:

- outbound network access for the Claude API;
- execution of the installed CLI and access to its existing auth state;
- creation and cleanup of the command's private temporary directory; and
- for workspace mode only, read access to the files already named in scope.

Keep the command, packet, model, schema, and output location unchanged so the
sandbox boundary is the only changed variable. A completed invocation with an
empty, malformed, schema-invalid, or `unable_to_answer` result then enters the
normal single-retry path in `claude-cli.md`.

## Guardrails

Host escalation does not authorize broader repository access, additional prompt
contents, installation, authentication, or file modification. Any approval for
sending private workspace material to Claude Code must already cover the exact
packet.

Never copy credentials into the repository, put them in the prompt or
environment, change credential locations, start interactive login, use an
unapproved proxy, or write packets or raw output to tracked paths. Keep packets
and raw output in private temporary or already-ignored paths.

## If Host Execution Is Unavailable or Denied

Stop rather than rephrasing an escalation request, repeating the blocked
command, or weakening the sandbox. Use `sandbox_auth_unverified` when the
blocked command was the host auth check; otherwise use `sandbox_blocked`.

Report the blocked capability and exact command. When useful, give the user an
equivalent quoted command with existing absolute script and packet paths and the
same flags. Do not leave placeholders or reproduce packet contents beyond the
approval that already covered them. If no safe, runnable equivalent can be
handed off, report that instead.

Make clear that no Claude answer was retrieved. Do not replace it with your own
analysis or describe the failed run as agreement.
