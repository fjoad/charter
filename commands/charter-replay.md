---
description: "Tier-2 recovery: rebuild conversational context by reading the dialogue-only filter of this session's transcript (genuine user prompts + your text replies, skipping tool I/O AND harness injections). Use when /charter-recover wasn't enough."
---

Recover the context of THIS conversation by reading only genuine human prompts and your text replies — not tool calls, tool results, thinking, or harness-injected records.

## When to use this vs `/charter-recover`

- **`/charter-recover`** (tier 1) — reads `docs/CONTEXT.md` + `docs/STATUS.md` + the active branch plan. Cheapest. Use first if CONTEXT.md was maintained well.
- **`/charter-replay`** (tier 2, this command) — reads the filtered conversation transcript. Use when CONTEXT.md is sparse, missing nuance, or the user explicitly asks for the conversational through-line. Costs more tokens than `recover` but far less than re-reading the raw .jsonl.
- **Full transcript read** (tier 3) — almost never the right answer. The raw .jsonl contains all the tool I/O and injections that are exactly the noise you're trying to skip.

## Steps

1. **Run the filter script — that's it.** It finds this session's transcript itself (no path needed) and prints the filtered dialogue:

   ```bash
   python3 "${CLAUDE_PLUGIN_ROOT}/scripts/replay-filter.py"
   ```

   The dialogue (`### USER` / `### ASSISTANT` blocks) goes to **stdout** — so its output lands directly in your context. To stderr it writes which transcript it used and a count summary, e.g. `[counts] genuine user prompts: 28 | assistant text replies: 95`.

   The script auto-locates the transcript by encoding the current working directory and finding the newest `*.jsonl` under `~/.claude/projects/<encoded-cwd>/`. It excludes tool calls/results, assistant thinking, subagent/sidechain records, and harness-injected user-role records (task notifications, slash-command echoes, `[Request interrupted]` markers, compaction summaries, standalone image placeholders) — keeping genuine human text, including prompts that legitimately start with `[`.

   **For a very long session**, redirect to a file and read it in chunks instead of dumping it all at once:
   ```bash
   python3 "${CLAUDE_PLUGIN_ROOT}/scripts/replay-filter.py" > /tmp/session-dialog.txt
   ```
   (You can also pass an explicit `<transcript.jsonl>` path as an argument if auto-find picks the wrong file.)

2. **Report the counts** to the user (e.g. "28 genuine prompts, 95 replies"), then use the dialogue to rebuild context.

3. **Also load** `docs/CONTEXT.md` (if it exists), `docs/STATUS.md`, and the active branch plan, the same way `/charter-recover` would. The replay gives nuance; the docs give state.

4. **Summarize briefly:** what was being worked on, where we left off, anything the user explicitly emphasized, and any open questions.

## Fallback (if the script is unavailable)

If `${CLAUDE_PLUGIN_ROOT}/scripts/replay-filter.py` can't be found, find the newest `*.jsonl` under `~/.claude/projects/<cwd-with-every-non-alphanumeric-char-as-dash>/` and filter it yourself — but mind the edge cases the script handles: match the FULL `[Request interrupted` prefix (never a bare `[`, since genuine prompts start with `[`), strip `[Image ...]` placeholders but keep any human text after them, and drop records with `isCompactSummary: true` or tool_result blocks.

## Do NOT

- Read the raw `.jsonl` directly. It contains all the tool I/O and injections you're trying to skip.
- Scroll through tool calls, file reads, or command outputs from earlier in the session.
- Re-fetch URLs or re-run commands whose results are already in the transcript.

The goal is to restore conversational context cheaply. The filtered dialog file is the cheapest viable replay; anything beyond that is wasted tokens.
