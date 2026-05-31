# v0.4.0 — /charter-replay (Tier-2 Recovery)

**Status:** ✅ Complete (2026-05-12) — shipped, 48/48 fast + 14/14 e2e tests pass, ready to merge.
**Branch:** `feat/replay-command`

**Goal:** Add `/charter-replay` — dialogue-only transcript replay for context recovery when CONTEXT.md isn't enough. Fills the missing middle tier between `/charter-recover` (CONTEXT.md only, cheapest) and a full transcript re-read (most expensive, almost never right).

**Architecture:** New command, plugin-side only. Reads the current session's JSONL, filters to user-text + assistant-text only (skipping tool I/O), reads the filtered output. Same capability-detection / additive pattern as v0.3.0: missing CONTEXT.md isn't a problem, command still works using just the transcript.

## Three-tier recovery model (documented)

| Tier | Command | What it reads | Use when |
|---|---|---|---|
| 1 | `/charter-recover` | CONTEXT.md + STATUS.md + active branch plan | CONTEXT.md was well-maintained |
| 2 | `/charter-replay` | Filtered transcript (user + assistant text, no tool I/O) | CONTEXT.md sparse or missing the nuance |
| 3 | (no command) | Full raw transcript | Almost never. Documented as anti-pattern. |

## File changes

**Plugin-side:**
- `commands/charter-replay.md` — NEW
- `commands/charter-recover.md` — extend with one paragraph mentioning `/charter-replay` as the next-tier fallback
- `template/.claude/rules/context-discipline.md` — extend with the three-tier reference
- `.claude/rules/context-discipline.md` (Charter's own) — same
- `.claude-plugin/plugin.json`, `package.json` — bump to 0.4.0

**Dogfood:**
- `docs/CONTEXT.md` — append a "Working Pattern" entry about the three-tier recovery
- `docs/STATUS.md`, `docs/ARCHITECTURE.md`, `AGENTS.md`, `README.md`
- `docs/decisions/2026-05-12-replay-command.md` — ADR

**Tests:**
- `tests/plugin-structure.test.sh` — assertions: charter-replay.md exists, has the Python pipeline, mentions the encoded-cwd derivation; charter-recover.md mentions /charter-replay; context-discipline mentions all three tiers

## Tasks

1. ✅ Branch + plan
2. Write `commands/charter-replay.md` with the prompt body I just shared with the user
3. Extend `commands/charter-recover.md` with the tier-2 fallback note
4. Extend both context-discipline rules with three-tier reference
5. Plugin-structure tests
6. Dogfood: update Charter's CONTEXT.md, STATUS.md, ARCHITECTURE.md, AGENTS.md, README.md
7. ADR
8. Bump to v0.4.0, run verify-plugin.sh
9. Run e2e (should pass unchanged — replay doesn't affect session-start hook)
10. Merge + main-branch finish + push + tag

## Non-goals

- Automatic tier escalation. The user chooses which tier; we don't auto-detect "CONTEXT.md is insufficient, escalate to replay."
- Caching the filtered dialog. Each invocation regenerates it (it's cheap; the JSONL is local).
- Editing or grouping turns. The output is a faithful filtered replay, nothing more.
