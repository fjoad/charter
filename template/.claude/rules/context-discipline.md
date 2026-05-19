# Context Discipline

Charter maintains `docs/CONTEXT.md` as working memory across compactions. The AI updates it **inline** during the session — not as a separate finish step. After `/compact`, run `/charter-recover` to restore orientation from CONTEXT.md, STATUS.md, and the active branch plan.

## When to Write to CONTEXT.md

Append when ANY of these happen:

- **Environment quirk**: a non-obvious fact about the runtime, OS, tools, or services
  - Example: "macOS lacks `timeout` by default — use `gtimeout` from coreutils or skip the timeout"
- **Working pattern**: a code snippet or command that solved a non-trivial problem (with the one-line "why")
  - Example: "Plugin e2e test: `claude -p --plugin-dir <local> --output-format=stream-json --include-hook-events`"
- **Don't repeat**: something tried that fails, with the symptom
  - Example: "Bash heredoc `<<'PY'` overrides pipes — use `python3 -c \"$(...)\"` to keep stdin free for piped input"
- **User emphasis**: the user explicitly says something is important, load-bearing, or repeats it
- **Mid-stream decision**: a choice that doesn't yet warrant a decision-record file but might surface again

## When NOT to Write

- Project state → STATUS.md
- Structural architecture → ARCHITECTURE.md
- Design choices with alternatives weighed → `docs/decisions/`
- Trivial output (file lists, single test passes, command exit codes)
- Genuinely ephemeral state that won't matter in the next turn

## How to Write

Append to the matching section in CONTEXT.md. **Terse: 1-2 lines max per entry.** Update the "Last updated" date.

Bad: "We discovered that when using `apply_chat_template` for the Llama model, the tokenizer adds an unexpected `<|begin_of_text|>` token at the beginning and also injects a date prefix, which breaks our regime extraction…"

Good: "Llama: never use `apply_chat_template` — adds `<|begin_of_text|>` + date prefix, breaks regime. Use hand-rolled template."

## When the User Runs /compact

If you anticipate `/compact` (context near full) or see that it just happened, capture anything important to CONTEXT.md *before* losing it. The `/charter-remember "..."` command is the explicit version.

## Pruning

When CONTEXT.md crosses ~200 lines, audit:
- Promote design-y items to `docs/decisions/`
- Promote empirical findings to a findings record (or write one)
- Delete items that are now obvious or out of date
- Keep CONTEXT.md focused on currently-active working memory

CONTEXT.md is **alive**, not a log. Old entries that no longer matter should be removed, not archived.
