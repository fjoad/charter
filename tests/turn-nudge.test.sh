#!/usr/bin/env bash
# Behavior tests for hooks/turn-nudge.sh.

# shellcheck source=lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/assert.sh"

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/hooks/turn-nudge.sh"

run_nudge_in_temp() {
  local setup_fn="$1"
  local tmpdir
  tmpdir=$(mktemp -d)
  pushd "$tmpdir" >/dev/null
  "$setup_fn"
  local output
  output=$(bash "$HOOK" 2>&1 || true)
  popd >/dev/null
  rm -rf "$tmpdir"
  printf '%s' "$output"
}

setup_no_scaffold_for_nudge() { :; }

setup_with_scaffold_for_nudge() {
  mkdir -p docs
  echo "# Status" > docs/STATUS.md
}

echo "  scenario: no Charter scaffold"
out=$(run_nudge_in_temp setup_no_scaffold_for_nudge)
assert_eq "" "$out" "turn-nudge produces no output without scaffold"

echo "  scenario: scaffold present"
out=$(run_nudge_in_temp setup_with_scaffold_for_nudge)
assert_contains "$out" "additionalContext" "turn-nudge emits JSON when scaffold present"
assert_contains "$out" "Classify this request" "nudge text mentions classification"
assert_contains "$out" "turn-ritual.md" "nudge points at the ritual rule"
