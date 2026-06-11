---
description: "Report the token overhead Charter adds to this session: measured session-start orient block, per-turn nudges, and rule-file overhead."
---

The user wants to understand Charter's token overhead for this session.

Report the token cost Charter has added — **measured, not estimated, where possible**:

1. **Session-start orient block (measure it):** run

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/measure-overhead.sh" .
   ```

   This re-runs the SessionStart hook for this project and reports the actual chars / ~tokens injected, plus whether any truncation caps are active. (If the script is unavailable, estimate: STATUS.md length + injected CONTEXT.md (≤200 lines) + injected plan (≤40 lines) + ~120 tokens of framing.)

2. **Per-turn nudge:** the UserPromptSubmit hook injects ~25 tokens per turn. Multiply by the approximate number of turns this session.

3. **Rule files loaded:** `.claude/rules/` files load into context each session. Count the actual files present in this project's `.claude/rules/` and estimate ~4 tokens per line (`wc -l .claude/rules/*.md`).

4. **Ritual overhead:** any plans or verification output created this session (part of productive work, not pure overhead — include for transparency).

Format:

**Charter Token Overhead — This Session**

| Source | Tokens | Notes |
|--------|--------|-------|
| Session-start orient | ~[measured N] | measured via measure-overhead.sh |
| Per-turn nudge | ~[N] | ~25 tokens × [N] turns |
| Rule files | ~[N] | [list files counted] |
| **Total overhead** | **~[N]** | |
| **Overhead % of 200k context** | **~[N]%** | |

If a truncation marker was reported, note which file is over its cap and suggest pruning (CONTEXT.md over 200 lines should be pruned per context-discipline).
