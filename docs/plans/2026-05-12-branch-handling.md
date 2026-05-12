# Branch Handling Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add branch handling to Charter so feature-branch workflows work cleanly, with full backward compatibility — existing installations must keep working unchanged after updating.

**Architecture:** Behavior lives plugin-side (hooks, commands), conventions live user-side (STATUS.md, rules). The plugin uses **capability detection** — it asks "does this project have the optional structures for branch awareness?" rather than requiring them. Missing structures default to today's behavior, so old projects keep working untouched. Plans become the branch-scoped unit of work: each feature branch owns one plan file in `docs/plans/`; STATUS.md component sections are only edited at merge time, eliminating merge conflicts.

**Tech Stack:** Bash (hooks), Python3 (JSON encoding, already in use), Markdown (commands, rules, docs).

**Backward compatibility guarantees:**
- An existing Charter project that updates the plugin and does nothing else sees identical behavior to today.
- New behavior activates only when (a) the user is on a non-main branch *and* (b) optional structures are present.
- No required edits to user-side files. `/charter-adopt branches` is opt-in.
- The "Branch State" section in existing STATUS.md files is left untouched; the new convention uses a parallel "In-flight Branches" section that the hook reads when present.

---

## File Structure

**Plugin-side (updated by `claude plugin update charter`):**
- `hooks/session-start.sh` — modify: add branch detection and plan-matching
- `commands/charter-finish.md` — modify: branch-conditional finish flow
- `commands/charter-adopt.md` — create: opt-in convention installer
- `template/docs/STATUS.md` — modify: add optional "In-flight Branches" section for new projects
- `template/.claude/rules/workflow.md` — modify: add branch-discipline note (for new projects only)
- `.claude-plugin/plugin.json` — modify: bump version to 0.2.0
- `package.json` — modify: bump version to 0.2.0

