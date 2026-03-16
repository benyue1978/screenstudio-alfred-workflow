#!/bin/zsh
set -euo pipefail

json_escape() {
  local value="${1-}"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  print -r -- "$value"
}

alfred_items_open() {
  print -n -- '{"items":['
}

alfred_item() {
  local title subtitle arg uid valid
  title="$(json_escape "${1-}")"
  subtitle="$(json_escape "${2-}")"
  arg="$(json_escape "${3-}")"
  uid="$(json_escape "${4-}")"
  valid="${5:-true}"

  print -n -- "{\"title\":\"$title\",\"subtitle\":\"$subtitle\",\"arg\":\"$arg\",\"uid\":\"$uid\",\"valid\":$valid}"
}

alfred_items_close() {
  print -- ']}'
}
