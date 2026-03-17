#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/../.."

python3 - <<'PY'
import plistlib

with open('workflow/src/info.plist', 'rb') as f:
    data = plistlib.load(f)

print(data['version'])
PY
