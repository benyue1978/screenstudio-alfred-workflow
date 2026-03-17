#!/bin/zsh
set -euo pipefail

source "$(cd "$(dirname "$0")/.." && pwd)/scripts/lib/common.sh"
source "$(cd "$(dirname "$0")/.." && pwd)/scripts/lib/mouse.sh"

[[ "$(convert_display_center_to_cg_point 756 491)" == "756 491" ]]
[[ "$(convert_display_center_to_cg_point -489 1702)" == "-489 -720" ]]
[[ "$(mouse_target_point window 740 530)" == "740 530" ]]
[[ "$(mouse_target_point display -489 1702)" == "-489 -720" ]]

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
export SCREENSTUDIO_LOG_DIR="$tmp_dir"
log_event "test-event" "target=display-3" "x=-489" "y=1702"
[[ -f "$tmp_dir/screenstudio.log" ]]
grep -q "test-event" "$tmp_dir/screenstudio.log"
echo "ok"
