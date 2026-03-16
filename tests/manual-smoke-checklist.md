# Manual Smoke Checklist

Run these checks on macOS with Screen Studio and Alfred installed.

## Preconditions

- Alfred has Accessibility permission
- Screen Studio is installed
- Screen Studio is configured to use `Record & Save`
- The target app windows are visible on screen

## Core Deep Link Checks

1. Run `open 'screen-studio://open-settings'`
Expected: Screen Studio opens Settings.

2. Run `open 'screen-studio://open-projects-folder'`
Expected: Finder opens the projects folder.

3. Run `open 'screen-studio://record-area'`
Expected: Screen Studio enters area-selection mode.

4. Run `open 'screen-studio://finish-recording'` during a recording
Expected: the recording stops.

## Script Dry-Run Checks

1. Run `DRY_RUN=1 zsh scripts/run_action.sh finish-recording`
Expected: `open screen-studio://finish-recording`

2. Run `DRY_RUN=1 FIXTURE_WINDOWS=tests/fixtures/windows.json zsh scripts/run_action.sh record-window Pricing`
Expected:
- `open screen-studio://record-window`
- `activate Google Chrome`
- `move 740 530`
- `press-enter`

3. Run `DRY_RUN=1 FIXTURE_DISPLAYS=tests/fixtures/displays.json zsh scripts/run_action.sh record-display Studio`
Expected:
- `open screen-studio://record-display`
- `move 2792 720`
- `press-enter`

## Real Window Flow

1. Run `zsh scripts/run_action.sh record-window "<part of visible window title>"`
Expected:
- Screen Studio opens window picker
- target app becomes frontmost
- mouse moves to the target window center
- `Enter` confirms the selection

2. Run `zsh scripts/run_action.sh record-window`
Expected:
- Screen Studio opens window picker only
- no automatic target selection occurs

3. Run `zsh scripts/list_windows.sh "<ambiguous query>"`
Expected:
- Alfred JSON contains more than one candidate window

## Real Display Flow

1. Run `zsh scripts/run_action.sh record-display "<part of display name>"`
Expected:
- Screen Studio opens display picker
- mouse moves to the target display center
- `Enter` confirms the selection

2. Run `zsh scripts/run_action.sh record-display`
Expected:
- Screen Studio opens display picker only

3. Run `zsh scripts/list_displays.sh ""`
Expected:
- Alfred JSON includes all active displays

## Alfred Entry Checks

After wiring the workflow into Alfred:

1. Main keyword with empty query
Expected: all Screen Studio commands are listed.

2. Main keyword with `record-window <query>`
Expected: candidate windows are listed.

3. Main keyword with `record-display <query>`
Expected: candidate displays are listed.

4. Direct keyword for finish recording
Expected: immediately triggers the finish deep link.
