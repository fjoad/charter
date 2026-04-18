---
name: brief-intake
description: Use when starting a new project with Charter after /charter-init is invoked. Asks clarifying questions about the project's thesis, goals, non-goals, and success criteria, then drafts VISION.md for user approval before scaffolding begins.
---

# Brief Intake

You are bootstrapping a new project with Charter. Your job is to gather the minimum information needed to draft a useful VISION.md. Ask questions, listen, then draft. Do not scaffold until the user approves the vision draft.

## Phase 1: Ask

Ask the following questions. You can ask them all at once or in natural conversational flow — use your judgment based on how much context was given in `/charter-init`:

1. **What does this project do?** One sentence — what problem does it solve for whom?
2. **What's the key insight?** Why is this approach better than the obvious alternative?
3. **What is explicitly NOT in scope?** What would people expect to be here that you're deliberately excluding?
4. **How will you know it's working?** What's a concrete success state — something you could check?
5. **What are the 2-3 most important domain concepts?** (Terms that will recur throughout the codebase)

If the user already provided some of this in their `/charter-init` message, skip or abbreviate those questions.

## Phase 2: Draft

Delegate to the `vision-drafter` subagent with the gathered answers. The subagent will produce a VISION.md draft.

Present the draft to the user. Say:

> Here's the VISION.md draft. Review it — does it capture what you're building? Say "looks good" to proceed, or tell me what to change.

## Phase 3: Scaffold

Once the user approves the vision:

1. Write `docs/VISION.md` with the approved content
2. Copy the Charter template into the project:
   - `docs/STATUS.md` (seed with "Step 0: vision approved; next: [what user said is next]")
   - `docs/ARCHITECTURE.md` (skeleton)
   - `docs/decisions/TEMPLATE.md`
   - `docs/plans/TEMPLATE.md`
   - `.claude/rules/project-flow.md`
   - `.claude/rules/workflow.md`
   - `.claude/rules/turn-ritual.md`
   - `.claude/rules/testing.md`
   - `.claude/settings.json`
   - `AGENTS.md` (fill in project name and brief description)
   - `CLAUDE.md` (one-line pointer)
   - `.gitignore` (only if one doesn't already exist)
3. Report:

```
**Charter initialized.**
- docs/VISION.md: written and approved
- docs/STATUS.md: seeded
- .claude/rules/: 4 rule files in place
- AGENTS.md: operational guide written
- Next step: [what STATUS.md says is next — usually architecture]
```

## Rules

- Never scaffold before vision is approved
- Never overwrite existing files (brownfield safe — use /charter-attach for existing projects)
- Keep questions conversational — this is an intake, not a form
