#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

rm -f "workflow/Screen Studio.alfredworkflow"
zsh workflow/build-workflow.sh >/dev/null

[[ -f "workflow/Screen Studio.alfredworkflow" ]]

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
unzip -q "workflow/Screen Studio.alfredworkflow" -d "$tmp_dir"

[[ -f "$tmp_dir/info.plist" ]]
[[ -f "$tmp_dir/scripts/run_action.sh" ]]
[[ -f "$tmp_dir/scripts/list_commands.sh" ]]
[[ -f "$tmp_dir/icon.png" ]]
