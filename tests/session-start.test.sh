#!/usr/bin/env bash
# Behavior tests for hooks/session-start.sh.
# Each test sets up a temp dir, runs the hook from that dir, and asserts on stdout.

# shellcheck source=lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/assert.sh"

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/hooks/session-start.sh"

# Helper: run hook in an isolated temp dir with optional file setup.
# Usage: out=$(run_hook_in_temp <setup_function>)
run_hook_in_temp() {
  local setup_fn="$1"
  local tmpdir
  tmpdir=$(mktemp -d)
  pushd "$tmpdir" >/dev/null
  git init -q -b main 2>/dev/null || git init -q
  git config user.email "test@test.test"
  git config user.name "test"
  # Establish HEAD = main with an initial commit so non-main branches are detectable
  echo "init" > .gitkeep
  git add .gitkeep
  git commit -q -m "init"
  # Try to ensure branch is named "main" (handles older git defaults)
  git branch -m main 2>/dev/null || true
  "$setup_fn"
  local output
  output=$(bash "$HOOK" 2>&1 || true)
  popd >/dev/null
  rm -rf "$tmpdir"
  printf '%s' "$output"
}

# Setup helpers
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

setup_main_with_status_and_plan() {
  setup_main_with_status
  mkdir -p docs/plans
  cat > docs/plans/2026-05-01-feature-x.md <<EOF
# Feature X Plan

Some plan content.
EOF
}

# --- Tests ---

echo "  scenario: no Charter scaffold"
out=$(run_hook_in_temp setup_no_scaffold)
assert_contains "$out" "no Charter scaffold" "suggests setup when no STATUS.md"

echo "  scenario: scaffold on main, no plan"
out=$(run_hook_in_temp setup_main_with_status)
assert_contains "$out" "Test Project Status" "STATUS.md content appears in output"
assert_contains "$out" "Charter: Project Orientation" "orient block header appears"
assert_not_contains "$out" "Active Plan:" "no plan section when no plans exist"

echo "  scenario: scaffold on main, with plan"
out=$(run_hook_in_temp setup_main_with_status_and_plan)
assert_contains "$out" "Test Project Status" "STATUS.md content appears"
assert_contains "$out" "Active Plan: 2026-05-01-feature-x.md" "latest plan surfaces by name"

# --- Branch-aware tests ---

setup_feature_branch_with_matching_plan() {
  setup_main_with_status
  git checkout -q -b feat/branch-handling
  mkdir -p docs/plans
  cat > docs/plans/2026-05-12-branch-handling.md <<EOF
# Branch Handling Plan

Branch-specific plan content.
EOF
}

setup_feature_branch_no_plan() {
  setup_main_with_status
  git checkout -q -b feat/other-thing
}

setup_feature_branch_with_frontmatter_match() {
  setup_main_with_status
  git checkout -q -b weird-name-xyz
  mkdir -p docs/plans
  cat > docs/plans/2026-05-12-totally-different-slug.md <<EOF
---
branch: weird-name-xyz
---

# Plan tied to branch via frontmatter
EOF
}

echo "  scenario: feature branch with matching plan"
out=$(run_hook_in_temp setup_feature_branch_with_matching_plan)
assert_contains "$out" "On branch: feat/branch-handling" "branch is named in output"
assert_contains "$out" "Branch Plan: 2026-05-12-branch-handling.md" "matching plan is surfaced"
assert_contains "$out" "Branch Handling Plan" "plan content appears"

echo "  scenario: feature branch, no matching plan"
out=$(run_hook_in_temp setup_feature_branch_no_plan)
assert_contains "$out" "On branch: feat/other-thing" "branch is named"
assert_contains "$out" "No plan file detected for this branch" "soft hint suggests /charter-adopt"
assert_contains "$out" "/charter-adopt branches" "hint mentions the opt-in command"

echo "  scenario: feature branch, plan matched by frontmatter"
out=$(run_hook_in_temp setup_feature_branch_with_frontmatter_match)
assert_contains "$out" "Branch Plan: 2026-05-12-totally-different-slug.md" "frontmatter match works"
