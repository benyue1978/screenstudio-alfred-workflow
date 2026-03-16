#!/bin/zsh
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
stage_dir="$(mktemp -d)"
artifact_path="$repo_root/workflow/Screen Studio.alfredworkflow"

cleanup() {
  rm -rf "$stage_dir"
}
trap cleanup EXIT

mkdir -p "$stage_dir/scripts"
cp "$repo_root/workflow/src/info.plist" "$stage_dir/info.plist"
cp -R "$repo_root/scripts" "$stage_dir/"

if [[ -f "$repo_root/workflow/icon.png" ]]; then
  cp "$repo_root/workflow/icon.png" "$stage_dir/icon.png"
fi

if [[ -f "$repo_root/README.md" ]]; then
  cp "$repo_root/README.md" "$stage_dir/README.md"
fi

rm -f "$artifact_path"
(
  cd "$stage_dir"
  zip -qr "$artifact_path" .
)

print -r -- "$artifact_path"
