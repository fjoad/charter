#!/usr/bin/env bash
# End-to-end install test for Charter v0.2.0.
#
# Spawns real Claude Code sessions via `claude -p --plugin-dir`, each in a
# fresh tmpdir set up to exercise a specific scenario. Captures hook events
# from the stream-json output and asserts on the SessionStart hook's
# `additionalContext` content.
#
# NOTE: Each scenario spawns an actual claude session (a small token cost).
# This is the test we can't do in pure shell — it verifies the plugin
# actually loads and the hook actually fires inside a real Claude session,
# not just that the script-under-test produces the right output.

set -uo pipefail

CHARTER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

# Run one claude session in $PWD with our plugin loaded, return raw stream-json.
# Uses a minimal prompt to keep the session cheap.
run_claude() {
  claude -p "say READY" \
    --plugin-dir "$CHARTER_ROOT" \
    --output-format=stream-json \
    --include-hook-events \
    --verbose \
    --no-session-persistence \
    --setting-sources user \
    2>&1
}

# Extract the additionalContext field from our Charter hook response.
# Our hook is the ONLY one that emits content matching "Charter: Project Orientation"
# or "no Charter scaffold" — we match by content, not hook_id (hook_ids are random per run).
extract_charter_context() {
  # Note: passing the script via -c, so stdin is free for piped input from caller.
  python3 -c '
import sys, json
def find():
    for line in sys.stdin:
        line = line.strip()
        if not line: continue
        try:
            obj = json.loads(line)
        except Exception:
            continue
        if obj.get("type") != "system": continue
        if obj.get("subtype") != "hook_response": continue
        if obj.get("hook_event") != "SessionStart": continue
        raw = obj.get("output", "")
        try:
            inner = json.loads(raw)
        except Exception:
            continue
        ctx = inner.get("additionalContext")
        if not ctx and isinstance(inner.get("hookSpecificOutput"), dict):
            ctx = inner["hookSpecificOutput"].get("additionalContext")
        if not ctx: continue
        if "Charter: Project Orientation" in ctx or "no Charter scaffold" in ctx:
            print(ctx)
            return
find()
'
}

# Assertion helpers
pass() { echo "  ✓ $*"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $*"; FAIL=$((FAIL + 1)); }

assert_contains() {
  local haystack="$1" needle="$2" msg="$3"
  if [[ "$haystack" == *"$needle"* ]]; then pass "$msg"; else
    fail "$msg"
    echo "    expected substring: $needle"
    echo "    actual (first 400 chars): ${haystack:0:400}"
  fi
}

# Scenarios
run_scenario() {
  local name="$1" setup_fn="$2"
  echo ""
  echo "▸ $name"
  local tmpdir
  tmpdir=$(mktemp -d)
  pushd "$tmpdir" >/dev/null
  git init -q -b main 2>/dev/null || git init -q
  git config user.email t@t.t
  git config user.name t
  echo init > .gitkeep
  git add .gitkeep
  git commit -q -m init
  git branch -m main 2>/dev/null || true
  "$setup_fn"
  local raw ctx
  raw=$(run_claude)
  ctx=$(printf '%s' "$raw" | extract_charter_context)
  popd >/dev/null
  rm -rf "$tmpdir"
  # Set CTX for caller assertions
  CTX="$ctx"
  RAW="$raw"
  if [[ -z "$CTX" ]]; then
    fail "Charter hook context not found in stream-json output"
    echo "    raw output (first 400 chars): ${raw:0:400}"
  fi
}

# Setup helpers (run inside the tmpdir, after git init and initial commit)
setup_no_scaffold() { :; }

setup_main_with_status() {
  mkdir -p docs
  cat > docs/STATUS.md <<EOF
# Test Project Status

**Current branch:** \`main\`

## What to Work On Next
1. **Build feature X**
EOF
}

setup_feature_branch_with_plan() {
  setup_main_with_status
  git checkout -q -b feat/test-feature
  mkdir -p docs/plans
  cat > docs/plans/2026-05-12-test-feature.md <<EOF
# Test Feature Plan

This is a fake plan for end-to-end testing.
EOF
}

setup_feature_branch_no_plan() {
  setup_main_with_status
  git checkout -q -b feat/orphan-branch
}

# --- Run scenarios ---

run_scenario "Scenario A: fresh project, no Charter scaffold" setup_no_scaffold
assert_contains "$CTX" "no Charter scaffold" "hook surfaces no-scaffold hint"
assert_contains "$CTX" "/charter-init" "hint mentions /charter-init"

run_scenario "Scenario B: project with scaffold on main" setup_main_with_status
assert_contains "$CTX" "Charter: Project Orientation" "orient block header present"
assert_contains "$CTX" "Test Project Status" "STATUS.md content surfaces"
assert_contains "$CTX" "Build feature X" "What to Work On Next surfaces"

run_scenario "Scenario C: on feature branch with matching plan" setup_feature_branch_with_plan
assert_contains "$CTX" "On branch: feat/test-feature" "branch is named"
assert_contains "$CTX" "Branch Plan: 2026-05-12-test-feature.md" "matching plan is surfaced"
assert_contains "$CTX" "fake plan for end-to-end testing" "plan content appears"

run_scenario "Scenario D: on feature branch with no plan" setup_feature_branch_no_plan
assert_contains "$CTX" "On branch: feat/orphan-branch" "branch is named"
assert_contains "$CTX" "No plan file detected for this branch" "soft hint appears"
assert_contains "$CTX" "/charter-adopt branches" "hint points at the opt-in command"

# --- Summary ---
echo ""
echo "==========================="
echo "E2E install test: $PASS passed, $FAIL failed"
if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
