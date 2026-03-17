#!/bin/zsh
set -euo pipefail

expected_tag="v$(zsh "$(dirname "$0")/release_version.sh")"
actual_tag="${1-}"

if [[ -z "$actual_tag" ]]; then
  print -u2 -- "Usage: $0 <tag>"
  exit 1
fi

if [[ "$actual_tag" != "$expected_tag" ]]; then
  print -u2 -- "Tag mismatch: expected $expected_tag, got $actual_tag"
  exit 1
fi

print -r -- "$actual_tag"
