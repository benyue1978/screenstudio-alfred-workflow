#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

export FIXTURE_WINDOWS="$PWD/tests/fixtures/windows.json"
export FIXTURE_DISPLAYS="$PWD/tests/fixtures/displays.json"

finish_output="$(DRY_RUN=1 zsh scripts/run_action.sh finish-recording)"
[[ "$finish_output" == "open screen-studio://finish-recording" ]]

display_output="$(DRY_RUN=1 zsh scripts/run_action.sh record-display "Studio")"
[[ "$display_output" == *"open screen-studio://record-display"* ]]
[[ "$display_output" == *"move 2792 720"* ]]
[[ "$display_output" == *"press-enter"* ]]

window_output="$(DRY_RUN=1 zsh scripts/run_action.sh record-window "Pricing")"
[[ "$window_output" == *"open screen-studio://record-window"* ]]
[[ "$window_output" == *"activate Google Chrome"* ]]
[[ "$window_output" == *"move 740 530"* ]]
[[ "$window_output" == *"press-enter"* ]]

encoded_display_output="$(DRY_RUN=1 zsh scripts/run_action.sh 'record-display|studio-display|2792|720')"
[[ "$encoded_display_output" == *"open screen-studio://record-display"* ]]
[[ "$encoded_display_output" == *"move 2792 720"* ]]

encoded_window_output="$(DRY_RUN=1 zsh scripts/run_action.sh 'record-window|chrome-pricing|Google Chrome|740|530')"
[[ "$encoded_window_output" == *"open screen-studio://record-window"* ]]
[[ "$encoded_window_output" == *"activate Google Chrome"* ]]

fallback_display_output="$(DRY_RUN=1 FIXTURE_DISPLAYS="$PWD/tests/fixtures/displays.json" zsh scripts/run_action.sh record-display 'missing-display')"
[[ "$fallback_display_output" == "open screen-studio://record-display" ]]

fallback_window_output="$(DRY_RUN=1 FIXTURE_WINDOWS="$PWD/tests/fixtures/windows.json" zsh scripts/run_action.sh record-window 'missing-window')"
[[ "$fallback_window_output" == "open screen-studio://record-window" ]]

trimmed_manual_output="$(DRY_RUN=1 zsh scripts/run_action.sh '   record-display   ' '   ')"
[[ "$trimmed_manual_output" == "open screen-studio://record-display" ]]
