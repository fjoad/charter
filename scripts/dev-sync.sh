#!/usr/bin/env bash
# dev-sync.sh — refresh the installed Charter plugin from GitHub after a release.
#
# Wraps the two SUPPORTED Claude Code CLI commands (no hand-editing of
# ~/.claude/plugins internal state — that path is fragile and forbidden,
# see AGENTS.md § Iterating on Charter):
#
#   claude plugin marketplace update <marketplace>
#   claude plugin update <plugin@marketplace>
#
# Run this as the last step of the release finish ritual (workflow.md),
# so your own install is never behind your own release.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MARKETPLACE="${CHARTER_MARKETPLACE:-fjoad-charter}"
PLUGIN_ID="${CHARTER_PLUGIN_ID:-charter@fjoad-charter}"

cd "$REPO_DIR"

# The marketplace pulls from GitHub — syncing unpushed work is a no-op.
git fetch -q origin 2>/dev/null || true
AHEAD=$(git rev-list --count origin/main..main 2>/dev/null || echo "?")
if [[ "$AHEAD" != "0" ]]; then
  echo "✗ main is $AHEAD commit(s) ahead of origin/main — push first, then re-run." >&2
  exit 1
fi
if [[ -n "$(git status --porcelain)" ]]; then
  echo "⚠ working tree has uncommitted changes — they won't be in the synced install (it pulls from GitHub)." >&2
fi

echo "→ updating marketplace clone: $MARKETPLACE"
claude plugin marketplace update "$MARKETPLACE"

echo "→ updating installed plugin: $PLUGIN_ID"
claude plugin update "$PLUGIN_ID"

echo ""
echo "✓ synced. Restart Claude Code (new session) for the updated plugin to load."
