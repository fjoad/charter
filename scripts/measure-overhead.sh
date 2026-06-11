#!/usr/bin/env bash
# measure-overhead.sh — measure the actual size of Charter's session-start
# orient block for a project.
#
# Usage:
#   bash scripts/measure-overhead.sh [project-dir]   (default: current dir)
#
# Runs hooks/session-start.sh from the given directory, extracts the
# additionalContext payload, and reports chars / lines / approximate tokens
# (chars ÷ 4). This is what /charter-cost uses for the orient-block number,
# and what TOKEN-BUDGET.md's measurements come from.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$REPO_DIR/hooks/session-start.sh"
TARGET="${1:-.}"

if [[ ! -d "$TARGET" ]]; then
  echo "error: not a directory: $TARGET" >&2
  exit 2
fi

RAW=$(cd "$TARGET" && bash "$HOOK")

printf '%s' "$RAW" | python3 -c '
import sys, json
raw = sys.stdin.read()
try:
    ctx = json.loads(raw)["additionalContext"]
except Exception as e:
    sys.stderr.write(f"error: could not parse hook output: {e}\n")
    sys.exit(1)
chars = len(ctx)
lines = ctx.count("\n") + 1
tokens = chars // 4
print(f"orient block: {chars} chars | {lines} lines | ~{tokens} tokens")
# Match the exact marker emitted by truncate_file() in session-start.sh,
# not loose phrases that project docs might legitimately contain.
truncated = ctx.count("for the rest.)")
if truncated:
    print(f"truncation markers active: {truncated}")
'
