# Screen Studio Alfred Workflow Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a self-contained Alfred Workflow for Screen Studio that supports all known deep links plus smart window and display target selection for `record-window` and `record-display`.

**Architecture:** Alfred provides the UX through a main Script Filter, two target-aware Script Filters, and direct keywords. Bundled shell scripts handle deep-link dispatch, target discovery, fuzzy matching, mouse movement, and `Enter` confirmation using system-provided macOS automation tools only.

**Tech Stack:** Alfred Workflow, `zsh`, `osascript`/JXA, system `swift`, macOS Accessibility APIs, `plutil`/plist workflow metadata

---

## File Map

Planned files and responsibilities:

- Create: `scripts/lib/common.sh`
  - shared shell helpers, environment setup, error reporting
- Create: `scripts/lib/deeplinks.sh`
  - deep-link registry and validation helpers
- Create: `scripts/lib/json.sh`
  - Alfred JSON response helpers
- Create: `scripts/lib/mouse.sh`
  - pointer movement and key press helpers via system `swift` and `osascript`
- Create: `scripts/lib/windows.sh`
  - generic window enumeration, filtering, center calculation, and fuzzy matching
- Create: `scripts/lib/displays.sh`
  - display enumeration, labeling, center calculation, and fuzzy matching
- Create: `scripts/list_commands.sh`
  - main command browser Script Filter entry point
- Create: `scripts/list_windows.sh`
  - record-window target listing entry point
- Create: `scripts/list_displays.sh`
  - record-display target listing entry point
- Create: `scripts/run_action.sh`
  - one-shot action runner and auto-confirm execution flow
- Create: `tests/test_helpers.sh`
  - lightweight shell assertions for script contract tests
- Create: `tests/test_deeplinks.sh`
  - deep-link registry tests
- Create: `tests/test_list_commands.sh`
  - command listing JSON contract tests
- Create: `tests/test_matching.sh`
  - window and display fuzzy matching tests using fixtures
- Create: `tests/fixtures/windows.json`
  - synthetic window fixture data for matching logic
- Create: `tests/fixtures/displays.json`
  - synthetic display fixture data for matching logic
- Create: `tests/manual-smoke-checklist.md`
  - repeatable manual validation for Screen Studio integration
- Create: `workflow/Screen Studio.alfredworkflow`
  - exported artifact placeholder or output target after implementation
- Create: `workflow/src/info.plist`
  - workflow source metadata
- Modify: `README.md`
  - installation, permissions, usage, and testing documentation

Notes:

- Keep matching logic testable by separating discovery from ranking.
- Keep Alfred JSON generation centralized so all Script Filters share the same shape.
- Exported `.alfredworkflow` should be generated from source after the scripts are working.

## Testing Strategy

Script testing needs to be designed in from the start because the fragile part is not shell syntax, it is target discovery and action routing.

Use two layers:

1. Contract tests that run without Screen Studio
   - validate deep-link mapping
   - validate Alfred JSON shape
   - validate fuzzy matching and ranking with fixtures
   - validate action argument parsing and fallback behavior

2. Manual integration smoke tests on macOS with Screen Studio
   - validate real picker behavior
   - validate Accessibility permissions
   - validate pointer movement and `Enter` confirmation
   - validate end-to-end behavior inside Alfred

The implementation should be structured so most logic can be exercised through fixture-driven tests, leaving only the OS integration to manual smoke tests.

## Chunk 1: Foundation and Test Harness

### Task 1: Create script directory structure

**Files:**
- Create: `scripts/lib/common.sh`
- Create: `scripts/lib/json.sh`
- Create: `tests/test_helpers.sh`

- [ ] **Step 1: Create the directories**

Create:

- `scripts/`
- `scripts/lib/`
- `tests/`
- `tests/fixtures/`
- `workflow/src/`

- [ ] **Step 2: Write the failing smoke-free test helper call**

Add a tiny test in `tests/test_helpers.sh` that sources `scripts/lib/common.sh`.

```sh
#!/bin/zsh
set -euo pipefail

source "$(cd "$(dirname "$0")/.." && pwd)/scripts/lib/common.sh"
echo "ok"
```

- [ ] **Step 3: Run it to verify it fails**

