# /charter-replay filter: committed script over in-prompt pipeline

**Date:** 2026-06-09
**Status:** Accepted (supersedes part of 2026-05-12-replay-command.md)

## Context

`/charter-replay` (v0.4.0) shipped with the filter logic embedded in the command's prompt body as a small Python pipeline the model retypes each invocation. The v0.4.0 ADR deliberately chose prompt-as-instruction over a committed script, reasoning that the prompt lets the model adapt and "a static script would do strictly less."

Two things changed that calculus:

1. **A sibling Charter session independently rebuilt `/charter-replay`** (it was on an old cached Charter and didn't know the command existed). In doing so it surfaced that the v0.4.0 filter is naive: it keeps *all* `type=user` text, so harness-injected user-role records (task notifications, slash-command echoes, interrupt markers, compaction summaries) get counted as genuine human prompts.

2. **A parallel sweep of ~7,800 transcripts across 11 projects** (8,542 genuine prompts vs 288 injections) revealed the filter needs real edge-case handling that is easy to get wrong when re-derived in-prompt:
   - The interrupt marker must match the **full** `[Request interrupted` prefix — never a bare `[`, because genuine prompts legitimately start with `[` (`[Image #3]...`, pasted logs `[11:27:15] ...`, event traces).
   - Image placeholders (`[Image: ...]`) must be **stripped but the record kept** when human text follows (`[Image #3] what is this?`), not dropped wholesale.
   - Compaction is most robustly detected by the structural `isCompactSummary` flag, with a text-prefix fallback.
   - Structural flags alone are insufficient: genuine prompts can carry `isMeta=True`; injections can carry no flags. So it's a hybrid (structural-first, text-marker fallback).

A model re-deriving this pipeline in-prompt can plausibly shorten `[Request interrupted` to `[` (dropping genuine prompts) or blanket-drop `[Image` (dropping a genuine prompt). Those are correctness bugs, not flexibility.

## Decision

**Ship the filter as a committed, unit-tested script: `scripts/replay-filter.py`.** `/charter-replay.md` invokes it via `${CLAUDE_PLUGIN_ROOT}/scripts/replay-filter.py` and reads the output. The command body still explains what the filter does (so the model understands the result) and includes an inline fallback for the rare case the script is unavailable — but with explicit edge-case warnings.

This supersedes the v0.4.0 "prompt-only" decision **for this filter specifically**. The general Charter principle (commands are prompt-as-instruction) still holds for everything else; this is the one case where the logic is fiddly enough that exactness beats adaptability.

The script also adds the **turn-count report** (genuine prompts / assistant replies) the sibling session demonstrated was useful — emitted to stderr so it doesn't pollute the dialogue file.

## Alternatives Considered

1. **Keep it in-prompt, just add the new markers.** Rejected — the `[`-prefix and image-strip edge cases are exactly the kind a model gets subtly wrong when retyping. A committed script is verifiable once and stays correct.

2. **Full structural-metadata filter (no text matching).** Rejected empirically — `isMeta`/`isSidechain` don't separate genuine from injected (measured: genuine prompts with `isMeta=True`, injections with no flags). Structural flags are used where they ARE reliable (`isCompactSummary`, `tool_result` block type, `isSidechain`); text-marker matching covers the rest.

3. **Reproduce the sibling's full `session_recap.py`.** Rejected — it did more than needed (per-category breakdowns, dedup-by-id). Charter's script is the minimal correct filter + counts.

## Consequences

- `/charter-replay` is now reliable across session types (MCP-heavy, plan-mode, compaction, sidechain) — not just clean sessions.
- The filter is directly unit-testable. `tests/replay-filter.test.sh` runs it against `tests/fixtures/replay-sample.jsonl`, a fixture with one record of every injection category + the two tricky edge cases (`[`-log-line kept, `[Image #N] text` kept-but-stripped).
- One more script in `scripts/`. CI already runs the full suite, so regressions are caught.
- Marker list may need updating if Claude Code introduces new injection types. The script's docstring records the empirical provenance so a future maintainer knows where the list came from.
- **Meta:** three sibling sessions have now independently rebuilt Charter features (branch cleanup → v0.4.1, this filter → v0.5.1). Discoverability is the real weakness. A `/charter-help` command listing what's available is worth considering next.
