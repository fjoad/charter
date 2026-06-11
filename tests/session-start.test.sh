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
assert_contains "$out" "/charter-help" "orient block points the AI at /charter-help (discoverability)"

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

# --- Edge case tests ---

setup_branch_with_dots() {
  setup_main_with_status
  git checkout -q -b feat/v0.2.0-hardening
  mkdir -p docs/plans
  cat > docs/plans/2026-05-12-v0-2-0-hardening.md <<EOF
# Hardening Plan
EOF
}

setup_branch_with_capitals() {
  setup_main_with_status
  git checkout -q -b feat/MIXED-Case-Branch
  mkdir -p docs/plans
  cat > docs/plans/2026-05-12-mixed-case-branch.md <<EOF
# Mixed Case Plan
EOF
}

setup_branch_with_short_tail_no_frontmatter() {
  setup_main_with_status
  git checkout -q -b feat/x
  mkdir -p docs/plans
  # Plan contains "x" but shouldn't match because branch slug is too short
  cat > docs/plans/2026-05-12-extensive-refactor.md <<EOF
# Extensive Refactor Plan
EOF
}

setup_branch_with_short_tail_and_frontmatter() {
  setup_main_with_status
  git checkout -q -b feat/x
  mkdir -p docs/plans
  cat > docs/plans/2026-05-12-explicit-match.md <<EOF
---
branch: feat/x
---

# Explicit Match Plan
EOF
}

setup_branch_with_multiple_slashes() {
  setup_main_with_status
  git checkout -q -b user/feat/branch-handling-extra
  mkdir -p docs/plans
  cat > docs/plans/2026-05-12-branch-handling-extra.md <<EOF
# Multi-slash Plan
EOF
}

echo "  scenario: branch with dots (v0.2.0)"
out=$(run_hook_in_temp setup_branch_with_dots)
assert_contains "$out" "Branch Plan: 2026-05-12-v0-2-0-hardening.md" "dots in branch tail slugify to dashes and match"

echo "  scenario: branch with capitals"
out=$(run_hook_in_temp setup_branch_with_capitals)
assert_contains "$out" "Branch Plan: 2026-05-12-mixed-case-branch.md" "capitals are slugified to lowercase before matching"

echo "  scenario: short branch tail, no frontmatter (false-positive guard)"
out=$(run_hook_in_temp setup_branch_with_short_tail_no_frontmatter)
assert_contains "$out" "No plan file detected for this branch" "min-length guard prevents single-char false positives"
assert_not_contains "$out" "Branch Plan: 2026-05-12-extensive-refactor.md" "no spurious match on short branch slug"

echo "  scenario: short branch tail, with frontmatter (explicit declaration wins)"
out=$(run_hook_in_temp setup_branch_with_short_tail_and_frontmatter)
assert_contains "$out" "Branch Plan: 2026-05-12-explicit-match.md" "frontmatter match works even when slug is too short"

echo "  scenario: branch with multiple slashes (use last segment)"
out=$(run_hook_in_temp setup_branch_with_multiple_slashes)
assert_contains "$out" "Branch Plan: 2026-05-12-branch-handling-extra.md" "branch with multiple slashes matches on last segment"

# --- CONTEXT.md / working memory tests ---