Run: `zsh tests/test_helpers.sh`
Expected: FAIL because `scripts/lib/common.sh` does not exist yet

- [ ] **Step 4: Write minimal shared helpers**

Implement `scripts/lib/common.sh` with:

- strict shell options
- repo-root resolution
- helper to print fatal errors to stderr
- helper to guard required commands

- [ ] **Step 5: Run the helper test again**

Run: `zsh tests/test_helpers.sh`
Expected: PASS with `ok`

- [ ] **Step 6: Commit**

```bash
git add scripts/lib/common.sh tests/test_helpers.sh
git commit -m "chore: add workflow script foundation"
```

### Task 2: Add JSON response helpers

**Files:**
- Modify: `scripts/lib/json.sh`
- Create: `tests/test_list_commands.sh`

- [ ] **Step 1: Write the failing JSON contract test**

Create `tests/test_list_commands.sh` with a minimal assertion that command-list output contains Alfred `items`.

```sh
#!/bin/zsh
set -euo pipefail

output="$(zsh scripts/list_commands.sh "")"
[[ "$output" == *'"items"'* ]]
```

- [ ] **Step 2: Run test to verify it fails**

Run: `zsh tests/test_list_commands.sh`
Expected: FAIL because `scripts/list_commands.sh` does not exist yet

- [ ] **Step 3: Implement JSON helper functions**

Add shell-safe JSON emitters in `scripts/lib/json.sh` for:

- start item list
- emit one item with title, subtitle, arg, uid, valid
- end item list

Prefer using JXA or `python -c` only if strictly needed for safe escaping. If shell escaping stays reliable and small, keep it shell-only.

- [ ] **Step 4: Add a temporary stub `scripts/list_commands.sh`**

Return one valid Alfred item using the JSON helpers.

- [ ] **Step 5: Run the JSON contract test**

Run: `zsh tests/test_list_commands.sh`
Expected: PASS and output contains `"items"`

- [ ] **Step 6: Commit**

```bash
git add scripts/lib/json.sh scripts/list_commands.sh tests/test_list_commands.sh
git commit -m "test: add Alfred JSON helper coverage"
```

## Chunk 2: Deep-Link Registry and Main Command Browser

### Task 3: Encode all deep-link actions

**Files:**
- Create: `scripts/lib/deeplinks.sh`
- Create: `tests/test_deeplinks.sh`

- [ ] **Step 1: Write the failing deep-link registry test**

Create assertions for all 11 command ids.

```sh
#!/bin/zsh
set -euo pipefail

source scripts/lib/deeplinks.sh
[[ "$(deeplink_url record-window)" == "screen-studio://record-window" ]]
[[ "$(deeplink_url finish-recording)" == "screen-studio://finish-recording" ]]
```

- [ ] **Step 2: Run test to verify it fails**

Run: `zsh tests/test_deeplinks.sh`
Expected: FAIL because registry does not exist yet

- [ ] **Step 3: Implement registry and metadata**

Include for each action:

- command id
- deep-link URL
- Alfred-facing title
- subtitle
- direct keyword name
- whether the action supports target selection

- [ ] **Step 4: Run registry tests**

Run: `zsh tests/test_deeplinks.sh`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add scripts/lib/deeplinks.sh tests/test_deeplinks.sh
git commit -m "feat: add Screen Studio deeplink registry"
```

### Task 4: Build the main command browser

**Files:**
- Modify: `scripts/list_commands.sh`
- Test: `tests/test_list_commands.sh`

- [ ] **Step 1: Expand the failing test to require all command ids**

Check that empty-query output includes `record-window`, `record-display`, and `open-settings`.

- [ ] **Step 2: Run test to verify it fails**

Run: `zsh tests/test_list_commands.sh`
Expected: FAIL until the full command browser is implemented

- [ ] **Step 3: Implement full command listing and filtering**

Support:

- empty query returns all commands
- query filters by title, command id, and aliases
- `record-window` and `record-display` include subtitles explaining target-aware behavior

- [ ] **Step 4: Re-run the command browser test**

Run: `zsh tests/test_list_commands.sh`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add scripts/list_commands.sh tests/test_list_commands.sh
git commit -m "feat: add main Screen Studio command browser"
```

