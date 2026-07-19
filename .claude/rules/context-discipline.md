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
- Durable causal corrections (former belief → disconfirming evidence → root cause → new conclusion) →
  `docs/EVIDENCE-AND-LEARNINGS.md` when adopted. Leave only a terse pointer in CONTEXT.md if active.
- Trivial output, single test passes, command exit codes
- Genuinely ephemeral state

## How to Write

Append to matching section. Terse: 1-2 lines max. Update "Last updated".

Bad: long prose explanation.
Good: `Llama: never use apply_chat_template — adds <|begin_of_text|> + date prefix, breaks regime. Use hand-rolled template.`

## When the User Runs /compact

Capture anything important to CONTEXT.md *before* it's lost. `/charter-remember "..."` is the explicit version.

## Recovery (post-/compact)

`/charter-recover` is the single entry point — it reads CONTEXT.md + STATUS.md + the active branch plan, and **auto-escalates** to the transcript replay (`scripts/replay-filter.py`) when CONTEXT.md is thin or missing. You don't pick a tier; it does. (`/charter-replay` is direct access to the replay when explicitly wanted.) Reading the raw .jsonl is an anti-pattern — it burned 400k+ tokens in a real case.

The discipline above is what keeps recovery cheap: a well-maintained CONTEXT.md means recover never needs the transcript.

## Pruning

When CONTEXT.md crosses ~200 lines: promote design items to decisions/, durable causal corrections to
EVIDENCE-AND-LEARNINGS.md when adopted, other empirical items to findings, and delete stale entries.
CONTEXT.md is alive, not a log.
