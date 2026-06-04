# v0.5.0 — /charter-preview + CONTEXT-per-branch articulation

**Status:** In progress
**Branch:** `feat/preview-and-context-per-branch`

**Goal:** Two small, related additions, no architectural change.

1. **`/charter-preview`** — dry-run that lists what `/charter-init` or `/charter-attach` would scaffold, marks each file as NEW or COLLISION, shows the available `/charter-adopt` conventions. Solves the "I want to evaluate Charter before committing to it" UX gap without breaking the everything-in-docs principle.

2. **Articulate CONTEXT.md as already per-branch.** v0.3.0 shipped CONTEXT.md as a tracked file but didn't explicitly say "each branch has its own working memory; it merges like any other file." Document the intent in ARCHITECTURE.md, the Branch Discipline rule, and the feature-branch finish flow. No code changes.

## File changes

- `commands/charter-preview.md` — NEW
- `docs/ARCHITECTURE.md` — add CONTEXT-per-branch paragraph in Working Memory section; add preview command to "How to Extend" or commands list
- `template/.claude/rules/workflow.md` Branch Discipline section — bullet: "CONTEXT.md edits ARE allowed on feature branches (unlike STATUS.md component sections) — it's branch-scoped working memory"
- `.claude/rules/workflow.md` — same edit (Charter's own copy)
- `commands/charter-finish.md` feature-branch flow — clarify CONTEXT.md update is permitted there
- `tests/plugin-structure.test.sh` — new assertions: preview command exists, has expected sections
- `docs/CONTEXT.md` (Charter's own) — append entries about this
- `docs/decisions/2026-06-04-preview-and-context-per-branch.md` — small ADR
- `docs/STATUS.md` — add row, In-flight, Recent Decisions, What's Next
- `AGENTS.md`, `README.md` — surface preview command
- `.claude-plugin/plugin.json`, `package.json` — bump to 0.5.0
- After merge: delete this branch (per v0.4.1 ritual)

## Non-goals

- Monorepo support (deferred — thinking pass coming this turn, no code)
- Auto-promotion of branch-local CONTEXT entries to main on merge
- Charter-managed CONTEXT diffing
