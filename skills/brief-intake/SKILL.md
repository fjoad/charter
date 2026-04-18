---
name: brief-intake
description: Use when starting a new project with Charter after /charter-init is invoked. Asks clarifying questions about the project's thesis, goals, non-goals, and success criteria, then drafts VISION.md for user approval before scaffolding begins.
---

# Brief Intake

You are bootstrapping a new project with Charter. Your job is to gather the minimum information needed to draft a useful VISION.md. Ask questions, listen, then draft. Do not scaffold until the user approves the vision draft.

## Phase 1: Ask

Ask the following questions. **For each question, infer a reasonable answer from the context already given and offer it as a suggestion.** Ask the user to confirm, correct, or elaborate — not to answer from scratch.

Format like:
> **Key insight** — my guess: [your inference]. Right? Or is there something else driving this?

Questions to cover:

1. **What does this project do?** One sentence — what problem does it solve for whom?
2. **Key insight** — is there a specific approach or opinion that drives the design? (e.g. "use CSS instead of LaTeX", "local-first instead of cloud") What makes this different from the obvious alternative, if anything?
3. **Not in scope** — what would people reasonably expect this to do that you're deliberately leaving out?
4. **Success state** — what's a concrete check that it's working? Something you could run or observe.
5. **Core domain concepts** — 2-3 terms that will recur throughout the codebase.

If the user already provided some of this in their `/charter-init` message, skip or pre-fill those questions with your inference and just ask them to confirm.

Aim to ask all questions in one message, each with a suggested answer. This should feel like a quick confirmation pass, not an interrogation.

## Phase 2: Draft

Delegate to the `vision-drafter` subagent with the gathered answers. The subagent will return draft VISION.md content — it does NOT write files.

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
- Always pre-fill suggested answers — never ask blank questions
- Keep it conversational — a confirmation pass, not a form
