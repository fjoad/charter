# Smart recover: one recovery entry point, auto-escalation

**Date:** 2026-06-11
**Status:** Accepted (revises part of 2026-05-12-replay-command.md)

## Context

Post-/compact recovery had grown to five user-facing concepts: CONTEXT.md, `/charter-remember`, `/charter-recover`, `/charter-replay`, and the three-tier model explaining when to use which. The tier choice lands on the user (or a freshly-compacted AI) at the worst possible moment — while disoriented. The v0.4.0 ADR argued recover and replay must stay semantically separate ("recover means skip transcript; making the inverse a flag is confusing"). That reasoning optimized for conceptual purity over the actual interface need: "get my bearings back."

More broadly: 12 commands across 8 releases with no structural check on surface growth. Every addition was individually justified — which is exactly how lightweight tools stop being lightweight.

## Decision

1. **`/charter-recover` is the single recovery entry point.** It assesses `docs/CONTEXT.md` itself: healthy → docs-only read (old tier 1); thin or missing (placeholders only, or < ~25 lines of real content) → auto-runs `scripts/replay-filter.py` (old tier 2) without asking. The report states which path ran. The tier model becomes implementation detail.
2. **`/charter-replay` remains** as direct access to the replay script — unchanged mechanics — but `/charter-help` demotes it to "Power / occasional."
3. **`/charter-help` reorganized** into Daily (5 commands) / Setup (5) / Power (2). Nothing deleted; perceived surface shrinks to what you actually touch.
4. **Growth guardrail:** workflow.md's Decision Records section now requires any new-command ADR to answer *"why can't an existing command absorb this?"*

## Alternatives Considered

1. **Keep tier choice with the user (status quo).** Rejected — the choice has a correct answer computable from CONTEXT.md's state; making a disoriented human (or AI) compute it is pure friction.
2. **Delete `/charter-replay` entirely.** Rejected — direct access is occasionally exactly right ("show me the whole dialogue"), it's zero maintenance (same script), and deleting a shipped command breaks muscle memory for no token savings.
3. **Auto-escalate all the way to the raw transcript (tier 3) when even replay output is insufficient.** Rejected — tier 3 stays a documented anti-pattern, never automated.
4. **Hard cap on command count.** Rejected — arbitrary number, gameable by overloading commands. The ADR-question guardrail forces the right conversation per addition instead.

## Consequences

- Recovery UX collapses from "know the tier model" to "run /charter-recover." The thin-CONTEXT heuristic (~25 lines / all placeholders) is prose guidance to the model, not parsed code — deliberately fuzzy, since the model can see the file.
- The v0.4.0 ADR's separation argument is explicitly revised; this ADR documents why (solo-workflow interface beats conceptual purity).
- Future command additions carry a small, permanent justification burden — by design.
