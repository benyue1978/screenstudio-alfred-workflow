#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

source scripts/lib/deeplinks.sh

[[ "$(deeplink_url record-window)" == "screen-studio://record-window" ]]
[[ "$(deeplink_url record-display)" == "screen-studio://record-display" ]]
[[ "$(deeplink_url record-area)" == "screen-studio://record-area" ]]
[[ "$(deeplink_url finish-recording)" == "screen-studio://finish-recording" ]]
[[ "$(deeplink_url cancel-recording)" == "screen-studio://cancel-recording" ]]
[[ "$(deeplink_url restart-recording)" == "screen-studio://restart-recording" ]]
[[ "$(deeplink_url toggle-recording-area-cover)" == "screen-studio://toggle-recording-area-cover" ]]
[[ "$(deeplink_url toggle-recording-controls)" == "screen-studio://toggle-recording-controls" ]]
[[ "$(deeplink_url open-projects-folder)" == "screen-studio://open-projects-folder" ]]
[[ "$(deeplink_url open-settings)" == "screen-studio://open-settings" ]]
[[ "$(deeplink_url copy-and-zip-project)" == "screen-studio://copy-and-zip-project" ]]
