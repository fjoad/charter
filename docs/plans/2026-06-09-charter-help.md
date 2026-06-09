# v0.6.0 — /charter-help + AI-facing discoverability

**Status:** In progress (2026-06-09)
**Branch:** `feat/charter-help`

## Why

Three sibling Charter sessions independently rebuilt features Charter already shipped (branch cleanup, the replay filter, a session-recap script). Root cause: **the AI didn't know the feature existed** — either on an old cached version or simply never told. This is a discoverability problem, and the most-affected audience is the *AI itself* mid-session, not the human.

## Two-part fix

1. **`/charter-help`** — a curated, grouped catalog of every command + opt-in convention + the recovery tiers. The reference people (and the AI) consult.

2. **AI-facing pointer in the session-start orient block** — one line telling the AI: before building session-recovery / branch / context / transcript tooling, check what Charter already provides (`/charter-help`). This directly targets the failure mode (AI rebuilding a shipped feature). Costs ~1 line of orient tokens; high leverage.

## Anti-staleness

`/charter-help` is curated (grouped, not a flat dump) for UX. To stop it drifting from the actual command set, add a plugin-structure test: **every `commands/*.md` (except charter-help itself) must be referenced by name in `charter-help.md`.** The test fails if a future command is added without updating help. Makes the sync enforceable, not hopeful.

Also add "update /charter-help" to the finish ritual's new-command path (workflow.md), so it's part of the discipline.

## Changes

- `commands/charter-help.md` — NEW, curated catalog
- `hooks/session-start.sh` — one-line AI-facing pointer in orient block
- `tests/plugin-structure.test.sh` — every command referenced in help; help command exists
- `tests/session-start.test.sh` — assert the help pointer appears in orient
- `.claude/rules/workflow.md` + `template/.claude/rules/workflow.md` — finish ritual: "if you added a command, add it to /charter-help"
- docs: ARCHITECTURE (commands list + discoverability note), STATUS, AGENTS, README, CONTEXT dogfood, ADR
- version 0.5.1 → 0.6.0
- merge + push + tag + delete branch (v0.4.1 ritual)

## Non-goals

- Auto-generating help from frontmatter (curated reads better; the test enforces sync)
- A separate `/charter-commands` vs `/charter-help` split (one command)
