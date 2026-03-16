# Screen Studio Alfred Workflow Design

Date: 2026-03-17

## Goal

Build an Alfred Workflow for Screen Studio that is suitable for eventual publication in the Alfred Workflow Gallery.

Primary goals:

- support all validated `screen-studio://...` deep links
- provide a gallery-friendly main entry point
- provide faster direct keywords for frequent actions
- add smart target selection for `record-window` and `record-display`
- keep the workflow self-contained, auditable, and free of third-party runtime dependencies

## Inputs

This design is based on:

- the current repository [`README.md`](/Users/song.yue/git/screenstudio-alfred-workflow/README.md)
- the Screen Studio Raycast extension command list from [Raycast `package.json`](https://raw.githubusercontent.com/raycast/extensions/6bd3d6958d4af79b79beae8c275542ea0f3ca6f2/extensions/screen-studio/package.json)
- Alfred Gallery submission guidance from [How to Submit a Workflow](https://alfred.app/submit/)
- the local Screen Studio automation skill at `/Users/song.yue/.codex/skills/screenstudio-macos-automation/SKILL.md`
- reusable local helper scripts under `/Users/song.yue/git/screen-studio-skill/skills/screenstudio-macos-automation/scripts`

## Product Shape

The workflow has two user-facing entry styles:

1. A gallery-friendly main Script Filter keyword
2. A set of direct shortcut keywords for high-frequency actions

The main keyword is the canonical interface shown in documentation and gallery screenshots.
Shortcut keywords are convenience entry points for repeat users.

## Supported Commands

The workflow supports all current deep-link actions validated in local docs and present in the Raycast reference:

- `record-display`
- `record-window`
- `record-area`
- `finish-recording`
- `cancel-recording`
- `restart-recording`
- `toggle-recording-area-cover`
- `toggle-recording-controls`
- `open-projects-folder`
- `open-settings`
- `copy-and-zip-project`

## Alfred UX

### Main Entry

Use a Script Filter keyword with at least 3 characters to align with Alfred Gallery guidance. Recommended defaults:

- `screenstudio`
- configurable shorter alias such as `sst`

Behavior:

- empty query: show all supported commands
- command-like query: filter command titles, names, and aliases
- `record-window` and `record-display`: support progressive target selection behavior

### Direct Keywords

Provide direct keywords for speed, all at least 3 characters by default:

- `ssw` for record window
- `ssd` for record display
- `ssa` for record area
- `ssf` for finish recording
- `ssc` for cancel recording
- `ssr` for restart recording
- `sss` for open settings
- `ssp` for open projects folder
- `sstc` for toggle recording controls
- `ssta` for toggle recording area cover
- `ssz` for copy and zip project

All keywords should be user-configurable in the Alfred Workflow configuration.

## Smart Selection Rules

### Record Window

`record-window` supports three modes:

1. No argument
   - only trigger `screen-studio://record-window`
   - no target auto-selection

2. Query with exactly one fuzzy match
   - resolve a single target window by matching against `application name + window title`
   - trigger `screen-studio://record-window`
   - activate the owning app
   - move the pointer to the target window center
   - press `Enter`

3. Query with multiple fuzzy matches
   - show a list of candidate windows in Alfred
   - selecting one runs the same auto-confirm flow

### Record Display

`record-display` uses the same 3-mode rule:

1. No argument
   - only trigger `screen-studio://record-display`

2. Query with exactly one fuzzy match
   - resolve a single display by display name
   - trigger `screen-studio://record-display`
   - move the pointer to the display center
   - press `Enter`

3. Query with multiple fuzzy matches
   - show candidate displays in Alfred
   - selecting one runs the same auto-confirm flow

## Matching Model

### Window Search

Search terms match across:

- app name
- window title
- concatenated display text such as `Google Chrome - Pricing Page`

This avoids requiring users to know the exact app name in advance.

Preferred result ranking:

1. exact or prefix match on app name
2. exact or prefix match on window title
3. substring match on combined label
4. fallback fuzzy score

### Display Search

Search terms match across:

- display name
- optional fallback labels like `Display 1`, `Display 2`
- resolution string if available

## Architecture

Use Alfred as the interaction surface and a small bundled script toolkit as the execution layer.

### Workflow Objects

- Script Filter for the main command browser
- Script Filters for `record-window` and `record-display` shortcut entry points
- Keyword objects for one-shot deep-link actions
- Run Script actions that dispatch into bundled scripts
- optional workflow variables to carry action type, target id, and label

### Script Layout

Recommended structure:

- `scripts/list_commands.sh`
- `scripts/list_windows.sh`
- `scripts/list_displays.sh`
- `scripts/run_action.sh`
- `scripts/lib/deeplinks.sh`
- `scripts/lib/accessibility.sh`
- `scripts/lib/json.sh`
- `scripts/lib/mouse.sh`
- `scripts/lib/displays.sh`

Keep the public scripts small and push shared logic into `lib/`.

## Window Discovery Strategy

The workflow should not depend on Chrome-specific or app-specific window logic.

Preferred strategy:

1. enumerate on-screen desktop windows generically
2. derive:
   - owning application name
   - window title when available
   - visible bounds
   - stable identity usable during the same Alfred action
3. filter out windows that are obviously unsuitable:
   - zero-size windows
   - off-screen windows
   - unnamed system overlays when they cannot be targeted reliably
4. compute center from live bounds

Center formula:

- `center_x = left + width / 2`
- `center_y = top + height / 2`

Implementation note:

- prefer generic macOS Accessibility and window APIs over app-specific adapters
- keep the design open to later app-specific adapters if a real need appears
- if a candidate lacks reliable live bounds, show it as non-auto-confirmable or omit it

## Display Discovery Strategy

Discover active displays generically and compute their centers from current bounds.

For each display, expose:

- display name
- resolution when available
- origin and size
- center point

The display auto-confirm flow is simpler than window targeting because no app activation is required.

## Execution Flow

### One-shot Deep Link Actions

For actions other than `record-window` and `record-display`:

1. validate Screen Studio availability if practical
2. open the corresponding deep link
3. return success or a readable error message

### Record Window with Auto-Confirm

1. resolve selected target window
2. compute live center
3. open `screen-studio://record-window`
4. wait for picker state to appear
5. activate the target app
6. move pointer to the center point
7. pause briefly for highlight settle
8. press `Enter`
9. return success with the selected window label

### Record Display with Auto-Confirm

1. resolve selected display
2. compute display center
3. open `screen-studio://record-display`
4. wait for picker state to appear
5. move pointer to the center point
6. pause briefly
7. press `Enter`
8. return success with the selected display label

## Error Handling

The workflow should fail clearly and conservatively.

Cases to handle:

- Screen Studio not installed or deep link cannot open
- Alfred or the script host lacks Accessibility permission
- no windows found
- no displays found
- fuzzy query produced no match
- target lost its bounds between listing and execution
- pointer move or key press failed

Fallback behavior:

- if there is no query, keep the manual picker behavior
- if auto-confirm cannot run safely, do not guess
- return a clear Alfred message telling the user to retry without a target query for manual selection

## Gallery Constraints

The workflow should be designed to satisfy Alfred Gallery expectations as closely as possible:

- keywords should generally be at least 3 characters
- keywords should be user-configurable
- include a workflow icon of at least 256x256
- do not self-update
- do not install additional software after installation
- keep executable contents auditable

This design therefore avoids dependencies on tools like:

- `brew`
- `cliclick`
- `yabai`
- `jq`
- custom unsigned binaries

Use shell, AppleScript or JXA, and system-provided Swift execution where needed.

## Permissions and Setup

Document these prerequisites clearly:

- Screen Studio must be installed
- Alfred must have Accessibility permission
- any helper process used to send events may also need Accessibility permission depending on how the final scripts are executed
- users should set Screen Studio to the validated recording flow configuration documented in the repo

## Testing Strategy

Testing should cover both script correctness and user-visible workflow behavior.

### Script-Level Checks

- deep-link mapping correctness
- query parsing and routing
- window and display result JSON shape
- center-point calculations
- handling of empty and ambiguous results

### Manual Integration Checks

On macOS with Screen Studio installed:

1. each deep-link action opens the expected Screen Studio state
2. `record-window` with no input opens picker only
3. `record-window` with unique match auto-confirms the right window
4. `record-window` with multiple matches lists candidates
5. `record-display` with no input opens picker only
6. `record-display` with unique match auto-confirms the right display
7. direct keywords and main Script Filter behave consistently
8. no path requires network access or external package installation

### Gallery Readiness Checks

- workflow exports cleanly as `.alfredworkflow`
- no auto-update logic exists
- no unsigned bundled binaries are included
- README explains setup, permissions, and keyword usage
- screenshots and icon are ready for forum or gallery submission

## Deliverables

Implementation should produce:

- Alfred workflow source files in this repository
- bundled scripts for listing and executing actions
- documentation for installation, permissions, and usage
- workflow icon and gallery-friendly copy
- exported `.alfredworkflow` artifact when implementation is complete

## Non-Goals

This phase does not attempt to automate:

- final file naming and save dialog handling after recording
- Screen Studio editing or export flows beyond validated deep links
- app-specific window discovery plugins unless generic discovery proves insufficient

## Risks

- generic macOS window enumeration may expose noisy or untargetable windows
- some apps may report incomplete accessibility metadata
- display names can vary across hardware setups
- Screen Studio picker timing may differ across app versions and machine performance

Mitigations:

- prefer conservative execution
- expose manual picker fallback
- keep timing values configurable if needed
- structure scripts so target discovery can be refined without changing Alfred UX

## Recommended Next Step

After review, the next step is to turn this design into an implementation plan, then build the workflow in small verified slices:

1. core deep-link actions
2. main Script Filter
3. window and display listing
4. auto-confirm execution flow
5. packaging and gallery polish

## Repository Note

This directory is currently not a git repository, so this spec can be written locally but cannot be committed from here until the project is placed inside a git repo or initialized as one.
