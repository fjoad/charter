# Project Flow

## How Everything Connects

This project uses a layered system of docs and rules. Full map:

**Auto-loaded every session (`.claude/rules/`):**
- `project-flow.md` (this file) — session start, deciding what to do, doc map
- `workflow.md` — per-step cycle: plan → implement → test → verify → finish checklist
- `turn-ritual.md` — per-turn tier classifier and ritual routing
- `testing.md` — what to test, test discipline

**Read at session start (`docs/`):**
- `docs/STATUS.md` — where we are, what's next (source of truth for progress)
- `docs/ARCHITECTURE.md` — technical blueprint
- `docs/VISION.md` — thesis, goals, non-goals, success criteria

**Reference when needed:**
- `docs/decisions/` — past choices with rationale
- `docs/plans/` — implementation plans per step
- `AGENTS.md` — canonical operational guide

**Superpowers skills used (from `workflow.md`):**
- `writing-plans` — create implementation plan for a step
- `executing-plans` — execute the plan step by step
- `test-driven-development` — tests before code
- `verification-before-completion` — verify before claiming done
- `systematic-debugging` — diagnose failures before guessing
- `subagent-driven-development` — parallel independent subtasks
- `finishing-a-development-branch` — clean up, PR/merge decision

## Starting a Session

1. Read `docs/STATUS.md` — find the current step and what's next
2. Read `docs/ARCHITECTURE.md` — understand how the current step fits
3. Check `docs/plans/` — is there an existing plan for the current step?

## Deciding What to Do

- If STATUS.md says a step is "In progress" with an existing plan → continue executing that plan
- If STATUS.md says a step is "In progress" with no plan → create a plan first (use `writing-plans` skill)
- If STATUS.md says a step is "Not started" → it's the next step. Create a plan.
- If STATUS.md says a step is "Done" → update STATUS.md, move to the next step
- If unsure → ask the user

## The Project Steps (in order)

Defined in `docs/STATUS.md` "What to Work On Next" section. Always follow that list. Do not skip ahead.

## After Completing a Step

Follow the mandatory finish checklist in `workflow.md`. This includes updating STATUS.md, AGENTS.md if needed, committing, and reporting to the user in the standard format.

## Key Docs Quick Reference

| Question | Read |
|----------|------|
| What are we building and why? | `docs/VISION.md` |
| Where are we now? What's next? | `docs/STATUS.md` |
| How should this component work? | `docs/ARCHITECTURE.md` |
| Why was a past decision made? | `docs/decisions/` |
| Implementation plan for current step? | `docs/plans/` |
| What skills to use when? | `.claude/rules/workflow.md` |
