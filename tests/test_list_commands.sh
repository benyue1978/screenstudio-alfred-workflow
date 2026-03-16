#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

output="$(zsh scripts/list_commands.sh "")"
[[ "$output" == *'"items"'* ]]
[[ "$output" == *'record-window'* ]]
[[ "$output" == *'record-display'* ]]
[[ "$output" == *'open-settings'* ]]
