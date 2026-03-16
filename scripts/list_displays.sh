#!/bin/zsh
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
source "$script_dir/lib/json.sh"
source "$script_dir/lib/displays.sh"

query="${1-}"
first_item=1
records=("${(@f)$(match_displays "$query")}")

alfred_items_open
if [[ -z "$query" ]]; then
  alfred_item "Record Display Manually" "Open Screen Studio display picker without auto-selection" "record-display" "screen-studio.display.manual" true
  first_item=0
fi
for record in "${records[@]}"; do
  IFS=$'\t' read -r id name center_x center_y <<< "$record"
  [[ -z "$id" ]] && continue
  if [[ $first_item -eq 0 ]]; then
    print -n -- ","
  fi
  alfred_item "$name" "Move pointer to display center and press Enter" "record-display|$id|$center_x|$center_y" "screen-studio.display.$id" true
  first_item=0
done
alfred_items_close
