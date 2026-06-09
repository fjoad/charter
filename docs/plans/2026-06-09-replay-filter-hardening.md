# v0.5.1 — /charter-replay filter hardening + turn counts

**Status:** ✅ Complete (2026-06-09) — 70/70 tests pass, filter shipped as script, ready to merge.
**Branch:** `feat/replay-filter-hardening`

## Why

A sibling Charter session independently rebuilt `/charter-replay` (didn't know it existed / was on old cached Charter). In doing so it surfaced a real gap: the current `/charter-replay` filter keeps **all** `type=user` text, so harness-injected user-role records are wrongly counted as genuine human prompts.

Empirically verified on this session's transcript: 28 genuine prompts vs 4 injected (`local-command` ×3, `compaction` ×1) that the current filter miscounts. Structural metadata (`isMeta`, `isSidechain`) does NOT cleanly separate them (genuine prompts can carry `isMeta=True`; injections can carry no flags), so text-marker matching is the reliable approach.

A background workflow swept all 11 projects' transcripts to enumerate the complete injection-marker set (this session only exposed ~5 types; other session kinds — MCP-heavy, plan-mode, computer-use — have others).

## Changes

1. **`commands/charter-replay.md`** — rewrite the filter to exclude harness-injected user-role records (the comprehensive marker set from the sweep). Keep only genuine human prompts + assistant text.
2. **Add optional turn counts** — after filtering, report `N genuine user prompts / M assistant text replies` (the sibling's useful addition).
3. **`tests/plugin-structure.test.sh`** — assertions that the filter spec mentions the key injection categories and the no-tool-IO rule.
4. **Optional `tests/replay-filter.test.sh`** — a real behavioral test: run the filter against a fixture JSONL with known injections, assert genuine count is correct.
5. Docs: ARCHITECTURE.md (note the filter hardening), CONTEXT.md dogfood entry, ADR, STATUS/AGENTS/README.
6. Version bump 0.5.0 → 0.5.1. Merge + push + tag + delete branch (per v0.4.1 ritual).

## Open design question (resolved by sweep synthesis)

Script-vs-prompt: keep the prompt-as-instruction approach (v0.4.0 ADR), but make the embedded filter comprehensive. A committed script is more reliable for exact counts but goes stale as harness formats change; the prompt lets the model adapt. Decision pending synthesis recommendation.

## Non-goals

- Reproducing the sibling's full session_recap.py as a committed script (unless synthesis strongly favors it)
- Monorepo (still deferred)
