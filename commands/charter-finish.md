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
