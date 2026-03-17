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

assert has_object('alfred.workflow.input.scriptfilter', 'ssd', True)
assert has_object('alfred.workflow.input.scriptfilter', 'ssw', True)
assert has_object('alfred.workflow.input.scriptfilter', 'ss', True)

for obj in objects:
    if obj.get('type') == 'alfred.workflow.input.keyword':
        assert obj.get('config', {}).get('keyword') not in {'ssd', 'ssw'}
        assert obj.get('config', {}).get('argumenttype') == 2
    if obj.get('type') == 'alfred.workflow.input.scriptfilter':
        assert obj.get('config', {}).get('withspace') is True
        assert obj.get('config', {}).get('argumenttype') == 1
PY
