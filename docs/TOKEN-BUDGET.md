# Token Budget

Charter's promise is "whisper not shout." Every token it consumes should be justified. This doc explains the cost model and measurements.

---

## Per-Session Overhead

| Source | Tokens | Frequency | Notes |
|--------|--------|-----------|-------|
| Rule files (project-flow + workflow + turn-ritual + testing) | ~1,350 | Once per session | Auto-loaded from `.claude/rules/` |
| Session-start orient block | ~200–800 | Once per session | Depends on STATUS.md + plan length |
| Per-turn nudge | ~20 | Every turn | "Classify this request..." |
| **Total (100-turn session)** | **~3,550** | | |

---

## As a Percentage of Context

| Context window | Charter overhead | % |
|----------------|-----------------|---|
| 200,000 tokens | ~3,550 | **1.8%** |

Charter consumes less than 2% of Claude's context window in a typical session.

---

## What You Get for It

- Zero manual orientation on session start
- Every request classified to correct ritual depth automatically
- Finish checklist fires before step completion
- Decision rationale preserved in `docs/decisions/`
- Status current across sessions

The alternative is spending 500–1,000 tokens per session re-orienting Claude manually. Charter is cheaper.

---

## Measuring Your Own Overhead

Run `/charter-cost` mid-session to get a breakdown for your current session. It reports:
- Session-start orient block size (actual, not estimated)
- Number of turns × 20 tokens for nudges
- Rule file token count

---

## The "Whispering PMO" Design

Charter's hook discipline follows one rule: **inject at the minimum effective dose**.

- `SessionStart` fires once. It injects the orient block — STATUS + active plan. That's it.
- `UserPromptSubmit` injects 20 tokens. Not 200. Not a full system prompt. A nudge.
- Rule files are loaded by Claude Code's `.claude/rules/` auto-discovery. They don't repeat per-turn — they're in context once.

This is deliberate. A Charter that consumed 10% of context per session would defeat its purpose by eating the context it's trying to protect.

---

## If You Want Less Overhead

**Reduce rule file length:** Edit `.claude/rules/` files. Remove sections you don't use.

**Reduce orient block:** Trim `docs/STATUS.md` to just the essentials. The hook reads the whole file.

**Skip the turn nudge:** Comment out the `UserPromptSubmit` hook in `.claude-plugin/plugin.json`. You lose tier classification but keep session orient.

**Go full minimal:** Keep only `session-start.sh`. ~200-800 tokens per session, zero per-turn overhead. Still better than no Charter.
