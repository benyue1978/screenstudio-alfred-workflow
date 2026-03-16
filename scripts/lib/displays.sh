#!/bin/zsh
set -euo pipefail

displays_lib_dir="$(cd "$(dirname "${(%):-%N}")" && pwd)"
source "$displays_lib_dir/common.sh"

read_display_records() {
  if [[ -n "${FIXTURE_DISPLAYS:-}" ]]; then
    osascript -l JavaScript <<'EOF'
const app = Application.currentApplication();
app.includeStandardAdditions = true;
ObjC.import("Foundation");
const path = ObjC.unwrap($.NSProcessInfo.processInfo.environment.objectForKey("FIXTURE_DISPLAYS"));
const raw = app.read(Path(path));
const items = JSON.parse(raw);
const lines = [];
for (const item of items) {
  const centerX = Math.floor(item.x + item.width / 2);
  const centerY = Math.floor(item.y + item.height / 2);
  lines.push([item.id, item.name, item.x, item.y, item.width, item.height, centerX, centerY].join("\t"));
}
lines.join("\n");
EOF
    return
  fi

  swift -e '
import AppKit
for (index, screen) in NSScreen.screens.enumerated() {
  let frame = screen.frame
  let centerX = Int(frame.origin.x + frame.size.width / 2.0)
  let centerY = Int(frame.origin.y + frame.size.height / 2.0)
  let id = "display-\(index + 1)"
  let name = screen.localizedName.replacingOccurrences(of: "\t", with: " ")
  print([id, name, String(Int(frame.origin.x)), String(Int(frame.origin.y)), String(Int(frame.size.width)), String(Int(frame.size.height)), String(centerX), String(centerY)].joined(separator: "\t"))
}
'
}

match_displays() {
  local query="${1-}"
  local query_lc="${query:l}"
  local record id name x y width height center_x center_y
  local -a records

  records=("${(@f)$(read_display_records)}")

  for record in "${records[@]}"; do
    IFS=$'\t' read -r id name x y width height center_x center_y <<< "$record"
    [[ -z "$id" ]] && continue
    if [[ -z "$query_lc" || "${name:l}" == *${query_lc}* ]]; then
      print -r -- "$id"$'\t'"$name"$'\t'"$center_x"$'\t'"$center_y"
    fi
  done
}
