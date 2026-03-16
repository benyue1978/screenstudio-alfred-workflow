#!/bin/zsh
set -euo pipefail

repo_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${(%):-%N}")" && pwd)"
  cd "$script_dir/../.." && pwd
}

fatal() {
  print -u2 -- "Error: $*"
  exit 1
}

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fatal "Missing required command: $cmd"
}

trim_whitespace() {
  local value="${1-}"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  print -r -- "$value"
}
