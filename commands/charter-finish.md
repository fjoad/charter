---
description: "Run the step-complete finish ritual: verify tests pass, update STATUS.md and docs, commit changes, and report to user in standard format."
argument-hint: "[optional notes about what was completed]"
---

The user has completed a step and wants to run the Charter finish ritual.

$ARGUMENTS

Run the mandatory finish checklist from .claude/rules/workflow.md:

1. Run the project's test suite (check AGENTS.md or README for the test command). Report pass/fail count.
   - If no automated tests exist for this step, note that explicitly.
2. Update docs/STATUS.md:
   - Mark the completed component as "Done"
   - Update "What to Work On Next" — strike through the done item, bold the next one
   - Update "Last updated" date
3. Update docs/ARCHITECTURE.md if the architecture changed from what was planned
4. Update AGENTS.md if project setup changed (new commands, new dependencies, etc.)
5. Commit all changes with a descriptive message
6. Report in this exact format:

**Step complete: [step name]**
- Tests: X/X pass (or: no automated tests for this step — [why/what was verified manually])
- Docs updated: [list which files were updated]
- Commits: [count] commits on [branch]
- Next step: [what STATUS.md now says is next]

Do not claim the step is done until all checklist items are complete.