## Chunk 3: Window and Display Discovery

### Task 5: Define fixture-driven matching contracts

**Files:**
- Create: `tests/fixtures/windows.json`
- Create: `tests/fixtures/displays.json`
- Create: `tests/test_matching.sh`

- [ ] **Step 1: Write fixture data before implementation**

Add windows like:

- `Google Chrome` + `Pricing Page`
- `Google Chrome` + `Docs`
- `Cursor` + `screenstudio-alfred-workflow`

Add displays like:

- `Built-in Retina Display`
- `Studio Display`

- [ ] **Step 2: Write failing matching tests**

Cover:

- unique match on app name
- unique match on title substring
- ambiguous window result
- unique display match
- no result fallback

- [ ] **Step 3: Run tests to verify they fail**

Run: `zsh tests/test_matching.sh`
Expected: FAIL because matching helpers do not exist yet

- [ ] **Step 4: Commit the failing tests**

```bash
git add tests/fixtures/windows.json tests/fixtures/displays.json tests/test_matching.sh
git commit -m "test: define matching fixtures and contracts"
```

### Task 6: Implement display discovery and matching

**Files:**
- Create: `scripts/lib/displays.sh`
- Create: `scripts/list_displays.sh`
- Test: `tests/test_matching.sh`

- [ ] **Step 1: Implement fixture-driven display matching first**

Separate:

- parse display fixture input
- compute labels and centers
- rank matches against query

- [ ] **Step 2: Run matching tests**

Run: `zsh tests/test_matching.sh`
Expected: display-related assertions PASS, window assertions still FAIL

- [ ] **Step 3: Add real display discovery adapter**

Use system tools to enumerate displays and derive:

- name
- origin
- size
- center coordinates

- [ ] **Step 4: Implement `scripts/list_displays.sh`**

Behavior:

- no query returns all displays
- one unique match outputs one Alfred item with actionable arg
- multiple matches output multiple Alfred items

- [ ] **Step 5: Run tests again**

Run: `zsh tests/test_matching.sh`
Expected: display cases PASS

- [ ] **Step 6: Commit**

```bash
git add scripts/lib/displays.sh scripts/list_displays.sh tests/test_matching.sh
git commit -m "feat: add display discovery and matching"
```

### Task 7: Implement generic window discovery and matching

**Files:**
- Create: `scripts/lib/windows.sh`
- Create: `scripts/list_windows.sh`
- Test: `tests/test_matching.sh`

- [ ] **Step 1: Implement fixture-driven window ranking before OS discovery**

Model window records with:

- window id
- app name
- title
- x
- y
- width
- height

- [ ] **Step 2: Run matching tests**

Run: `zsh tests/test_matching.sh`
Expected: fixture ranking assertions PASS once ranking logic is correct

- [ ] **Step 3: Add real generic window discovery**

Discover for visible desktop windows:

- owning application name
- title when available
- visible bounds

Filter out:

- zero-area windows
- windows lacking usable bounds
- obvious overlay/system junk if safely detectable

- [ ] **Step 4: Implement center calculation helper**

Verify that live window center uses:

- `center_x = x + width / 2`
- `center_y = y + height / 2`

- [ ] **Step 5: Implement `scripts/list_windows.sh`**

Behavior mirrors `list_displays.sh`, but window search matches both app name and title.

- [ ] **Step 6: Run matching tests**

Run: `zsh tests/test_matching.sh`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add scripts/lib/windows.sh scripts/list_windows.sh tests/test_matching.sh
git commit -m "feat: add generic window discovery and matching"
```

## Chunk 4: Action Runner and Auto-Confirm Flows

### Task 8: Implement one-shot action dispatch

**Files:**
- Create: `scripts/run_action.sh`
- Test: `tests/test_deeplinks.sh`

- [ ] **Step 1: Write a failing dry-run action test**

Add a test mode such as `DRY_RUN=1` so `run_action.sh finish-recording` prints the deep link instead of opening it.

- [ ] **Step 2: Run test to verify it fails**

Run: `DRY_RUN=1 zsh scripts/run_action.sh finish-recording`
Expected: FAIL until dispatch exists

- [ ] **Step 3: Implement non-targeted action routing**

Support:

- action id parsing
- deep-link lookup
- dry-run mode for tests
- readable error for unknown action

- [ ] **Step 4: Re-run the dry-run test**

Run: `DRY_RUN=1 zsh scripts/run_action.sh finish-recording`
Expected: PASS and prints `screen-studio://finish-recording`

