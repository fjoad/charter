#!/usr/bin/env bash
# Charter turn-nudge hook
# Injects ~20-token tier reminder before every user prompt.
# Only fires if this project has a Charter scaffold.

set -euo pipefail

STATUS_FILE="docs/STATUS.md"

# Only fire if this project has a Charter scaffold
if [[ ! -f "$STATUS_FILE" ]]; then
  exit 0
fi

NUDGE="Classify this request as trivial/small/medium/major and apply the matching ritual from .claude/rules/turn-ritual.md before responding."

printf '%s' "$NUDGE" | python3 -c "
import sys, json
content = sys.stdin.read()
print(json.dumps({'additionalContext': content}))
"
