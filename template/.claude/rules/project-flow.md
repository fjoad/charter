# Project Flow

## How Everything Connects

This project uses shared docs plus agent-specific automation. Canonical project facts must be readable
by every agent; `.claude/rules/` only automates Claude's use of them.

**Shared bootstrap:**
- `AGENTS.md` — canonical instructions for Claude, Codex, and other assistants
- `CLAUDE.md` — imports `AGENTS.md`; it must not become a second source of truth

**Auto-loaded every session (`.claude/rules/`):**
- `project-flow.md` (this file) — session start, deciding what to do, doc map
- `workflow.md` — per-step cycle: plan → implement → test → verify → finish checklist
- `turn-ritual.md` — per-turn tier classifier and ritual routing
- `testing.md` — what to test, test discipline

**Project docs (`STATUS`/`CONTEXT` at session start; the rest as needed):**
- `docs/CONTEXT.md` — AI working memory across compactions (auto-loaded by session-start hook if present)
- `docs/STATUS.md` — where we are, what's next (source of truth for progress)
- `docs/EVIDENCE-AND-LEARNINGS.md` (if adopted) — durable causal corrections; read on demand
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
2. Read `docs/CONTEXT.md` if present — recover active caveats and don't-repeats
3. Read `docs/EVIDENCE-AND-LEARNINGS.md` only when STATUS/CONTEXT cites it, a claim was
   corrected/contested, or a discriminating experiment/debugging result needs interpretation
4. Read `docs/ARCHITECTURE.md` — understand how the current step fits
5. Check `docs/plans/` — is there an existing plan for the current step?

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
| What must this session remember? | `docs/CONTEXT.md` (if adopted) |
| Why did our belief change? How strong is the evidence? | `docs/EVIDENCE-AND-LEARNINGS.md` (if adopted) |
| How should this component work? | `docs/ARCHITECTURE.md` |
| Why was a past decision made? | `docs/decisions/` |
| Implementation plan for current step? | `docs/plans/` |
| What skills to use when? | `.claude/rules/workflow.md` |
| Mid-session learnings (post-compaction)? | `docs/CONTEXT.md` |
