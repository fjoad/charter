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
#   2. Plan filename slug contains the branch slug, where the branch slug is
#      derived from the part of the branch name after the last `/` (so
#      `feat/branch-handling` matches a plan with `branch-handling` in its name).
# Echoes the matching plan file path, or empty string.
find_branch_plan() {
  local branch="$1"
  [[ -z "$branch" ]] && return
  [[ ! -d "docs/plans" ]] && return

  # Use last `/`-separated segment for slug matching (strips prefixes like feat/, fix/)
  local branch_tail="${branch##*/}"
  local branch_slug
  branch_slug=$(slugify "$branch_tail")

  local plan
  # Rule 1: frontmatter match (against full branch name)
  # Runs regardless of slug length, since frontmatter is an explicit declaration.
  for plan in docs/plans/*.md; do
    [[ -f "$plan" ]] || continue
    [[ "$(basename "$plan")" == "TEMPLATE.md" ]] && continue
    if head -10 "$plan" | grep -qE "^branch:[[:space:]]*${branch}[[:space:]]*$"; then
      printf '%s' "$plan"
      return
    fi
  done

  # Rule 2: filename contains branch slug (tail only).
  # Requires slug >= 3 chars to avoid false-positive matches (e.g., branch
  # `feat/x` would otherwise match every plan filename containing 'x').
  if [[ ${#branch_slug} -lt 3 ]]; then
    return
  fi

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

# Working memory block (empty unless docs/CONTEXT.md exists)
CONTEXT_BLOCK=""
if [[ -f "docs/CONTEXT.md" ]]; then
  CONTEXT_BLOCK="
## Working Memory

$(cat docs/CONTEXT.md)

---
"
fi

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
${CONTEXT_BLOCK}${BRANCH_BLOCK}
### Project Status

${STATUS_CONTENT}
${PLAN_CONTENT}

---

Session start ritual: read STATUS.md ✓ — you know where this project stands. Check docs/ARCHITECTURE.md if you need structural context. Check docs/VISION.md if you need to understand the thesis. Find the current step in "What to Work On Next" above and proceed.

Before building any session-recovery, transcript, branch-management, working-memory, or scaffolding tooling: check what Charter already provides (run or read /charter-help). Charter likely already ships it — reuse or improve the existing command rather than reinventing it.

When you respond, briefly tell the user: where the project stands (current step), and what Charter is doing this session (orienting from STATUS.md, classifying requests by tier, enforcing finish ritual). Keep it to 2-3 sentences — they shouldn't need to read docs to understand what's happening.
ORIENT
)

# Output JSON for Claude Code hook system
printf '%s' "$ORIENT" | python3 -c "
import sys, json
content = sys.stdin.read()
print(json.dumps({'additionalContext': content}))
"
