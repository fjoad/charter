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