**User-side (never auto-modified; only changed by `/charter-adopt branches` with user confirmation):**
- `docs/STATUS.md` (in user's project) — optional new "In-flight Branches" section
- `.claude/rules/workflow.md` (in user's project) — optional branch-discipline rule

**Charter's own dogfood (this project's docs):**
- `docs/STATUS.md` — add "In-flight Branches" section, mark feature in-flight
- `docs/ARCHITECTURE.md` — document branch handling design
- `AGENTS.md` — mention new command, branch behavior
- `README.md` — one line bullet about branch support
- `docs/decisions/2026-05-12-branch-handling.md` — ADR

**Test infrastructure (new):**
- `tests/run-tests.sh` — minimal shell test runner
- `tests/lib/assert.sh` — assertion helpers
- `tests/session-start.test.sh` — hook behavior under different branch/plan scenarios
- `scripts/verify-plugin.sh` — modify: invoke `tests/run-tests.sh` after structural checks

---

## CHECKPOINT 0: Plan approved

Before any implementation, the user reviews this plan and confirms scope. No code is written until the user signs off.

---

### Task 1: Create feature branch

**Files:**
- No file changes; git operation only

- [ ] **Step 1: Verify clean working tree**

```bash
git status
```

Expected: `nothing to commit, working tree clean` on `main`.

- [ ] **Step 2: Create and switch to feature branch**

```bash
git checkout -b feat/branch-handling
```

Expected: `Switched to a new branch 'feat/branch-handling'`

- [ ] **Step 3: Commit the plan file**

```bash
git add docs/plans/2026-05-12-branch-handling.md
git commit -m "docs: add branch-handling implementation plan"
```

---

### Task 2: Create test harness

**Files:**
- Create: `tests/run-tests.sh`
- Create: `tests/lib/assert.sh`

- [ ] **Step 1: Create assertion library**

Create `tests/lib/assert.sh`:

```bash
#!/usr/bin/env bash
# Minimal assertion helpers for shell tests.
# Each assertion increments PASS or FAIL and prints a result line.

ASSERT_PASS=0
ASSERT_FAIL=0

assert_eq() {
  local expected="$1"
  local actual="$2"
  local msg="${3:-assertion}"
  if [[ "$expected" == "$actual" ]]; then
    echo "  ✓ $msg"
    ASSERT_PASS=$((ASSERT_PASS + 1))
  else
    echo "  ✗ $msg"
    echo "    expected: $expected"
    echo "    actual:   $actual"
    ASSERT_FAIL=$((ASSERT_FAIL + 1))
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local msg="${3:-contains check}"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "  ✓ $msg"
    ASSERT_PASS=$((ASSERT_PASS + 1))
  else
    echo "  ✗ $msg"
    echo "    expected to contain: $needle"
    echo "    actual:              $haystack"
    ASSERT_FAIL=$((ASSERT_FAIL + 1))
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local msg="${3:-not-contains check}"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "  ✓ $msg"
    ASSERT_PASS=$((ASSERT_PASS + 1))
  else
    echo "  ✗ $msg"
    echo "    expected NOT to contain: $needle"
    echo "    actual:                  $haystack"
    ASSERT_FAIL=$((ASSERT_FAIL + 1))
  fi
}
```

- [ ] **Step 2: Create test runner**

Create `tests/run-tests.sh`:

```bash
#!/usr/bin/env bash
# Charter test runner. Executes every tests/*.test.sh and reports totals.

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOTAL_PASS=0
TOTAL_FAIL=0

echo "Charter test suite"
echo "=================="

for test_file in "$REPO_DIR"/tests/*.test.sh; do
  [[ -f "$test_file" ]] || continue
  echo ""
  echo "▸ $(basename "$test_file")"
  ASSERT_PASS=0
  ASSERT_FAIL=0
  # shellcheck disable=SC1090
  source "$test_file"
  TOTAL_PASS=$((TOTAL_PASS + ASSERT_PASS))
  TOTAL_FAIL=$((TOTAL_FAIL + ASSERT_FAIL))
done

echo ""
echo "=================="
echo "Results: $TOTAL_PASS passed, $TOTAL_FAIL failed"
if [[ $TOTAL_FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
```

- [ ] **Step 3: Make scripts executable**

```bash
chmod +x tests/run-tests.sh tests/lib/assert.sh
```

- [ ] **Step 4: Verify runner works with no tests**

```bash
bash tests/run-tests.sh
```

Expected output ends with: `Results: 0 passed, 0 failed`. Exit code 0.

- [ ] **Step 5: Commit**

```bash
git add tests/run-tests.sh tests/lib/assert.sh
git commit -m "test: add minimal shell test harness"
```

---

### Task 3: Write regression tests for current session-start.sh behavior

**Files:**
- Create: `tests/session-start.test.sh`

This task locks in current behavior so the refactor in Task 4 can't break it.

- [ ] **Step 1: Write the test file**

Create `tests/session-start.test.sh`:

```bash
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
  git init -q -b main
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
```

- [ ] **Step 2: Run and verify all pass against current hook**

```bash
bash tests/run-tests.sh
```

Expected: all assertions pass. If any fail, the current hook differs from documented behavior — investigate before continuing.

- [ ] **Step 3: Commit**

```bash
git add tests/session-start.test.sh
git commit -m "test: regression coverage for current session-start.sh behavior"
```

---

### Task 4: Add branch detection to session-start.sh

**Files:**
- Modify: `hooks/session-start.sh`
- Modify: `tests/session-start.test.sh` (append new tests first)

Plan-matching rule: a plan file matches the current branch if (a) the filename's slug portion contains the branch's slug, OR (b) the plan has YAML frontmatter with `branch: <name>` matching. The slug is the branch name with `/` and non-alphanumeric chars replaced by `-`. Example: branch `feat/branch-handling` → slug `feat-branch-handling`; plan `docs/plans/2026-05-12-branch-handling.md` matches because filename contains `branch-handling`.

- [ ] **Step 1: Add failing tests for branch awareness**

Append to `tests/session-start.test.sh`:

```bash

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
assert_contains "$out" "no plan file detected for this branch" "soft hint suggests /charter-adopt"
assert_contains "$out" "/charter-adopt branches" "hint mentions the opt-in command"

echo "  scenario: feature branch, plan matched by frontmatter"
out=$(run_hook_in_temp setup_feature_branch_with_frontmatter_match)
assert_contains "$out" "Branch Plan: 2026-05-12-totally-different-slug.md" "frontmatter match works"
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
bash tests/run-tests.sh
```

Expected: the three new scenarios fail. Existing scenarios still pass.

- [ ] **Step 3: Modify session-start.sh to add branch awareness**

Replace `hooks/session-start.sh` with:

```bash
#!/usr/bin/env bash
# Charter session-start hook
# Detects Charter scaffold and injects current project state into Claude's context.
# Branch-aware: on a non-main branch, surfaces the matching plan file (if any).
# Outputs JSON { "additionalContext": "..." } or exits silently if no scaffold.

set -euo pipefail

STATUS_FILE="docs/STATUS.md"

# If no Charter scaffold, suggest setup
if [[ ! -f "$STATUS_FILE" ]]; then
  printf '%s' "This project has no Charter scaffold. Run /charter-init to bootstrap a new project, or /charter-attach to attach Charter to this existing codebase." | python3 -c "
import sys, json
content = sys.stdin.read()
print(json.dumps({'additionalContext': content}))
"
  exit 0
fi

# Detect current branch (silent fallback if not a git repo)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Slugify: lowercase, replace non-alphanumeric with '-', collapse repeats
slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g'
}

# Find a plan file that matches the given branch.
# Match rules (in order):
#   1. Plan has YAML frontmatter with `branch: <name>` matching
#   2. Plan filename slug contains the branch slug
# Returns: the matching plan file path, or empty string.
find_branch_plan() {
  local branch="$1"
  [[ -z "$branch" ]] && return
  [[ ! -d "docs/plans" ]] && return

  local branch_slug
  branch_slug=$(slugify "$branch")
  [[ -z "$branch_slug" ]] && return

  local plan
  # Rule 1: frontmatter match
  for plan in docs/plans/*.md; do
    [[ -f "$plan" ]] || continue
    [[ "$(basename "$plan")" == "TEMPLATE.md" ]] && continue
    if head -10 "$plan" | grep -qE "^branch:[[:space:]]*${branch}[[:space:]]*$"; then
      printf '%s' "$plan"
      return
    fi
  done

  # Rule 2: filename contains branch slug
  for plan in docs/plans/*.md; do
    [[ -f "$plan" ]] || continue
    [[ "$(basename "$plan")" == "TEMPLATE.md" ]] && continue
    local plan_slug
    plan_slug=$(slugify "$(basename "$plan" .md)")
    if [[ "$plan_slug" == *"$branch_slug"* ]]; then
      printf '%s' "$plan"
      return
    fi
  done
}

# Is this branch a "main" branch (not a feature branch)?
is_main_branch() {
  [[ "$1" == "main" || "$1" == "master" || -z "$1" ]]
}

STATUS_CONTENT=$(cat "$STATUS_FILE")

# Branch context block (empty unless on a feature branch)
BRANCH_BLOCK=""
PLAN_CONTENT=""

if ! is_main_branch "$CURRENT_BRANCH"; then
  BRANCH_PLAN=$(find_branch_plan "$CURRENT_BRANCH")
  if [[ -n "$BRANCH_PLAN" ]]; then
    PLAN_NAME=$(basename "$BRANCH_PLAN")
    BRANCH_BLOCK="
## On branch: ${CURRENT_BRANCH}

### Branch Plan: ${PLAN_NAME}

$(cat "$BRANCH_PLAN")

---
"
  else
    BRANCH_BLOCK="
## On branch: ${CURRENT_BRANCH}

No plan file detected for this branch. Run /charter-adopt branches to enable branch-aware conventions, or create a plan at docs/plans/YYYY-MM-DD-${CURRENT_BRANCH//\//-}.md.

---
"
  fi
else
  # On main: fall back to surfacing latest plan (legacy behavior)
  if [[ -d "docs/plans" ]]; then
    LATEST_PLAN=$(ls -t docs/plans/*.md 2>/dev/null | grep -v 'TEMPLATE.md' | head -1 || true)
    if [[ -n "$LATEST_PLAN" && -f "$LATEST_PLAN" ]]; then
      PLAN_NAME=$(basename "$LATEST_PLAN")
      PLAN_CONTENT="

## Active Plan: ${PLAN_NAME}

$(cat "$LATEST_PLAN")"
    fi
  fi
fi

# Build orient block
ORIENT=$(cat <<ORIENT
## Charter: Project Orientation

You are starting a session in a Charter-managed project. Read the following before responding.
${BRANCH_BLOCK}
### Project Status

${STATUS_CONTENT}
${PLAN_CONTENT}

---

Session start ritual: read STATUS.md ✓ — you know where this project stands. Check docs/ARCHITECTURE.md if you need structural context. Check docs/VISION.md if you need to understand the thesis. Find the current step in "What to Work On Next" above and proceed.

When you respond, briefly tell the user: where the project stands (current step), and what Charter is doing this session (orienting from STATUS.md, classifying requests by tier, enforcing finish ritual). Keep it to 2-3 sentences — they shouldn't need to read docs to understand what's happening.
ORIENT
)

# Output JSON for Claude Code hook system
printf '%s' "$ORIENT" | python3 -c "
import sys, json
content = sys.stdin.read()
print(json.dumps({'additionalContext': content}))
"
```

- [ ] **Step 4: Run tests to verify they now pass**

```bash
bash tests/run-tests.sh
```

Expected: all tests pass, including the original regression tests (legacy behavior on main unchanged) AND the new branch-aware tests.

- [ ] **Step 5: Commit**

```bash
git add hooks/session-start.sh tests/session-start.test.sh
git commit -m "feat(hooks): make session-start.sh branch-aware (additive, backward-compat)"
```

---

## CHECKPOINT 1: Core hook behavior

Verify with the user: hook now surfaces branch plans on feature branches, falls back to legacy behavior on main, suggests `/charter-adopt branches` when on a feature branch with no plan. Pause for review before continuing.

---

### Task 5: Make /charter-finish branch-aware

**Files:**
- Modify: `commands/charter-finish.md`

This is a markdown command (model instruction), not testable code. Manual verification.

- [ ] **Step 1: Rewrite the command body to fork on branch**

Replace `commands/charter-finish.md` with:

```markdown
---
description: "Run the step-complete finish ritual: verify tests pass, update docs, commit, and report. Adapts to whether you're on main or a feature branch."
argument-hint: "[optional notes about what was completed]"
---

The user has completed a step and wants to run the Charter finish ritual.

$ARGUMENTS

**Step 1: Determine the branch context.**

Run `git rev-parse --abbrev-ref HEAD` to get the current branch.

- If the branch is `main` or `master`, follow **Main Branch Flow** below.
- Otherwise, follow **Feature Branch Flow**.

---

## Main Branch Flow

Run the mandatory finish checklist from `.claude/rules/workflow.md`:

1. Run the project's test suite (check AGENTS.md or README for the test command). Report pass/fail count.
   - If no automated tests exist for this step, note that explicitly.
2. Update `docs/STATUS.md`:
   - Mark the completed component as "Done"
   - Update "What to Work On Next" — strike through the done item, bold the next one
   - Update "Last updated" date
   - If an "In-flight Branches" section exists and this work merged a branch, remove the corresponding line
3. Update `docs/ARCHITECTURE.md` if the architecture changed from what was planned
4. Update `AGENTS.md` if project setup changed (new commands, new dependencies, etc.)
5. Commit all changes with a descriptive message
6. Report in this exact format:

```
**Step complete: [step name]**
- Tests: X/X pass (or: no automated tests for this step — [why/what was verified manually])
- Docs updated: [list which files were updated]
- Commits: [count] commits on [branch]
- Next step: [what STATUS.md now says is next]
```

---

## Feature Branch Flow

You are on a feature branch. STATUS.md component sections must NOT be edited — they only update on merge to main. This avoids merge conflicts.

1. Run the project's test suite. Report pass/fail count.
2. Update the **branch plan file** in `docs/plans/` matching this branch:
   - Mark completed steps as done in the plan
   - Add any decisions made during this work
   - Note what's left, if anything
3. **Do not touch** `docs/STATUS.md` Component Status, What to Work On Next, or Recent Decisions sections.
   - You MAY update an "In-flight Branches" section if it exists, but only to reflect this branch's status.
4. Commit changes on this branch.
5. Invoke `superpowers:finishing-a-development-branch` to decide on merge/PR strategy. That skill will:
   - Check if the branch is ready (tests pass, plan complete)
   - Help decide between merge to main, open a PR, or hold for more work
6. After merge to main (if applicable), the main-branch finish flow will update STATUS.md component sections.

Report in this format:

```
**Branch step complete: [step name]**
- Branch: [branch name]
- Plan: docs/plans/[plan file] — [N/N steps complete]
- Tests: X/X pass
- Commits this session: [count]
- Ready to merge: yes/no — [reason]
- Next: [merge / continue plan / await review]
```

---

Do not claim the step is done until all checklist items for the relevant flow are complete.
```

- [ ] **Step 2: Verify with verify-plugin.sh that command structure is valid**

```bash
bash scripts/verify-plugin.sh
```

Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add commands/charter-finish.md
git commit -m "feat(commands): charter-finish forks on branch (main vs feature)"
```

---

### Task 6: Create /charter-adopt command

**Files:**
- Create: `commands/charter-adopt.md`

This command is the opt-in path for existing users who want to enable branch conventions in their project.

- [ ] **Step 1: Create the command file**

Create `commands/charter-adopt.md`:

```markdown
---
description: "Adopt an optional Charter convention into this project. Idempotent — safe to run multiple times. Currently supported: 'branches' (enables branch-aware workflows)."
argument-hint: "<convention>  (e.g., branches)"
---

The user is opting into a Charter convention.

$ARGUMENTS

Parse the argument as the convention name. Currently supported: `branches`.

If the argument is empty or unrecognized, list the supported conventions and stop:

```
Supported conventions:
  branches — enable branch-aware workflows (plans tied to feature branches, branch-aware finish ritual)
```

---

## Convention: `branches`

Goal: enable Charter to treat each feature branch as a self-contained unit of work, with its own plan file.

Make the following changes, **asking the user before each one** so they can skip any:

### Change 1: Add "In-flight Branches" section to docs/STATUS.md

Check if `docs/STATUS.md` already contains a heading exactly matching `## In-flight Branches`. If yes, skip — already adopted.

If no, propose adding the following section after "Branch State" (or at the end if "Branch State" is absent):

```markdown
---

## In-flight Branches

<!-- GUIDANCE: One line per active feature branch. Format: `- \`branch-name\` → docs/plans/<plan-file>.md — short status` -->

_None active._
```

Show the user the proposed insertion location and exact content. Ask: "Add this section to STATUS.md? (yes/no)" If yes, edit the file; if no, skip.

### Change 2: Add branch-discipline note to .claude/rules/workflow.md

Check if `.claude/rules/workflow.md` already contains the phrase `On feature branches`. If yes, skip.

If no, propose appending the following section at the end of the file:

```markdown
---

## Branch Discipline

On feature branches:
- Edit only your branch's plan file in `docs/plans/`
- Do NOT edit STATUS.md Component Status, What to Work On Next, or Recent Decisions sections
- These sections only update on merge to main (handled by `/charter-finish` on the main branch)
- This avoids merge conflicts and keeps STATUS.md as the canonical "shipped" state

When starting work on a new feature:
1. Create the branch: `git checkout -b feat/<short-name>`
2. Create a plan file: `docs/plans/YYYY-MM-DD-<short-name>.md` (filename should include `<short-name>` so the session-start hook can match it to the branch)
3. Optionally add a line to STATUS.md "In-flight Branches" pointing at the plan
```

Show the user the proposed addition. Ask: "Add this rule to workflow.md? (yes/no)" If yes, append; if no, skip.

### Change 3: Optional plan rename suggestion

If `docs/plans/` contains plan files that don't match any branch name slug, mention them as informational only — do NOT modify or rename them. Existing plans keep working.

---

After all changes are applied (or skipped), report:

```
**Adoption complete: branches**
- STATUS.md: [added section / skipped — already present / skipped — user declined]
- workflow.md: [added rule / skipped — already present / skipped — user declined]
- Next: on feature branches, create a plan in docs/plans/ with the branch name in the filename. The session-start hook will surface it automatically.
```

If the user declined every change, report that adoption was a no-op and explain that the plugin will still work in legacy mode.
```

- [ ] **Step 2: Verify command structure**

```bash
bash scripts/verify-plugin.sh
```

Expected: PASS, with `charter-adopt.md` listed.

- [ ] **Step 3: Commit**

```bash
git add commands/charter-adopt.md
git commit -m "feat(commands): add /charter-adopt for opt-in convention installation"
```

---

### Task 7: Update template for new projects

**Files:**
- Modify: `template/docs/STATUS.md`
- Modify: `template/.claude/rules/workflow.md`

New projects scaffolded from this point get the branch conventions baked in. Existing projects are untouched.

- [ ] **Step 1: Update template STATUS.md**

Read current `template/docs/STATUS.md`. After the existing "Branch State" section, add a new "In-flight Branches" section. Keep "Branch State" intact for backwards compatibility (existing users may reference it).

Edit `template/docs/STATUS.md` to insert this block between the "Branch State" section's table and the "## Recent Decisions" heading:

```markdown

---

## In-flight Branches

<!-- GUIDANCE: One line per active feature branch. Format: `- \`branch-name\` → docs/plans/<plan-file>.md — short status`. Updated on this branch as work progresses. Removed when the branch merges. -->

_None active._
```

- [ ] **Step 2: Update template workflow.md**

Append to `template/.claude/rules/workflow.md`:

```markdown

## Branch Discipline

On feature branches:
- Edit only your branch's plan file in `docs/plans/`
- Do NOT edit STATUS.md Component Status, What to Work On Next, or Recent Decisions sections
- These sections only update on merge to main (handled by `/charter-finish` on the main branch)
- This avoids merge conflicts and keeps STATUS.md as the canonical "shipped" state

When starting work on a new feature:
1. Create the branch: `git checkout -b feat/<short-name>`
2. Create a plan file: `docs/plans/YYYY-MM-DD-<short-name>.md` (filename should include `<short-name>` so the session-start hook can match it to the branch)
3. Optionally add a line to STATUS.md "In-flight Branches" pointing at the plan
```

- [ ] **Step 3: Verify template files still parse correctly**

```bash
bash scripts/verify-plugin.sh
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add template/docs/STATUS.md template/.claude/rules/workflow.md
git commit -m "feat(template): add branch conventions for new projects"
```

---

## CHECKPOINT 2: Commands and template updates

Verify with the user: commands fork correctly, template carries the new conventions, `/charter-adopt branches` is opt-in and idempotent. Pause for review.

---

### Task 8: Wire tests into verify-plugin.sh

**Files:**
- Modify: `scripts/verify-plugin.sh`

- [ ] **Step 1: Append test-runner invocation**

Edit `scripts/verify-plugin.sh`. After the "Summary" block but before the `exit 0`, replace the tail with:

```bash
# Summary of structural checks
echo ""
echo "==========================="
echo "Structural checks: $PASS passed, $FAIL failed"
if [[ $FAIL -gt 0 ]]; then
  echo "FAIL — fix structural errors above before releasing"
  exit 1
fi
echo "PASS — plugin structure looks good"

# Run behavioral tests
echo ""
echo "Running behavioral tests..."
if ! bash "$REPO_DIR/tests/run-tests.sh"; then
  echo "FAIL — behavioral tests failed"
  exit 1
fi

echo ""
echo "All checks passed."
exit 0
```

- [ ] **Step 2: Run verify-plugin.sh end to end**

```bash
bash scripts/verify-plugin.sh
```

Expected: structural checks pass, behavioral tests run and pass, exits 0.

- [ ] **Step 3: Commit**

```bash
git add scripts/verify-plugin.sh
git commit -m "build: verify-plugin.sh now runs behavioral tests"
```

---

### Task 9: Decision record

**Files:**
- Create: `docs/decisions/2026-05-12-branch-handling.md`

- [ ] **Step 1: Write the ADR**

Create `docs/decisions/2026-05-12-branch-handling.md`:

```markdown
# Branch Handling

**Date:** 2026-05-12
**Status:** Accepted

## Context

Charter's session-start hook and finish ritual were built assuming a single-branch workflow. STATUS.md was treated as the global source of truth, but it's a file in the repo, so it's per-branch by accident. Feature branches diverged STATUS.md, causing merge conflicts and confusing the session-start orientation.

Real development needs feature branches. Charter didn't support them.

## Decision

**Plans become the unit of branch-scoped work.** Each feature branch owns a plan file in `docs/plans/`. The session-start hook is branch-aware: on a non-main branch, it surfaces the matching plan instead of (or in addition to) the latest one. STATUS.md component sections are only edited at merge to main — feature branches leave them alone.

**Backward compatibility via capability detection.** The hook and commands don't require new structures; they detect them. An old project that updates the plugin and changes nothing sees identical behavior. Branch awareness activates only when the user is on a feature branch AND opts in (creates a branch-named plan file, or runs `/charter-adopt branches`).

**Opt-in via `/charter-adopt branches`.** A new command idempotently adds an "In-flight Branches" section to STATUS.md and a branch-discipline rule to workflow.md, asking before each change. Power users who want explicit conventions in their rules can opt in; everyone else benefits from the hook behavior without any user-file changes.

## Alternatives Considered

1. **Branch-local STATUS.md, accept conflicts.** Simplest but produces routine merge conflicts on STATUS.md. Rejected — conflicts erode the "frictionless continuity" thesis.

2. **Required schema migration.** Have `/charter-upgrade` rewrite user STATUS.md to a new shape. Cleaner long-term but breaks backward compatibility — users who don't run the migration are stranded. Rejected — Charter's update must never break a project.

3. **Branch metadata in a sidecar file (`.charter/branches.json`).** Cleaner separation but introduces a hidden state file Claude can't naturally read. Rejected — Charter's principle is "everything in docs/, human-readable."

4. **Active branch lifecycle commands (`/charter-branch-start`, `/charter-branch-finish`).** Considered for v2. For v0.2.0, we ship the smallest coherent slice: branch-aware hook + branch-aware finish + opt-in adoption. Lifecycle commands can be added later without breaking anything.

## Consequences

- Existing projects work unchanged until they opt in.
- Users on feature branches get a soft "no plan for this branch — run /charter-adopt" hint at session start. Discovery without disruption.
- The hook's plan-matching logic uses filename slug matching with frontmatter override — straightforward and debuggable.
- Forward-compat: the hook composes from multiple optional context sources. Future additions (stacked PRs, named work streams) extend the composer; they don't replace it.
- New automated test infrastructure (`tests/`) was added alongside this feature. Future features can use it.
```

- [ ] **Step 2: Commit**

```bash
git add docs/decisions/2026-05-12-branch-handling.md
git commit -m "docs: ADR for branch-handling design"
```

---

### Task 10: Update Charter's own docs

**Files:**
- Modify: `docs/ARCHITECTURE.md`
- Modify: `docs/STATUS.md`
- Modify: `AGENTS.md`
- Modify: `README.md`

- [ ] **Step 1: Update ARCHITECTURE.md**

In `docs/ARCHITECTURE.md`, after the "Hook Flow" section, insert a new section:

```markdown
---

## Branch Handling

Charter supports feature-branch workflows via two mechanisms:

### Branch-aware session-start hook

`hooks/session-start.sh` reads the current git branch. If on a non-main branch, it searches `docs/plans/` for a matching plan file (filename slug containing the branch slug, or YAML frontmatter `branch: <name>`) and surfaces that plan in the orient block. If no plan matches, it injects a soft hint suggesting `/charter-adopt branches`.

On main, the legacy behavior is preserved: the most-recently-modified plan is surfaced.

### Branch-aware finish ritual

`/charter-finish` checks the current branch:
- **Main:** the original finish flow — update STATUS.md, ARCHITECTURE.md, AGENTS.md, commit, report.
- **Feature branch:** update only the branch plan and any "In-flight Branches" entry. Do NOT touch STATUS.md component sections. Route to `superpowers:finishing-a-development-branch` for merge/PR decisions.

### Opt-in via `/charter-adopt branches`

For existing projects, `/charter-adopt branches` idempotently adds an "In-flight Branches" section to STATUS.md and a branch-discipline rule to workflow.md, asking before each change.

### Capability detection

All branch-aware behavior is purely additive. Missing structures (no plan file, no "In-flight Branches" section, no branch-discipline rule) default to today's behavior. Existing Charter projects continue to work without modification.
```

Also update the "How to Extend" section by appending a row about branch-aware extension:

```markdown
**Add a new opt-in convention:** Extend `commands/charter-adopt.md` with a new convention block. Each convention should: detect whether it's already adopted, propose changes to user files one at a time, ask before each, report what changed.
```

- [ ] **Step 2: Update docs/STATUS.md**

Add to the Component Status table (above the "Branch State" section):

```markdown
| Branch handling | In progress | `hooks/`, `commands/`, `template/` | v0.2.0 — see docs/plans/2026-05-12-branch-handling.md |
```

After the "Branch State" section, add:

```markdown

---

## In-flight Branches

<!-- GUIDANCE: One line per active feature branch. Format: `- \`branch-name\` → docs/plans/<plan-file>.md — short status`. -->

- `feat/branch-handling` → [docs/plans/2026-05-12-branch-handling.md](docs/plans/2026-05-12-branch-handling.md) — in progress, dogfooding the new feature
```

Update "Recent Decisions" by inserting at the top:

```markdown
| 2026-05-12 | Branch handling via capability detection | Backward-compat, opt-in, plans-as-branch-unit |
```

Update "What to Work On Next" — strike the marketplace-await item if you want, or leave; add a new "branch-handling" item if not yet listed. Actually leave the marketplace item; insert the branch-handling work as a new line:

```markdown
1. ~~Everything through publish~~ (done)
2. ~~v0.1.1 fix complete — commands verified, docs updated, pushed~~ (done)
3. ~~Branch handling (v0.2.0)~~ (in progress — see plan)
4. Await marketplace review acceptance **(current)**
5. Update install instructions once marketplace accepted
6. Monitor for user feedback and bug reports
```

Update "Last updated" to `2026-05-12`.

- [ ] **Step 3: Update AGENTS.md**

In the "Charter-Enforced Rituals" section, add a brief note:

```markdown
**Branch awareness (v0.2.0+):** On feature branches, `/charter-finish` updates only the branch plan, not STATUS.md component sections. The session-start hook surfaces the matching plan for the current branch. See `docs/ARCHITECTURE.md` § Branch Handling.
```

In the implicit list of commands (mentioned via `/charter-*` references), add `/charter-adopt` to the inventory if a list exists.

- [ ] **Step 4: Update README.md**

Add a single bullet under the feature list (find the relevant section in README.md). Example:

```markdown
- **Branch-aware workflows** — feature branches get their own plan; finish ritual adapts; STATUS.md stays conflict-free on merge.
```

- [ ] **Step 5: Commit doc updates together**

```bash
git add docs/ARCHITECTURE.md docs/STATUS.md AGENTS.md README.md
git commit -m "docs: document branch handling in ARCHITECTURE, STATUS, AGENTS, README"
```

---

### Task 11: Bump version and final verification

**Files:**
- Modify: `.claude-plugin/plugin.json`
- Modify: `package.json`

- [ ] **Step 1: Bump plugin.json**

Edit `.claude-plugin/plugin.json`: change `"version": "0.1.1"` to `"version": "0.2.0"`.

- [ ] **Step 2: Bump package.json**

Edit `package.json`: change `"version": "0.1.1"` to `"version": "0.2.0"`.

- [ ] **Step 3: Run full verification**

```bash
bash scripts/verify-plugin.sh
```

Expected: structural checks pass, behavioral tests pass (at least 6 assertions: 3 legacy + 3 branch-aware, possibly more), exits 0.

- [ ] **Step 4: Run tests directly to confirm count**

```bash
bash tests/run-tests.sh
```

Note the pass count for the finish report.

- [ ] **Step 5: Commit version bump**

```bash
git add .claude-plugin/plugin.json package.json
git commit -m "release: bump to v0.2.0 (branch handling)"
```

---

## CHECKPOINT 3: Ready for merge

All work on `feat/branch-handling` is complete. Run finish checklist from `.claude/rules/workflow.md`. Decide on merge strategy (squash vs merge commit) with the user.

---

### Task 12: Finish — merge or PR decision

**Files:**
- No file changes; git operations only

- [ ] **Step 1: Invoke superpowers:finishing-a-development-branch**

Use the `Skill` tool to invoke `superpowers:finishing-a-development-branch`. Follow its guidance for the merge/PR decision. Charter is a solo-author repo, so a fast-forward or squash merge to main is likely appropriate.

- [ ] **Step 2: After merge, run main-branch finish ritual**

Once merged to main:

1. Update `docs/STATUS.md`:
   - Change "Branch handling" row status from "In progress" to "Done (v0.2.0)"
   - Strike through the branch-handling line in "What to Work On Next"
   - Remove the `feat/branch-handling` line from "In-flight Branches" (back to `_None active._`)
2. Commit STATUS.md update on main
3. Report in standard format:

```
**Step complete: branch handling (v0.2.0)**
- Tests: N/N pass
- Docs updated: ARCHITECTURE.md, STATUS.md, AGENTS.md, README.md, decisions/2026-05-12-branch-handling.md
- Commits: M commits on feat/branch-handling, merged to main
- Next step: [whatever STATUS.md now says]
```

---

## Self-Review Checklist

After writing this plan:

1. **Spec coverage:** Every backward-compat requirement is addressed — the hook has fallback paths, /charter-adopt is opt-in, template changes only affect new projects, user-side files are never auto-modified. ✓
2. **Placeholders:** No "TBD", "implement later", or "add error handling" — every step has explicit content. ✓
3. **Type consistency:** Function names (`slugify`, `find_branch_plan`, `is_main_branch`), file paths, command names all consistent across tasks. ✓
4. **Forward compat:** The hook composes context from multiple optional sources (legacy plan, branch plan, STATUS.md). Future additions extend, never replace. The plan-matching has two rules (slug, frontmatter) — frontmatter is the cleaner long-term path; slug is the migration-friendly shortcut. ✓

---

## Execution Notes

- **TDD discipline:** Tasks 2-4 are real TDD (test first for shell hook). Tasks 5-7 are markdown commands and templates — not testable code, manual verification only.
- **Commits per task:** Each task ends with one commit. Roughly 8-10 commits total on `feat/branch-handling`.
- **Risk areas:** The session-start.sh `set -euo pipefail` is strict — any unhandled empty variable will abort the hook silently. Test on a branch with unusual characters (slashes, dots) to make sure slugify handles them.
- **Manual verification beyond tests:**
  - Install the updated plugin in a real test project that has the old STATUS.md shape — confirm no regression.
  - Switch to a feature branch in that project — confirm soft hint appears.
  - Run `/charter-adopt branches` — confirm idempotency.
