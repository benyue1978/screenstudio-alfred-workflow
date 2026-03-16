#!/bin/zsh
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
source "$script_dir/lib/common.sh"
source "$script_dir/lib/deeplinks.sh"
source "$script_dir/lib/windows.sh"
source "$script_dir/lib/displays.sh"
source "$script_dir/lib/mouse.sh"

picker_delay="${SCREENSTUDIO_PICKER_DELAY:-1.2}"
hover_settle="${SCREENSTUDIO_HOVER_SETTLE:-0.8}"

open_deeplink() {
  local url="$1"

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    print -r -- "open $url"
    return
  fi

  open "$url"
}

run_selected_display() {
  local id="$1"
  local center_x="$2"
  local center_y="$3"
  local url

  url="$(deeplink_url record-display)"
  open_deeplink "$url"
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    sleep "$picker_delay"
  fi
  move_mouse_to_point "$center_x" "$center_y" "$hover_settle"
  press_enter
}

run_selected_window() {
  local id="$1"
  local app_name="$2"
  local center_x="$3"
  local center_y="$4"
  local url

  url="$(deeplink_url record-window)"
  open_deeplink "$url"
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    sleep "$picker_delay"
  fi
  activate_app "$app_name"
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    sleep 0.4
  fi
  move_mouse_to_point "$center_x" "$center_y" "$hover_settle"
  press_enter
}

match_count() {
  local matches="$2"
  print -r -- "$matches" | sed '/^$/d' | wc -l | tr -d ' '
}

run_record_display() {
  local query
  local url
  local matches id name center_x center_y count

  query="$(trim_whitespace "${1-}")"
  url="$(deeplink_url record-display)"
  if [[ -z "$query" ]]; then
    open_deeplink "$url"
    return
  fi

  matches="$(match_displays "$query")"
  count="$(match_count display "$matches")"
  if [[ "$count" != "1" ]]; then
    open_deeplink "$url"
    return
  fi
  IFS=$'\t' read -r id name center_x center_y <<< "$matches"

  run_selected_display "$id" "$center_x" "$center_y"
}

run_record_window() {
  local query
  local url
  local matches id app_name title center_x center_y count

  query="$(trim_whitespace "${1-}")"
  url="$(deeplink_url record-window)"
  if [[ -z "$query" ]]; then
    open_deeplink "$url"
    return
  fi

  matches="$(match_windows "$query")"
  count="$(match_count window "$matches")"
  if [[ "$count" != "1" ]]; then
    open_deeplink "$url"
    return
  fi
  IFS=$'\t' read -r id app_name title center_x center_y <<< "$matches"

  run_selected_window "$id" "$app_name" "$center_x" "$center_y"
}

run_simple_action() {
  local action_id="$1"
  local url

  url="$(deeplink_url "$action_id")"
  if [[ -z "$url" ]]; then
    print -u2 -- "Unknown action: $action_id"
    exit 1
  fi
  open_deeplink "$url"
}

action_id="$(trim_whitespace "${1-}")"
query="$(trim_whitespace "${2-}")"

if [[ "$action_id" == *"|"* ]]; then
  IFS='|' read -r encoded_action encoded_id encoded_name encoded_x encoded_y <<< "$action_id"
  case "$encoded_action" in
    record-display)
      run_selected_display "$encoded_id" "$encoded_name" "$encoded_x"
      exit 0
      ;;
    record-window)
      run_selected_window "$encoded_id" "$encoded_name" "$encoded_x" "$encoded_y"
      exit 0
      ;;
  esac
fi

case "$action_id" in
  record-display)
    run_record_display "$query"
    ;;
  record-window)
    run_record_window "$query"
    ;;
  "")
    print -u2 -- "Usage: $0 <action-id> [query]"
    exit 1
    ;;
  *)
    run_simple_action "$action_id"
    ;;
esac
