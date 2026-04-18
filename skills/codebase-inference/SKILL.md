---
name: codebase-inference
description: Use when attaching Charter to an existing codebase via /charter-attach. Reads README, entry points, existing docs, and infers the project vision, then presents a draft for user correction before scaffolding non-destructively.
---

# Codebase Inference

You are attaching Charter to an existing project. Your job is to infer the vision from what's already there, present it for user correction, then scaffold Charter's structure non-destructively alongside existing files.

## Phase 1: Read

Read the following in order (skip gracefully if they don't exist):

1. `README.md` or `README.rst` — project description, goals, install instructions
2. `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml` — name, description, dependencies
3. `docs/` or `doc/` directory — any existing documentation
4. Main entry point(s) — top-level files, `main.py`, `index.ts`, `cmd/`, `src/main.*`
5. Test files (a sample) — often reveal what the code is supposed to do

## Phase 2: Infer

Based on what you read, infer:
- **Thesis:** What problem does this project solve?
- **What it does:** Major features/components visible in the code
- **Non-goals:** What's notably absent that someone might expect?
- **Success criteria:** What would "working correctly" look like?
- **Key concepts:** What are the core domain objects/terms in the codebase?

## Phase 3: Draft

Delegate to the `vision-drafter` subagent with your inferences. The subagent will produce a VISION.md draft.

Present the draft to the user. Say:

> Here's my inferred VISION.md for this project. I read [list what you read]. Does this capture what the project is? Correct anything that's wrong, and I'll scaffold Charter's structure around it.

## Phase 4: Scaffold (non-destructive)

Once the user approves or corrects the vision:

1. Write `docs/VISION.md` (or `docs/charter/VISION.md` if `docs/` has conflicting content)
2. Copy the Charter template files that don't already exist:
   - `docs/STATUS.md` — only if none exists
   - `docs/ARCHITECTURE.md` — only if none exists
   - `docs/decisions/TEMPLATE.md`
   - `docs/plans/TEMPLATE.md`
   - `.claude/rules/project-flow.md`
   - `.claude/rules/workflow.md`
   - `.claude/rules/turn-ritual.md`
   - `.claude/rules/testing.md`
   - `.claude/settings.json` — only if none exists
   - `AGENTS.md` — only if none exists
   - `CLAUDE.md` — only if none exists
   - `.gitignore` — DO NOT overwrite existing
3. Fill in `AGENTS.md` with the project name, brief description, and any stack-specific notes inferred from the codebase (test command, dev server command, known gotchas)
4. Report:

```
**Charter attached.**
- Read: [list of files read]
- docs/VISION.md: drafted from codebase inference
- Files added: [list only files actually written — skip ones that already existed]
- Files skipped (already exist): [list]
- Next step: review VISION.md — does it capture the project correctly?
```

## Rules

- **Never overwrite existing files.** Charter attaches alongside, not on top of.
- **Flag conflicts.** If existing docs contradict the inferred vision, say so explicitly.
- **Preserve existing structure.** Don't reorganize `docs/` if it already has a structure.
- **Minimal footprint.** Only add what Charter needs. Don't reorganize the project.
