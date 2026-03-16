#!/bin/zsh
set -euo pipefail

typeset -grA SCREENSTUDIO_DEEPLINKS=(
  record-display "screen-studio://record-display"
  record-window "screen-studio://record-window"
  record-area "screen-studio://record-area"
  finish-recording "screen-studio://finish-recording"
  cancel-recording "screen-studio://cancel-recording"
  restart-recording "screen-studio://restart-recording"
  toggle-recording-area-cover "screen-studio://toggle-recording-area-cover"
  toggle-recording-controls "screen-studio://toggle-recording-controls"
  open-projects-folder "screen-studio://open-projects-folder"
  open-settings "screen-studio://open-settings"
  copy-and-zip-project "screen-studio://copy-and-zip-project"
)

typeset -grA SCREENSTUDIO_TITLES=(
  record-display "Record Display"
  record-window "Record Window"
  record-area "Record Area"
  finish-recording "Finish Recording"
  cancel-recording "Cancel Recording"
  restart-recording "Restart Recording"
  toggle-recording-area-cover "Toggle Recording Area Cover"
  toggle-recording-controls "Toggle Recording Controls"
  open-projects-folder "Open Projects Folder"
  open-settings "Open Settings"
  copy-and-zip-project "Copy and Zip Project"
)

typeset -grA SCREENSTUDIO_ALIASES=(
  record-display "display monitor screen"
  record-window "window app title"
  record-area "area selection region"
  finish-recording "finish stop end"
  cancel-recording "cancel abort"
  restart-recording "restart redo"
  toggle-recording-area-cover "toggle area cover"
  toggle-recording-controls "toggle controls overlay"
  open-projects-folder "projects folder finder"
  open-settings "settings preferences"
  copy-and-zip-project "copy zip archive"
)

typeset -grA SCREENSTUDIO_TARGET_AWARE=(
  record-display 1
  record-window 1
  record-area 0
  finish-recording 0
  cancel-recording 0
  restart-recording 0
  toggle-recording-area-cover 0
  toggle-recording-controls 0
  open-projects-folder 0
  open-settings 0
  copy-and-zip-project 0
)

deeplink_ids() {
  print -- \
    "record-display" \
    "record-window" \
    "record-area" \
    "finish-recording" \
    "cancel-recording" \
    "restart-recording" \
    "toggle-recording-area-cover" \
    "toggle-recording-controls" \
    "open-projects-folder" \
    "open-settings" \
    "copy-and-zip-project"
}

deeplink_url() {
  local action_id="${1-}"
  print -r -- "${SCREENSTUDIO_DEEPLINKS[$action_id]-}"
}

deeplink_title() {
  local action_id="${1-}"
  print -r -- "${SCREENSTUDIO_TITLES[$action_id]-}"
}

deeplink_aliases() {
  local action_id="${1-}"
  print -r -- "${SCREENSTUDIO_ALIASES[$action_id]-}"
}

deeplink_supports_target() {
  local action_id="${1-}"
  print -r -- "${SCREENSTUDIO_TARGET_AWARE[$action_id]-0}"
}
