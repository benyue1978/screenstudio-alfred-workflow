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

screenstudio_log_dir() {
  if [[ -n "${SCREENSTUDIO_LOG_DIR:-}" ]]; then
    print -r -- "$SCREENSTUDIO_LOG_DIR"
    return
  fi

  if [[ -n "${alfred_workflow_data:-}" ]]; then
    print -r -- "$alfred_workflow_data"
    return
  fi

  print -r -- "$(repo_root)/.screenstudio-logs"
}

screenstudio_log_file() {
  print -r -- "$(screenstudio_log_dir)/screenstudio.log"
}

log_event() {
  local log_dir log_file timestamp
  log_dir="$(screenstudio_log_dir)"
  mkdir -p "$log_dir"
  log_file="$(screenstudio_log_file)"
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  print -r -- "$timestamp | $*" >> "$log_file"
}
