#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

version="$(zsh .github/scripts/release_version.sh)"
[[ "$version" == "0.1.0" ]]

tag_output="$(zsh .github/scripts/validate_release_tag.sh v0.1.0)"
[[ "$tag_output" == "v0.1.0" ]]
