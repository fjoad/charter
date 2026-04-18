---
name: turn-ritual
description: Use when classifying an incoming user request by size to determine the appropriate ritual depth. Routes trivial and small requests to direct execution, medium requests through writing-plans and TDD, and major requests through writing-plans with CHECKPOINT markers and subagent-driven development.
---

# Turn Ritual

Classify the current request, then apply the matching ritual. Do this before any other response.

## Step 1: Classify

Look at the request. Which tier fits?

| Tier | Signal |
|------|--------|
| **Trivial** | Single-line change, no logic, no interfaces. Typo fix, rename, constant update. |
| **Small** | Under 1 hour of work, well-understood change, no interface changes. Add a flag, fix a known bug. |
| **Medium** | Multi-file change, touches interfaces, moderate risk. New feature, module refactor, API update. |
| **Major** | Architecture change, new component, high risk or high uncertainty. New subsystem, data model change, dependency restructure. |

**When in doubt, classify one tier higher.** Over-discipline is recoverable; under-discipline causes drift.

## Step 2: Apply Ritual

### Trivial
1. Execute directly — no announcement needed
2. Verify the specific change is correct
3. Done

### Small
1. State what you're doing in one sentence
2. Implement
3. Verify (run relevant tests, check output)
4. Report result in one sentence

### Medium
1. Use `superpowers:writing-plans` — create plan, save to `docs/plans/YYYY-MM-DD-[name].md`
2. If plan is straightforward, proceed; otherwise wait for user acknowledgment
3. Use `superpowers:test-driven-development` — write tests before logic
4. Implement per plan
5. Use `superpowers:verification-before-completion` — verify before claiming done
6. Run finish checklist from `.claude/rules/workflow.md`
7. Report in standard format

### Major
1. Use `superpowers:writing-plans` — create plan with at least one `## CHECKPOINT: user review` marker
2. **CHECKPOINT** — present plan, wait for explicit user approval before writing any code
3. Execute tasks between checkpoints autonomously
4. At each CHECKPOINT — pause, report what was done, what's next, any concerns. Wait for user
5. Use `superpowers:test-driven-development` throughout
6. Use `superpowers:subagent-driven-development` for parallel subtasks if applicable
7. Use `superpowers:verification-before-completion` at end
8. Run finish checklist from `.claude/rules/workflow.md`
9. Final standard report

## Step 3: Escape Hatch Check

Before applying ritual, check if the user has said "skip ritual", "no ritual", "just do it", or has already invoked `/charter-off` this session. If so, execute directly. Note: `/charter-off` persists until end of session.

## Standard Report Format

```
**Step complete: [name]**
- Tests: X/X pass (or: no automated tests for this step)
- Docs updated: [list which]
- Commits: [count] on [branch]
- Next step: [what STATUS.md says is next]
```
