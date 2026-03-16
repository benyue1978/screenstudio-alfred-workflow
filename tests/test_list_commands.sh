#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

output="$(zsh scripts/list_commands.sh "")"
[[ "$output" == *'"items"'* ]]
[[ "$output" == *'record-window'* ]]
[[ "$output" == *'record-display'* ]]
[[ "$output" == *'open-settings'* ]]

delegated_windows="$(FIXTURE_WINDOWS="$PWD/tests/fixtures/windows.json" zsh scripts/list_commands.sh "record-window Pricing")"
[[ "$delegated_windows" == *'chrome-pricing'* ]]
[[ "$delegated_windows" != *'chrome-docs'* ]]

delegated_displays="$(FIXTURE_DISPLAYS="$PWD/tests/fixtures/displays.json" zsh scripts/list_commands.sh "record-display Studio")"
[[ "$delegated_displays" == *'studio-display'* ]]

window_manual="$(FIXTURE_WINDOWS="$PWD/tests/fixtures/windows.json" zsh scripts/list_windows.sh "")"
[[ "$window_manual" == *'Record Window Manually'* ]]

display_manual="$(FIXTURE_DISPLAYS="$PWD/tests/fixtures/displays.json" zsh scripts/list_displays.sh "")"
[[ "$display_manual" == *'Record Display Manually'* ]]
