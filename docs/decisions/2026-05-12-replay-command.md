# /charter-replay — Tier-2 Recovery

**Date:** 2026-05-12
**Status:** Accepted

## Context

v0.3.0 introduced `docs/CONTEXT.md` and `/charter-recover` as the cheap post-`/compact` recovery path. The model assumes the context-discipline rule was followed throughout the session: if CONTEXT.md is well-maintained, tier-1 recovery is sufficient.

In practice, this assumption breaks. Discipline lapses. Sessions sometimes start before CONTEXT.md is adopted. Even diligent maintenance misses nuance — a user's emphasis paraphrased in CONTEXT.md isn't the same as the actual exchange where they said it.

The natural fallback — re-reading the raw session JSONL — wastes hundreds of thousands of tokens on tool I/O (file reads, command outputs, search results) that aren't context-bearing. A real case in another project burned ~440k tokens this way before the user told Claude *"please just open the json file for this conversation and nothing else. then just read every user turn and your reply line by line."*

That instruction is the prototype. We're systematizing it.

## Decision

Ship `/charter-replay` as a **tier-2 recovery command**: read the current session's transcript filtered down to user turns + assistant text only, skipping all tool I/O.

Three-tier recovery model:

| Tier | Command | What it reads | Cost |
|---|---|---|---|
| 1 | `/charter-recover` | CONTEXT.md + STATUS.md + active branch plan | cheapest |
| 2 | `/charter-replay` | filtered transcript (user + assistant text) | medium |
| 3 | (none) | raw JSONL | anti-pattern |

Tier 2 is the bridge between tier 1's curated-docs-only and tier 3's all-the-tool-noise. It's the *cheapest viable recovery* when CONTEXT.md isn't enough.

## Mechanics

The command's prompt body instructs the model to:

1. Find the session JSONL via the convention `~/.claude/projects/<encoded-cwd>/*.jsonl` (cwd `/` → `-`), pick the most-recently-modified.
2. Pipe it through a Python filter that keeps `type=user`/`type=assistant` entries, extracts only `{type:"text"}` content blocks, drops everything else.
3. Write to `/tmp/session-dialog.txt`.
4. Read that file. Also load CONTEXT.md and STATUS.md to combine replay (nuance) with docs (state).

The Python pipeline is portable (works on macOS BSD + Linux GNU) and pure-stdlib.

## Alternatives Considered

1. **Make it a flag on `/charter-recover`** (e.g., `/charter-recover --deep`). Rejected — `/charter-recover` is semantically "skip transcript"; making the inverse a flag is confusing. Two commands with opposite semantics is cleaner.

2. **Auto-tier-escalation** — have `/charter-recover` notice when CONTEXT.md is sparse and chain to `/charter-replay`. Rejected for v0.4 — adds complexity and "how does it know sparse?" is hard to define cheaply. User-driven tier choice is fine.

3. **Cache the filtered dialog file** across invocations. Rejected — the JSONL is local and parsing is fast (<1s for typical sessions). Cache invalidation isn't worth the complexity.

4. **Make it a skill rather than a command.** Rejected — recovery is user-initiated, not autonomous. Skills fit the "AI decides to invoke" model; this is "user explicitly asks for tier-2 recovery."

5. **Ship a separate Bash script in `scripts/` that does the filter.** Rejected — the prompt-as-instruction model lets the model adapt (e.g., handle a path with spaces, find the JSONL when multiple match, summarize after reading). A static script would do strictly less.

## Consequences

- One more command to maintain alongside the existing eight.
- The three-tier model is now load-bearing across `/charter-recover`, `/charter-replay`, the two `context-discipline.md` rules, and downstream docs. Edits to one tier should be checked against the others for consistency.
- Backward compatible: no required structures, no existing project changes. Just an additional command available in v0.4.0+.
- The prompt body of `/charter-replay` is also useful as a **standalone instruction** — users can copy-paste it into a non-Charter session to get the same recovery behavior. This is a feature, not a leak.
