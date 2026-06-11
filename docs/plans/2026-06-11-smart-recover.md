# v0.9.0 — smart recover + surface-growth control

**Status:** ✅ Complete (2026-06-11) — 107/107 tests pass, ready to merge.
**Branch:** `feat/smart-recover`

## Why

The recovery surface is five concepts deep (CONTEXT.md, remember, recover, replay, the tier model) and the user has to choose between tiers *while disoriented* — the worst moment to demand a decision. Separately, Charter has grown to 12 commands across 8 releases with no structural check on surface growth.

## Changes

1. **`/charter-recover` becomes the single smart entry point.** It inspects CONTEXT.md itself: missing, or thin (every section still `_None recorded yet._`, or < ~25 lines of real entries) → auto-escalates to tier 2 (runs `replay-filter.py` one-shot) without asking. The tier model becomes implementation detail; the report states which tier ran. This deliberately revises the v0.4.0 ADR's "recover and replay must stay semantically separate" — wrong call for a solo workflow; the user's interface should be "get my bearings back", not a tier menu.
2. **`/charter-replay` stays** as direct/explicit access (and the underlying script is unchanged). Help demotes it to a power-user note.
3. **`/charter-help` reorganized** into "Daily" vs "Power / occasional" sections — perceived surface drops even though nothing is deleted.
4. **Growth guardrail** in workflow.md Decision Records: any new command's ADR must answer "why can't an existing command absorb this?"
5. Both context-discipline rules updated (recover auto-escalates; replay = direct access). ADR, STATUS, CONTEXT, README/AGENTS touches, bump 0.9.0.

## Non-goals

- Deleting any command (cheap to keep; decision load was the real cost)
- Auto-escalation beyond tier 2 (tier 3 stays an anti-pattern, never automated)
