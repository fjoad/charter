#!/usr/bin/env bash
# Charter session-start hook
# Detects Charter scaffold and injects current project state into Claude's context.
# Outputs JSON { "additionalContext": "..." } or exits silently if no scaffold.

set -euo pipefail

STATUS_FILE="docs/STATUS.md"

# Only fire if this project has a Charter scaffold
if [[ ! -f "$STATUS_FILE" ]]; then
  exit 0
fi

# Read STATUS.md
STATUS_CONTENT=$(cat "$STATUS_FILE")

# Find the most recently modified plan (exclude TEMPLATE.md)
PLAN_CONTENT=""
if [[ -d "docs/plans" ]]; then
  LATEST_PLAN=$(ls -t docs/plans/*.md 2>/dev/null | grep -v 'TEMPLATE.md' | head -1 || true)
  if [[ -n "$LATEST_PLAN" && -f "$LATEST_PLAN" ]]; then
    PLAN_NAME=$(basename "$LATEST_PLAN")
    PLAN_CONTENT="

## Active Plan: ${PLAN_NAME}

$(cat "$LATEST_PLAN")"
  fi
fi

# Build orient block
ORIENT=$(cat <<ORIENT
## Charter: Project Orientation

You are starting a session in a Charter-managed project. Read the following before responding.

### Project Status

${STATUS_CONTENT}
${PLAN_CONTENT}

---

Session start ritual: read STATUS.md ✓ — you know where this project stands. Check docs/ARCHITECTURE.md if you need structural context. Check docs/VISION.md if you need to understand the thesis. Find the current step in "What to Work On Next" above and proceed.
ORIENT
)

# Output JSON for Claude Code hook system
printf '%s' "$ORIENT" | python3 -c "
import sys, json
content = sys.stdin.read()
print(json.dumps({'additionalContext': content}))
"