- [ ] **Step 5: Commit**

```bash
git add scripts/run_action.sh tests/test_deeplinks.sh
git commit -m "feat: add one-shot action runner"
```

### Task 9: Implement mouse move and key confirm helpers

**Files:**
- Create: `scripts/lib/mouse.sh`
- Test: `tests/test_helpers.sh`

- [ ] **Step 1: Add a failing dry-run helper test**

Exercise helper functions in dry-run mode so they print intended coordinates and key action without sending events.

- [ ] **Step 2: Run test to verify it fails**

Run: `zsh tests/test_helpers.sh`
Expected: FAIL until helper functions exist

- [ ] **Step 3: Implement event helpers**

Provide:

- `move_mouse_to_point x y settle`
- `press_enter`
- optional `activate_app app_name`

Support `DRY_RUN=1` to keep tests headless.

- [ ] **Step 4: Re-run helper tests**

Run: `zsh tests/test_helpers.sh`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add scripts/lib/mouse.sh tests/test_helpers.sh
git commit -m "feat: add dry-runable input automation helpers"
```

### Task 10: Implement `record-display` auto-confirm flow

**Files:**
- Modify: `scripts/run_action.sh`
- Test: `tests/test_matching.sh`

- [ ] **Step 1: Write a failing dry-run flow assertion**

Add a test path that resolves a fixture display and prints ordered steps:

- deep link
- move pointer
- press enter

- [ ] **Step 2: Run it to verify it fails**

Run: `DRY_RUN=1 FIXTURE_DISPLAYS=tests/fixtures/displays.json zsh scripts/run_action.sh record-display "Studio Display"`
Expected: FAIL

- [ ] **Step 3: Implement display auto-confirm flow**

Support:

- no query means deep-link only
- query resolves target display
- unique result triggers move and `Enter`
- ambiguous result returns error telling caller to use the listing step

- [ ] **Step 4: Re-run dry-run flow test**

Run: same as above
Expected: PASS with ordered dry-run output

- [ ] **Step 5: Commit**

```bash
git add scripts/run_action.sh tests/test_matching.sh
git commit -m "feat: add display auto-confirm flow"
```

### Task 11: Implement `record-window` auto-confirm flow

**Files:**
- Modify: `scripts/run_action.sh`
- Test: `tests/test_matching.sh`

- [ ] **Step 1: Write a failing dry-run flow assertion**

Add a test path that resolves a fixture window and prints ordered steps:

- deep link
- activate app
- move pointer
- press enter

- [ ] **Step 2: Run it to verify it fails**

Run: `DRY_RUN=1 FIXTURE_WINDOWS=tests/fixtures/windows.json zsh scripts/run_action.sh record-window "Pricing"`
Expected: FAIL

- [ ] **Step 3: Implement window auto-confirm flow**

Support:

- no query means deep-link only
- unique query resolves target window
- target app is activated before pointer move
- ambiguous results fail safely
- missing bounds fail safely

- [ ] **Step 4: Re-run dry-run flow test**

Run: same as above
Expected: PASS with ordered dry-run output

- [ ] **Step 5: Commit**

```bash
git add scripts/run_action.sh tests/test_matching.sh
git commit -m "feat: add window auto-confirm flow"
```

## Chunk 5: Alfred Workflow Wiring

### Task 12: Create workflow source metadata

**Files:**
- Create: `workflow/src/info.plist`

- [ ] **Step 1: Inspect Alfred workflow plist structure from a minimal sample**

Document the object types needed:

- Script Filter
- Keyword
- Run Script
- connections between them

- [ ] **Step 2: Create the initial plist with the main Script Filter only**

Wire it to `scripts/list_commands.sh`.

- [ ] **Step 3: Validate plist structure**

Run: `plutil -lint workflow/src/info.plist`
Expected: `OK`

- [ ] **Step 4: Commit**

```bash
git add workflow/src/info.plist
git commit -m "feat: add Alfred workflow source plist"
```

### Task 13: Wire target-aware Script Filters and direct keywords

**Files:**
- Modify: `workflow/src/info.plist`

- [ ] **Step 1: Add `record-window` and `record-display` Script Filter nodes**

Hook them to:

- `scripts/list_windows.sh`
- `scripts/list_displays.sh`

- [ ] **Step 2: Add direct keyword nodes for all one-shot actions**

Each should route into `scripts/run_action.sh`.

- [ ] **Step 3: Validate plist again**

Run: `plutil -lint workflow/src/info.plist`
Expected: `OK`

- [ ] **Step 4: Manual Alfred wiring check**

Import or sync the workflow source into Alfred and verify objects appear.

- [ ] **Step 5: Commit**

```bash
git add workflow/src/info.plist
git commit -m "feat: wire Alfred commands and target selectors"
```

## Chunk 6: Documentation, Manual Validation, and Packaging

### Task 14: Write the manual smoke checklist

**Files:**
- Create: `tests/manual-smoke-checklist.md`

- [ ] **Step 1: Write repeatable manual cases**

Include:

- Accessibility permission check
- Screen Studio installed check
- each deep-link smoke test
- `record-window` manual picker
- `record-window` unique auto-confirm
- `record-display` manual picker
- `record-display` unique auto-confirm
- ambiguous result behavior

- [ ] **Step 2: Commit**

```bash
git add tests/manual-smoke-checklist.md
git commit -m "docs: add manual smoke checklist"
```

### Task 15: Update README with usage and testing

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add installation and permission instructions**

Document:

- Screen Studio requirement
- Alfred Accessibility requirement
- how smart selection works

- [ ] **Step 2: Add testing instructions**

Document two commands:

- script contract tests, for example `zsh tests/test_deeplinks.sh && zsh tests/test_list_commands.sh && zsh tests/test_matching.sh`
- manual smoke checklist execution

- [ ] **Step 3: Add gallery-facing usage copy**

Explain:

- main keyword
- direct keywords
- manual fallback behavior

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add workflow usage and testing guide"
```

