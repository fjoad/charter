# Orient-block token budget: enforced, not aspirational

**Date:** 2026-06-11
**Status:** Accepted

## Context

The session-start orient block grew unbounded across v0.3–v0.7: STATUS.md (full) + CONTEXT.md (full) + a plan file (full). Worst observed case: after the v0.2.0 merge, main's most-recently-modified plan was the 1,151-line (completed) branch-handling plan — injected in full, every session, as "Active Plan". TOKEN-BUDGET.md still claimed ~3,550 tokens from the v0.1 era; `/charter-cost` estimated instead of measuring; nothing enforced anything. Charter preaches "measure, prune" and didn't apply it to itself.

## Decision

Bound the orient block and gate it in CI:

1. **Completed plans are never injected on main.** `plan_is_complete()` checks the header for `Status: … Complete/✅`. History is not orientation; STATUS.md already says what's next. This kills the worst case outright.
2. **Line caps with read-the-file markers:** plans (branch or main) at 40 lines; CONTEXT.md at 200 lines. The CONTEXT cap is exactly the context-discipline pruning threshold, so the cap operationalizes the rule — and its marker explicitly nudges pruning.
3. **STATUS.md stays uncapped** — deliberate. "What to Work On Next", the single most important orient section, lives at the *bottom* of the file; head-truncation would cut it while keeping the boilerplate. Keeping STATUS tight remains a doc discipline, and the budget gate catches pathology.
4. **`scripts/measure-overhead.sh`** measures the real orient block for any project (chars / ~tokens / active truncation markers). `/charter-cost` now runs it instead of estimating.
5. **CI budget gate:** an adversarial fixture (600-line CONTEXT + 1,200-line in-progress plan) must produce an orient block under 24,000 chars (~6k tokens). Truncation regressions fail the suite.

Measured reality (v0.8.0): Charter's own repo orients at ~4,600 tokens (heavy dogfood project mid-feature-branch); the adversarial fixture bounds at ~6k.

## Alternatives Considered

1. **Section-aware extraction (parse plans/CONTEXT for the "important" parts).** Rejected — fragile parsing for marginal gain; head-N + an explicit "read the file" marker keeps the full content one tool call away.
2. **Char-based caps instead of line-based.** More precise (dense lines cost more), but line counts are what the pruning discipline already speaks in (the 200-line rule), and wc -l is simpler. The CI gate is char-based, so char-pathology is still caught.
3. **Truncating STATUS.md.** Rejected — see Decision #3. Bottom-heavy file; head-truncation cuts the wrong end.
4. **Tail-truncation for STATUS (keep the bottom).** Considered; rejected for now — losing the component table header makes the remainder confusing, and a tight STATUS is already the doc's own discipline.

## Consequences

- Orient cost is now bounded and *tested*; TOKEN-BUDGET.md numbers are measured, with the measurement tool shipped.
- A completed plan no longer shadows "no active work" on main — sessions right after a merge get a leaner, more accurate orient.
- Line-based caps under-count dense lines (CONTEXT.md entries can run 300+ chars); the char-based CI gate backstops this. Noted in TOKEN-BUDGET.md.
- If a plan legitimately needs more than 40 lines of orientation, the marker tells the AI exactly which file to read — one tool call.
