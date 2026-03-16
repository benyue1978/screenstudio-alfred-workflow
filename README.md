# Screen Studio URL Schemes

This document records the Screen Studio URL schemes we learned from Raycast's Screen Studio extension and verified on macOS.

The goal is to support a future Alfred workflow.

## Summary

Screen Studio supports `screen-studio://...` deep links.

These URL schemes are more reliable than keyboard shortcuts because they:

- do not depend on app focus as much
- avoid shortcut conflicts with macOS or other apps
- enter Screen Studio directly into the requested mode

However, URL schemes do not eliminate all UI automation:

- `record-window` still requires selecting the target window
- `record-display` still requires selecting the target display
- the most reliable confirmation method we found is:
  - activate target app
  - move mouse to the target window center or target display center
  - press `Enter`
- after recording finishes, naming and saving the file is still manual

## Confirmed Useful Schemes

These were directly useful in testing.

### `screen-studio://record-window`

Meaning:

- Start Screen Studio's window-recording picker

Observed behavior:

- Opens Screen Studio into window selection mode
- Shows `Start Recording`
- Shows window/display highlighter overlays

Recommended use:

1. `open 'screen-studio://record-window'`
2. Activate the target app
3. Move mouse to the target window center
4. Press `Enter`

### `screen-studio://record-display`

Meaning:

- Start Screen Studio's display-recording flow

Observed behavior:

- Opens Screen Studio into display recording mode
- Visible state changed to `Start Recording` plus `recording-manager-widget`

Recommended use:

- Use when window targeting is too brittle or when the target app cannot be reliably identified as a desktop window
- Move the mouse to the intended display center before pressing `Enter`

### `screen-studio://record-area`

Meaning:

- Start Screen Studio's area recording mode

Observed behavior:

- Entered area/display-selection-related state
- Highlighter windows appeared

Recommended use:

- Likely useful for manual area selection or future area automation
- We did not fully automate the selection flow in this mode

### `screen-studio://finish-recording`

Meaning:

- Finish the current recording

Observed behavior:

- `open` succeeded
- This is part of the validated automation flow
- More reliable than sending the old global finish shortcut

Recommended use:

- Prefer this over the keyboard shortcut fallback

### `screen-studio://open-settings`

Meaning:

- Open Screen Studio settings

Observed behavior:

- Opened a `Settings` window

### `screen-studio://open-projects-folder`

Meaning:

- Open the Screen Studio projects folder

Observed behavior:

- `open` succeeded
- Screen Studio lost frontmost state, likely because Finder opened the folder

Recommended use:

- Useful for Alfred actions that jump to saved projects

## Schemes That Likely Need Context

These did not show a strong visible effect in the test run, but `open` succeeded. The most likely explanation is that they require an active recording or an open project.

### `screen-studio://cancel-recording`

Likely meaning:

- Cancel the current recording or recording setup

Observed behavior:

- No obvious visible state change in the test context

### `screen-studio://restart-recording`

Likely meaning:

- Restart an active recording

Observed behavior:

- No obvious visible state change in the test context

### `screen-studio://toggle-recording-controls`

Likely meaning:

- Show or hide recording controls

Observed behavior:

- No obvious visible state change in the test context

### `screen-studio://toggle-recording-area-cover`

Likely meaning:

- Toggle area-cover behavior during area recording

Observed behavior:

- No obvious visible state change in the test context

### `screen-studio://copy-and-zip-project`

Likely meaning:

- Copy and zip the current project

Observed behavior:

- No obvious visible state change in the test context

## Full Tested Scheme List

We tested these exact commands:

```bash
open 'screen-studio://record-window'
open 'screen-studio://record-display'
open 'screen-studio://record-area'
open 'screen-studio://finish-recording'
open 'screen-studio://cancel-recording'
open 'screen-studio://restart-recording'
open 'screen-studio://open-settings'
open 'screen-studio://open-projects-folder'
open 'screen-studio://toggle-recording-controls'
open 'screen-studio://toggle-recording-area-cover'
open 'screen-studio://copy-and-zip-project'
```

## Best Current Automation Flow

For Alfred, the best current window-recording flow is:

1. Launch or focus the target app
2. Identify the real desktop window
3. Read its live bounds
4. Compute center:
   - `center_x = left + width / 2`
   - `center_y = top + height / 2`
5. Run:

```bash
open 'screen-studio://record-window'
```

6. Activate the target app
7. Move mouse to the target window center
8. Press `Enter`
9. Drive the target app
10. Stop with:

```bash
open 'screen-studio://finish-recording'
```

For display recording:

```bash
open 'screen-studio://record-display'
```

Then:

1. Move the mouse to the intended display center
2. Press `Enter`

## Important Caveats

### 1. Window recording still needs target selection

The URL scheme gets Screen Studio into the right mode, but it does not fully remove the selection step.

The reliable method we validated was:

- hover the target window center
- press `Enter`

This worked better than trying to click the transient `Record & Save` button.

### 1b. Display recording also needs target selection

`screen-studio://record-display` also enters a selection state first.

To actually start recording:

- move the mouse to the intended display center
- press `Enter`

Without that step, Screen Studio may still be waiting for confirmation rather than actively recording.

### 2. Use `Record & Save`, not the default project flow

Before relying on automation, manually do one Screen Studio window-recording session and switch the floating action from:

- `Record and create project`

to:

- `Record & Save`

### 3. Final naming and saving is still manual

The current workflow does not automate:

- final file name entry
- save dialog confirmation
- export to `.mp4`

It can automate:

- entering recording mode
- choosing display/window mode
- selecting the target window
- performing the app actions
- finishing the recording

## Recommended Alfred Actions

Good candidates for Alfred workflow actions:

- Record Window
  - `open 'screen-studio://record-window'`
- Record Display
  - `open 'screen-studio://record-display'`
- Record Area
  - `open 'screen-studio://record-area'`
- Finish Recording
  - `open 'screen-studio://finish-recording'`
- Open Screen Studio Settings
  - `open 'screen-studio://open-settings'`
- Open Projects Folder
  - `open 'screen-studio://open-projects-folder'`

Secondary candidates that need more validation:

- Cancel Recording
- Restart Recording
- Toggle Recording Controls
- Toggle Recording Area Cover
- Copy and Zip Project
