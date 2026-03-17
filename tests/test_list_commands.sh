#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

output="$(zsh scripts/list_commands.sh "")"
[[ "$output" == *'"items"'* ]]
[[ "$output" == *'record-window'* ]]
[[ "$output" == *'record-display'* ]]
[[ "$output" == *'open-settings'* ]]

main_filtered="$(zsh scripts/list_commands.sh "record-display")"
[[ "$main_filtered" == *'screen-studio.record-display'* ]]
[[ "$main_filtered" != *'screen-studio.display.manual'* ]]

no_delegation="$(FIXTURE_WINDOWS="$PWD/tests/fixtures/windows.json" zsh scripts/list_commands.sh "record-window Pricing")"
[[ "$no_delegation" != *'chrome-pricing'* ]]

window_manual="$(FIXTURE_WINDOWS="$PWD/tests/fixtures/windows.json" zsh scripts/list_windows.sh "")"
[[ "$window_manual" == *'Record Window Manually'* ]]
[[ "$window_manual" == *'chrome-pricing'* ]]

display_manual="$(FIXTURE_DISPLAYS="$PWD/tests/fixtures/displays.json" zsh scripts/list_displays.sh "")"
[[ "$display_manual" == *'Record Display Manually'* ]]
[[ "$display_manual" == *'studio-display'* ]]

trimmed_window_manual="$(FIXTURE_WINDOWS="$PWD/tests/fixtures/windows.json" zsh scripts/list_windows.sh "    ")"
[[ "$trimmed_window_manual" == *'Record Window Manually'* ]]
[[ "$trimmed_window_manual" == *'chrome-pricing'* ]]

trimmed_display_manual="$(FIXTURE_DISPLAYS="$PWD/tests/fixtures/displays.json" zsh scripts/list_displays.sh "    ")"
[[ "$trimmed_display_manual" == *'Record Display Manually'* ]]
[[ "$trimmed_display_manual" == *'studio-display'* ]]

no_window_match="$(FIXTURE_WINDOWS="$PWD/tests/fixtures/windows.json" zsh scripts/list_windows.sh "missing-target")"
[[ "$no_window_match" == *'No matching windows'* ]]

no_display_match="$(FIXTURE_DISPLAYS="$PWD/tests/fixtures/displays.json" zsh scripts/list_displays.sh "missing-display")"
[[ "$no_display_match" == *'No matching displays'* ]]
