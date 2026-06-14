#!/usr/bin/env bash
# Tests for prune_cache() in scripts/dev-sync.sh.
# Sourcing dev-sync.sh defines its functions WITHOUT running main (source guard),
# so the real `claude plugin` CLI is never invoked here.

# shellcheck source=lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/assert.sh"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "$REPO_DIR/scripts/dev-sync.sh"

make_cache() {
  local root
  root=$(mktemp -d)
  mkdir -p "$root/0.3.0" "$root/0.6.0" "$root/0.9.0"
  printf '%s' "$root"
}

echo "  scenario: prune keeps active version, removes orphans"
ROOT=$(make_cache)
prune_cache "$ROOT" "0.9.0" >/dev/null
remaining=$(ls -1 "$ROOT")
assert_eq "0.9.0" "$remaining" "only the active version dir remains"
rm -rf "$ROOT"

echo "  scenario: empty keep_name is a no-op (safety — never wipe everything)"
ROOT=$(make_cache)
prune_cache "$ROOT" "" >/dev/null
count=$(ls -1 "$ROOT" | wc -l | tr -d ' ')
assert_eq "3" "$count" "no dirs deleted when keep_name is empty"
rm -rf "$ROOT"

echo "  scenario: missing cache_root is a no-op, no error"
prune_cache "/no/such/cache/root" "0.9.0" >/dev/null 2>/tmp/prune-err.txt
rc=$?
assert_eq "0" "$rc" "missing cache_root returns success (no-op)"
assert_eq "" "$(cat /tmp/prune-err.txt)" "missing cache_root produces no error output"

echo "  scenario: keep_name that isn't present removes all but warns nothing fatal"
ROOT=$(make_cache)
prune_cache "$ROOT" "99.0.0" >/dev/null
count=$(ls -1 "$ROOT" 2>/dev/null | wc -l | tr -d ' ')
assert_eq "0" "$count" "all orphans removed when active version dir is absent (CLI just recreated it)"
rm -rf "$ROOT"
