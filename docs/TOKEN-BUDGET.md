# Token Budget

Charter's promise is "whisper not shout." Every token it consumes should be justified. This doc explains the cost model, the **measured** numbers, and — as of v0.8.0 — how the budget is *enforced* rather than aspirational.

---

## Per-Session Overhead (measured, v0.8.0)

| Source | Tokens | Frequency | Notes |
|--------|--------|-----------|-------|
| Rule files (project-flow + workflow + turn-ritual + testing + context-discipline) | ~1,500 | Once per session | Auto-loaded from `.claude/rules/` |
| Session-start orient block | ~600–4,600 | Once per session | Measured: ~4,615 on Charter's own repo (heavy dogfood project, mid-feature-branch with CONTEXT.md + branch plan); simpler projects run far lower |
| Per-turn nudge | ~25 | Every turn | "Classify this request..." |
| **Typical total (100-turn session)** | **~4,500–8,500** | | |

As a share of a 200k context window: **~2–4%**. On 1M-context models: under 1%.

Measure your own project's real number any time:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/measure-overhead.sh" .
```

`/charter-cost` runs this for you and adds the per-turn and rule-file numbers.

---

## How the budget is enforced (v0.8.0)

The orient block is **bounded**, not just observed:

| Injected file | Cap | Behavior over cap |
|---|---|---|
| Latest plan on main | skipped entirely if its header says `Status: … Complete` | Completed plans are history — STATUS.md already says what's next |
| Plan (branch or main, in-progress) | 40 lines | Truncated with a "read the file for the rest" marker |
| CONTEXT.md | 200 lines | Truncated with a marker that nudges pruning — 200 is exactly the context-discipline pruning threshold, so the cap enforces the rule |
| STATUS.md | uncapped | Deliberate: "What to Work On Next" lives at the bottom; head-truncation would cut the most important section. Keep STATUS tight — that's its discipline. |

A CI-gated test injects an adversarial fixture (600-line CONTEXT.md + 1,200-line plan) and fails if the orient block exceeds **24,000 chars (~6k tokens)**. Before v0.8.0, that fixture produced an unbounded block (the post-v0.2.0 worst case was a 1,151-line completed plan injected in full, every session).

---

## What You Get for It

- Zero manual orientation on session start
- Every request classified to correct ritual depth automatically
- Finish checklist fires before step completion
- Working memory that survives `/compact` (and tiered recovery when it doesn't)
- Decision rationale preserved in `docs/decisions/`

The alternative is spending 500–1,000 tokens per session re-orienting Claude manually — plus the occasional 100k+ token transcript re-read after a compaction. Charter is cheaper.

---

## The "Whispering PMO" Design

Charter's hook discipline follows one rule: **inject at the minimum effective dose**.

- `SessionStart` fires once. It injects the orient block — STATUS + working memory + active plan, each bounded as above.
- `UserPromptSubmit` injects ~25 tokens. Not 200. A nudge.
- Rule files are loaded by Claude Code's `.claude/rules/` auto-discovery. They don't repeat per-turn.

---

## If You Want Less Overhead

**Prune CONTEXT.md.** On a long-lived project this is usually the biggest single component — and pruning is already the discipline; the 200-line cap will start nagging you anyway. Note the cap is line-based: dense 300-char lines cost more than the line count suggests.

**Trim STATUS.md.** It's injected in full by design. Keep the component table tight; archive stale rows.

**Reduce rule file length:** Edit `.claude/rules/` files. Remove sections you don't use.

**Skip the turn nudge:** Comment out the `UserPromptSubmit` hook in `hooks/hooks.json`. You lose tier classification but keep session orient.

**Go full minimal:** Keep only `session-start.sh`. Zero per-turn overhead. Still better than no Charter.
