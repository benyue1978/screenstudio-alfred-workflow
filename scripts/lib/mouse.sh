#!/bin/zsh
set -euo pipefail

move_mouse_to_point() {
  local x="$1"
  local y="$2"
  local settle="${3:-0.8}"

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    print -r -- "move $x $y"
    return
  fi

  swift -e "import Foundation
import CoreGraphics
let p = CGPoint(x: Double(\"$x\")!, y: Double(\"$y\")!)
if let move = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: p, mouseButton: .left) {
  move.post(tap: .cghidEventTap)
}
Thread.sleep(forTimeInterval: Double(\"$settle\")!)
"
}

press_enter() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    print -r -- "press-enter"
    return
  fi

  osascript <<'EOF'
tell application "System Events"
  key code 36
end tell
EOF
}

activate_app() {
  local app_name="$1"

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    print -r -- "activate $app_name"
    return
  fi

  osascript -e "tell application \"$app_name\" to activate"
}
