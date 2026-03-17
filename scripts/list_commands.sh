#!/bin/zsh
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
source "$script_dir/lib/common.sh"
source "$script_dir/lib/json.sh"
source "$script_dir/lib/deeplinks.sh"

query="$(trim_whitespace "${1-}")"
query_lc="${query:l}"
first_item=1

matches_query() {
  local haystack="${1:l}"
  [[ -z "$query_lc" || "$haystack" == *${query_lc}* ]]
}

item_subtitle() {
  local action_id="$1"

  if [[ "$(deeplink_supports_target "$action_id")" == "1" ]]; then
    print -r -- "Press Enter to open picker, or keep typing to target a specific item"
  else
    print -r -- "$(deeplink_url "$action_id")"
  fi
}

alfred_items_open
for action_id in $(deeplink_ids); do
  title="$(deeplink_title "$action_id")"
  alias_text="$(deeplink_aliases "$action_id")"
  if ! matches_query "$action_id $title $alias_text"; then
    continue
  fi

  if [[ $first_item -eq 0 ]]; then
    print -n -- ","
  fi
  alfred_item "$title" "$(item_subtitle "$action_id")" "$action_id" "screen-studio.$action_id" true
  first_item=0
done
alfred_items_close