### Task 16: Export and verify workflow artifact

**Files:**
- Create: `workflow/Screen Studio.alfredworkflow`

- [ ] **Step 1: Export the workflow from Alfred**

Ensure it includes:

- scripts
- plist metadata
- icon

- [ ] **Step 2: Run validation checks**

Run:

- `plutil -lint workflow/src/info.plist`
- all shell contract tests

Expected:

- plist validation passes
- shell tests pass

- [ ] **Step 3: Run manual smoke tests**

Use: `tests/manual-smoke-checklist.md`
Expected: all required smoke checks pass or documented exceptions are understood

- [ ] **Step 4: Commit**

```bash
git add workflow/src/info.plist workflow/Screen\ Studio.alfredworkflow tests/ README.md scripts/
git commit -m "release: package Screen Studio Alfred workflow"
```

## Script Testing Notes

Because this project is mostly automation glue, the test design should favor dry runs and fixtures over trying to drive the live desktop in CI.

Recommended conventions:

- `DRY_RUN=1` disables real deep-link opens, mouse movement, and key presses
- `FIXTURE_WINDOWS=...` makes window discovery read from JSON fixtures
- `FIXTURE_DISPLAYS=...` makes display discovery read from JSON fixtures

This keeps the fragile OS integration thin and moves most behavior into repeatable tests.

## Open Technical Questions to Resolve During Implementation

- which macOS API gives the cleanest generic display names without extra dependencies
- whether window discovery is more reliable through JXA System Events, CGWindow APIs via `swift`, or a hybrid
- whether Alfred source should be maintained as a raw `info.plist` only or also mirrored in an editable build script

Resolve these with the smallest workable approach that keeps the workflow self-contained.

## Verification Commands

Baseline commands to keep using throughout implementation:

- `zsh tests/test_deeplinks.sh`
- `zsh tests/test_list_commands.sh`
- `zsh tests/test_matching.sh`
- `plutil -lint workflow/src/info.plist`

## Handoff

Plan complete and saved to `docs/superpowers/plans/2026-03-17-screenstudio-alfred-workflow.md`. Ready to execute?
