#!/bin/zsh
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
source "$script_dir/lib/common.sh"
source "$script_dir/lib/json.sh"
source "$script_dir/lib/windows.sh"

query="$(trim_whitespace "${1-}")"
first_item=1
records=("${(@f)$(match_windows "$query")}")
nonempty_record_count="$(print -r -- "${records[@]}" | sed '/^$/d' | wc -l | tr -d ' ')"

alfred_items_open
alfred_item "Record Window Manually" "Open Screen Studio window picker without auto-selection" "record-window" "screen-studio.window.manual" true
first_item=0

if [[ -n "$query" && "$nonempty_record_count" == "0" ]]; then
  print -n -- ","
  alfred_item "No matching windows" "Press Enter on the first item to open the picker manually" "" "screen-studio.window.no-match" false
fi
for record in "${records[@]}"; do
  IFS=$'\t' read -r id app_name title center_x center_y <<< "$record"
  [[ -z "$id" ]] && continue
  if [[ $first_item -eq 0 ]]; then
    print -n -- ","
  fi
  alfred_item "$app_name" "$title" "record-window|$id|$app_name|$center_x|$center_y" "screen-studio.window.$id" true
  first_item=0
done
alfred_items_close
