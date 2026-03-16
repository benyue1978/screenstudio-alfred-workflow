#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - <<'PY'
import plistlib

with open('workflow/src/info.plist', 'rb') as f:
    data = plistlib.load(f)

objects = data['objects']

def has_object(obj_type, keyword, withspace):
    for obj in objects:
        if obj.get('type') != obj_type:
            continue
        cfg = obj.get('config', {})
        if cfg.get('keyword') == keyword and cfg.get('withspace') == withspace:
            return True
    return False

assert has_object('alfred.workflow.input.keyword', 'ssd', False)
assert has_object('alfred.workflow.input.scriptfilter', 'ssd', True)
assert has_object('alfred.workflow.input.keyword', 'ssw', False)
assert has_object('alfred.workflow.input.scriptfilter', 'ssw', True)
PY
