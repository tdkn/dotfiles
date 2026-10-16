---
name: devicehub-use
description: Launch or recover Xcode Device Hub for physical iPhone control through Codex Computer Use, including timeouts caused by invalid AppKit process registration.
---

# Device Hub with Computer Use

Make a connected physical iPhone visible and controllable through Device Hub and Codex Computer Use.

## Select the Xcode installation

Use the exact Xcode application path specified for the task. If no path is available, ask for it before launching.

Derive these paths from the selected installation:

- Device Hub app: `<Xcode.app>/Contents/Applications/DeviceHub.app`
- Executable: `<DeviceHub.app>/Contents/MacOS/DeviceHub`

Do not substitute another Xcode installation, resolve the path through the global Xcode selection, or change `xcode-select`.

## Inspect existing processes

Inspect running Device Hub and DevicesTrampoline processes:

```bash
ps -axww -o pid=,comm= | rg 'DeviceHub|DevicesTrampoline'
```

If the selected Device Hub is already healthy and Computer Use can control it, reuse it unless a restart was requested.

For a requested restart or invalid process registration, terminate only the identified Device Hub or DevicesTrampoline PIDs. Do not terminate Xcode or unrelated device services. Confirm those processes have exited before relaunching.

## Launch the executable directly

Check that the selected executable exists and is executable.

Run the internal executable directly in a persistent terminal session:

```bash
"<selected-Xcode.app>/Contents/Applications/DeviceHub.app/Contents/MacOS/DeviceHub"
```

Do not launch through:

- Xcode's Window or Devices menus
- `open DeviceHub.app` or normal application launching
- DevicesTrampoline

Verify the running process and record its PID:

```bash
ps -axww -o pid=,comm= | rg 'DeviceHub'
```

Confirm that its executable path belongs to the selected Xcode installation.

## Verify AppKit registration

Run Swift with the selected Xcode's developer directory:

```bash
DEVELOPER_DIR="<selected-Xcode.app>/Contents/Developer" /usr/bin/xcrun swift -e '
import AppKit
for app in NSRunningApplication.runningApplications(
  withBundleIdentifier: "com.apple.dt.Devices"
) {
  print(
    "pid:", app.processIdentifier,
    "finishedLaunching:", app.isFinishedLaunching,
    "bundle:", app.bundleURL?.path ?? "unknown"
  )
}'
```

Find the entry whose bundle path matches the selected DeviceHub.app.

Before acquiring the app through Computer Use, confirm:

- The AppKit PID is positive, not `-1`.
- It matches the running DeviceHub PID.
- `finishedLaunching` is true.
- The bundle and executable paths belong to the selected Xcode.

If registration is still invalid after one controlled relaunch, stop and report the diagnostic evidence. Do not loop through identical launch attempts.

## Verify Computer Use access

Use the available Computer Use tool and follow its API documentation.

Acquire the selected DeviceHub.app by its exact application path when multiple Xcode installations make bundle-ID lookup ambiguous. Use `com.apple.dt.Devices` only when it identifies the verified process unambiguously.

Select the connected iPhone and display its screen.

Verify all of the following:

- Device Hub's window can be inspected.
- The physical iPhone screen is visible.
- A tap produces an observable response.
- A swipe produces an observable response.

Use navigation or scrolling appropriate to the current task. Do not initiate a payment, checkout, deletion, or other consequential action merely to test input.

If acquiring the app times out, inspect the real process and AppKit registration again before retrying. In particular, check whether the AppKit PID has become `-1`.

Keep this workflow on Device Hub and Computer Use. Do not substitute XCUITest or simulator automation unless the user requests another approach.

## QR camera limitation

Device Hub connections can cause the physical iPhone camera preview to appear black.

When QR scanning requires a disconnect, hand that step to the user. Resume after the user confirms scanning is complete and Device Hub is reconnected. Do not treat the black preview alone as an application defect.

## Report the result

Claim readiness only after visibility, tapping, and swiping have been verified.

If blocked, report:

- The executed launch command
- The DeviceHub process PID
- The AppKit PID and launch state
- The actual executable and bundle paths
- The complete Computer Use error

Keep machine-specific paths and session diagnostics in the conversation. Do not add them to repository documentation or commits.
