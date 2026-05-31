---
description: "Restore orientation after /compact. Reads CONTEXT.md + STATUS.md + active branch plan, in that order. Skip the transcript."
---

The user has just run `/compact` (or wants explicit re-orientation). Your job: restore working context without re-reading the conversation transcript.

**Critical:** Do NOT read the session JSONL or scroll back through prior messages — that costs hundreds of thousands of tokens and is usually wasteful. Use the docs Charter maintains for exactly this purpose.

## Three-tier recovery model

- **Tier 1 (this command, cheapest):** read CONTEXT.md + STATUS.md + active branch plan.
- **Tier 2 (`/charter-replay`, medium):** if CONTEXT.md is sparse / missing nuance, fall back to a filtered transcript read (user turns + assistant text only, skipping all tool I/O). Use when this command's output feels insufficient.
- **Tier 3 (no command, anti-pattern):** reading the full raw .jsonl is almost never right — it's the 400k+ token waste pattern.

If after this command's read you feel critical context is missing (recent decisions weren't captured, the user emphasized something not in CONTEXT.md), suggest the user run `/charter-replay` rather than scrolling back through tool calls.

## Recovery read order

1. **`docs/CONTEXT.md`** — working memory across compactions. Has environment quirks, working patterns, don't-repeats, open questions, user emphases. If this file is missing, tell the user `/charter-adopt context` would have helped — but proceed.

2. **`docs/STATUS.md`** — current project state, component table, what to work on next.

3. **Active branch plan** — run `git rev-parse --abbrev-ref HEAD`. If on a feature branch, find the matching plan in `docs/plans/` (filename slug containing the branch tail) and read it. If on main, skip.

## Do NOT read (unless explicitly cited above)

- The session transcript / JSONL
- `docs/ARCHITECTURE.md` (only if STATUS or CONTEXT cites structural concern)
- `docs/VISION.md` (only if the user asks "what are we building")
- Other plans in `docs/plans/` (only the one for the current branch)
- Decision records (only if cited)

## Report

After reading, output 3-5 lines max:

```
Recovered:
- Project: [one-line project state from STATUS]
- Current step: [from STATUS "What to Work On Next" or branch plan]
- Working memory: [count] entries across [list active sections] (or: empty)
- Open questions / blockers: [from CONTEXT.md Open Questions, or "none"]
- Next: [continue last task / await user input]
```

Then ask the user what to do next, or continue from the last in-flight task if it's obvious from the branch plan.