setup_main_with_status_and_context() {
  setup_main_with_status
  cat > docs/CONTEXT.md <<EOF
# Test Project — Working Memory

## Environment Quirks

- The mock server takes 8s to warm up after restart (don't retry sooner)

## Working Patterns

- Use \`make test-fast\` for unit tests, \`make test-all\` only before push
EOF
}

setup_main_with_status_no_context() {
  setup_main_with_status
  # Explicit: no CONTEXT.md
}

setup_feature_branch_with_context() {
  setup_main_with_status_and_context
  git checkout -q -b feat/has-context
  mkdir -p docs/plans
  cat > docs/plans/2026-05-12-has-context.md <<EOF
# Has Context Plan
EOF
}

echo "  scenario: scaffold on main with CONTEXT.md"
out=$(run_hook_in_temp setup_main_with_status_and_context)
assert_contains "$out" "Working Memory" "Working Memory section header surfaces"
assert_contains "$out" "mock server takes 8s" "CONTEXT.md content surfaces"
assert_contains "$out" "make test-fast" "all CONTEXT.md sections surface"

echo "  scenario: scaffold on main WITHOUT CONTEXT.md (backward compat)"
out=$(run_hook_in_temp setup_main_with_status_no_context)
assert_not_contains "$out" "Working Memory" "no Working Memory header when CONTEXT.md absent"
assert_contains "$out" "Test Project Status" "STATUS.md still surfaces normally"

echo "  scenario: feature branch with both CONTEXT.md and branch plan"
out=$(run_hook_in_temp setup_feature_branch_with_context)
assert_contains "$out" "Working Memory" "CONTEXT.md surfaces on feature branch too"
assert_contains "$out" "On branch: feat/has-context" "branch context still works"
assert_contains "$out" "Branch Plan: 2026-05-12-has-context.md" "branch plan still surfaces"

# --- Token budget: skip completed plans, truncate long files (v0.8.0) ---

setup_main_with_completed_plan() {
  setup_main_with_status
  mkdir -p docs/plans
  cat > docs/plans/2026-06-01-shipped-thing.md <<EOF
# Shipped Thing Plan

**Status:** ✅ Complete (2026-06-01) — all done, merged.

## Goal

COMPLETED_PLAN_BODY_MARKER this plan is history.
EOF
}

setup_main_with_long_inprogress_plan() {
  setup_main_with_status
  mkdir -p docs/plans
  {
    echo "# Big Active Plan"
    echo ""
    echo "**Status:** In progress"
    echo ""
    for i in $(seq 1 100); do echo "- step $i of the big plan"; done
    echo "LATE_PLAN_CONTENT_MARKER should not be injected"
  } > docs/plans/2026-06-01-big-active.md
}

setup_main_with_long_context() {
  setup_main_with_status
  {
    echo "# Test — Working Memory"
    for i in $(seq 1 250); do echo "- context entry number $i with some words in it"; done
    echo "LATE_CONTEXT_MARKER should not be injected"
  } > docs/CONTEXT.md
}

setup_budget_adversarial() {
  setup_main_with_status
  {
    echo "# Test — Working Memory"
    for i in $(seq 1 600); do echo "- context entry $i: a realistic-length working memory line with details in it"; done
  } > docs/CONTEXT.md
  mkdir -p docs/plans
  {
    echo "# Gigantic Plan"
    echo "**Status:** In progress"
    for i in $(seq 1 1200); do echo "- task $i: implement the thing and verify the other thing"; done
  } > docs/plans/2026-06-01-gigantic.md
}

echo "  scenario: completed plan on main is NOT injected"
out=$(run_hook_in_temp setup_main_with_completed_plan)
assert_not_contains "$out" "COMPLETED_PLAN_BODY_MARKER" "completed plan body absent"
assert_not_contains "$out" "Active Plan:" "no Active Plan section for a completed plan"

echo "  scenario: long in-progress plan on main is truncated"
out=$(run_hook_in_temp setup_main_with_long_inprogress_plan)
assert_contains "$out" "Active Plan: 2026-06-01-big-active.md" "in-progress plan still surfaces"
assert_contains "$out" "step 5 of the big plan" "early plan content present"
assert_not_contains "$out" "LATE_PLAN_CONTENT_MARKER" "late plan content truncated away"
assert_contains "$out" "truncated at 40" "plan truncation marker present"

echo "  scenario: long CONTEXT.md is truncated with pruning nudge"
out=$(run_hook_in_temp setup_main_with_long_context)
assert_contains "$out" "context entry number 5" "early CONTEXT content present"
assert_not_contains "$out" "LATE_CONTEXT_MARKER" "late CONTEXT content truncated away"
assert_contains "$out" "prune" "truncation marker nudges pruning per context-discipline"

echo "  scenario: short files get no truncation markers (backward compat)"
out=$(run_hook_in_temp setup_main_with_status_and_context)
assert_not_contains "$out" "truncated at" "no truncation marker for short files"

echo "  scenario: adversarial fixture stays under the orient budget"
out=$(run_hook_in_temp setup_budget_adversarial)
out_len=${#out}
if [[ "$out_len" -lt 24000 ]]; then
  assert_eq "under" "under" "orient block under 24,000 chars (actual: $out_len)"
else
  assert_eq "under" "OVER:$out_len" "orient block under 24,000 chars"
fi
