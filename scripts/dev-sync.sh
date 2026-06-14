#!/usr/bin/env bash
# dev-sync.sh — refresh the installed Charter plugin from GitHub after a release,
# then prune orphaned version dirs from the plugin cache.
#
# Wraps the two SUPPORTED Claude Code CLI commands (no hand-editing of
# ~/.claude/plugins internal state to force an update — that path is fragile
# and forbidden, see AGENTS.md § Iterating on Charter):
#
#   claude plugin marketplace update <marketplace>
#   claude plugin update <plugin@marketplace>
#
# Pruning is cleanup of UNREFERENCED files after the CLI update (the active
# version dir, per installed_plugins.json, is always kept) — not state surgery.
#
# Run this as the last step of the release finish ritual (workflow.md),
# so your own install is never behind your own release.
#
# NOTE: `set -euo pipefail` is applied inside the direct-execution guard at the
# bottom, NOT at top level — otherwise sourcing this file for its functions
# (as tests do) would leak `set -e` into the caller's shell.

# prune_cache <cache_root> <keep_name>
# Remove every immediate subdirectory of cache_root except keep_name.
# Safety: no-op if keep_name is empty (never wipe everything) or root missing.
prune_cache() {
  local cache_root="$1" keep="$2"
  [[ -n "$keep" ]] || { echo "  (prune skipped: no active version identified)"; return 0; }
  [[ -d "$cache_root" ]] || return 0
  local d name removed=0
  for d in "$cache_root"/*/; do
    [[ -d "$d" ]] || continue
    name="$(basename "$d")"
    if [[ "$name" != "$keep" ]]; then
      rm -rf "$d"
      echo "  pruned orphan version: $name"
      removed=$((removed + 1))
    fi
  done
  [[ "$removed" -eq 0 ]] && echo "  (no orphan versions to prune)"
  return 0
}

# active_install_path <plugin-key-substring>
# Echo the installPath of the matching installed plugin, or empty.
active_install_path() {
  local match="$1"
  python3 - "$match" <<'PY' 2>/dev/null || true
import json, os, sys
match = sys.argv[1]
p = os.path.expanduser("~/.claude/plugins/installed_plugins.json")
try:
    d = json.load(open(p))
except Exception:
    sys.exit(0)
for key, entries in d.get("plugins", {}).items():
    if match in key:
        for e in entries:
            ip = e.get("installPath")
            if ip:
                print(ip)
                sys.exit(0)
PY
}

main() {
  local repo_dir
  repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  local marketplace="${CHARTER_MARKETPLACE:-fjoad-charter}"
  local plugin_id="${CHARTER_PLUGIN_ID:-charter@fjoad-charter}"

  cd "$repo_dir"

  # The marketplace pulls from GitHub — syncing unpushed work is a no-op.
  git fetch -q origin 2>/dev/null || true
  local ahead
  ahead=$(git rev-list --count origin/main..main 2>/dev/null || echo "?")
  if [[ "$ahead" != "0" ]]; then
    echo "✗ main is $ahead commit(s) ahead of origin/main — push first, then re-run." >&2
    exit 1
  fi
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "⚠ working tree has uncommitted changes — they won't be in the synced install (it pulls from GitHub)." >&2
  fi

  echo "→ updating marketplace clone: $marketplace"
  claude plugin marketplace update "$marketplace"

  echo "→ updating installed plugin: $plugin_id"
  claude plugin update "$plugin_id"

  echo "→ pruning orphaned cache versions"
  local active
  active="$(active_install_path "charter")"
  if [[ -n "$active" ]]; then
    prune_cache "$(dirname "$active")" "$(basename "$active")"
  else
    echo "  (prune skipped: could not read active install path)"
  fi

  echo ""
  echo "✓ synced. Restart Claude Code (new session) for the updated plugin to load."
}

# Run main only when executed directly, so tests can source for prune_cache.
# set -e/-u/-o pipefail live here (not top level) to avoid leaking into a
# sourcing caller's shell.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail
  main "$@"
fi
