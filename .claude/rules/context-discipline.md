# Context Discipline

Charter maintains `docs/CONTEXT.md` as working memory across compactions. The AI updates it **inline** during the session — not as a separate finish step.

## When to Write

Append to CONTEXT.md when ANY of these happen:

- **Environment quirk**: non-obvious fact about runtime, OS, tools, services
- **Working pattern**: code/command that solved a non-trivial problem (with one-line "why")
- **Don't repeat**: tried-and-fails, with symptom + the right alternative
- **User emphasis**: the user explicitly says something is important or repeats it
- **Mid-stream decision**: a choice not yet warranting a decision record

## When NOT to Write

- Project state → STATUS.md
- Architecture → ARCHITECTURE.md
- Design choices with alternatives → `docs/decisions/`
- Trivial output, single test passes, command exit codes
- Genuinely ephemeral state

## How to Write

Append to matching section. Terse: 1-2 lines max. Update "Last updated".

Bad: long prose explanation.
Good: `Llama: never use apply_chat_template — adds <|begin_of_text|> + date prefix, breaks regime. Use hand-rolled template.`

## When the User Runs /compact

Capture anything important to CONTEXT.md *before* it's lost. `/charter-remember "..."` is the explicit version.

## Three-tier recovery model (post-/compact)

When the user runs `/compact` and you need to restore context, use the cheapest tier that works:

1. **`/charter-recover`** — reads CONTEXT.md + STATUS.md + active branch plan. Use first.
2. **`/charter-replay`** — reads the dialogue-only filter of this session's transcript (user turns + your text replies, no tool I/O). Use when CONTEXT.md is sparse.
3. **Reading the raw .jsonl** — almost never right; what burned 400k+ tokens in a real case before. Treat as anti-pattern.

If CONTEXT.md was well-maintained during the session, tier 1 is sufficient. The discipline above is what makes tier 1 work; without it, you'll end up at tier 2.

## Pruning

When CONTEXT.md crosses ~200 lines: promote design items to decisions/, empirical items to findings, delete stale entries. CONTEXT.md is alive, not a log.
