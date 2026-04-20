---
description: "Report the token overhead Charter adds to this session: session-start orient block, per-turn nudges, and ritual overhead from rule files."
---

The user wants to understand Charter's token overhead for this session.

Estimate and report the token cost Charter has added to this session:

1. **Session-start orient block**: The SessionStart hook injects current STATUS.md + active plan into context once per session. Estimate tokens: length of STATUS.md + length of active plan + ~50 tokens of framing. If no STATUS.md exists, this was 0.

2. **Per-turn nudge**: The UserPromptSubmit hook injects ~20 tokens per turn. Multiply by approximate number of turns this session.

3. **Rule files loaded**: .claude/rules/ files are loaded into context each session. Estimate tokens for: project-flow.md (~400 tokens), workflow.md (~350 tokens), turn-ritual.md (~350 tokens), testing.md (~250 tokens). Total: ~1,350 tokens per session.

4. **Ritual overhead**: Any writing-plans or verification outputs created this session (these are part of productive work, not pure overhead, but include them for transparency).

Format:

**Charter Token Overhead — This Session**

| Source | Tokens | Notes |
|--------|--------|-------|
| Session-start orient | ~[N] | STATUS.md + active plan, once |
| Per-turn nudge | ~[N] | ~20 tokens × [N] turns |
| Rule files | ~1,350 | Loaded once per session |
| **Total overhead** | **~[N]** | |
| Context window | ~200,000 | Claude's context size |
| **Overhead %** | **~[N]%** | Overhead / context window |

Note: Rule files and the orient block are what make Charter useful — without them, Claude starts each session cold. The cost is the price of continuity.
