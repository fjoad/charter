# v0.8.0 — Token budget: enforced, not aspirational

**Status:** ✅ Complete (2026-06-11) — 96/96 tests pass, real overhead measured (~4.6k tokens on Charter's own repo), ready to merge.
**Branch:** `feat/token-budget`

## Why

The orient block grew unbounded across v0.3–v0.7: STATUS.md (full) + CONTEXT.md (full) + a plan file (full). Worst observed case: after the v0.2.0 merge, main's "latest plan" was the 1,151-line branch-handling plan — injected in full every session. TOKEN-BUDGET.md still claims ~3,550 tokens from the v0.1 era; nobody re-measured. Charter preaches "measure, prune" and doesn't apply it to itself.

## Changes

1. **Skip completed plans on main.** If the latest plan's header says `Status: … Complete/✅`, inject nothing for it (STATUS.md already says what's next). Completed plans are history, not orientation.
2. **Truncate injected files:**
   - Plans (branch plan + main's active plan): first 40 lines + "(truncated — read the file)" marker. Plan headers carry goal/status; details are one Read away.
   - CONTEXT.md: first 200 lines + a marker that doubles as a pruning nudge — 200 is exactly the context-discipline pruning threshold, so the cap enforces the rule.
   - STATUS.md: NOT truncated (canonical doc, "What to Work On Next" lives at the bottom — head-truncation would cut the most important section).
3. **`scripts/measure-overhead.sh`** — runs the hook in a target dir, reports chars / approx tokens of the orient block.
4. **Budget gate in the test suite:** adversarial fixture (600-line CONTEXT.md + 1,200-line in-progress plan) must produce an orient block under 24,000 chars (~6k tokens). If truncation regresses, CI fails.
5. **`/charter-cost`** rewired to run measure-overhead.sh for the actual orient number instead of estimating.
6. **TOKEN-BUDGET.md** re-measured and rewritten with the enforcement story.

## Tests (TDD)

- main + completed plan → plan body NOT injected
- main + long in-progress plan → injected, truncated at 40 lines, marker present, late content absent
- long CONTEXT.md → truncated at 200 lines, pruning-nudge marker, late content absent
- short files → no truncation markers (backward compat)
- adversarial budget fixture → orient block < 24,000 chars

## Non-goals

- Truncating STATUS.md (see above)
- Smart section-aware extraction (head-N + marker is enough; the AI can read files)
