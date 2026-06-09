---
description: "Tier-2 recovery: rebuild conversational context by reading the dialogue-only filter of this session's transcript (genuine user prompts + your text replies, skipping tool I/O AND harness injections). Use when /charter-recover wasn't enough."
---

Recover the context of THIS conversation by reading only genuine human prompts and your text replies — not tool calls, tool results, thinking, or harness-injected records.

## When to use this vs `/charter-recover`

- **`/charter-recover`** (tier 1) — reads `docs/CONTEXT.md` + `docs/STATUS.md` + the active branch plan. Cheapest. Use first if CONTEXT.md was maintained well.
- **`/charter-replay`** (tier 2, this command) — reads the filtered conversation transcript. Use when CONTEXT.md is sparse, missing nuance, or the user explicitly asks for the conversational through-line. Costs more tokens than `recover` but far less than re-reading the raw .jsonl.
- **Full transcript read** (tier 3) — almost never the right answer. The raw .jsonl contains all the tool I/O and injections that are exactly the noise you're trying to skip.

## Steps

1. **Find this session's transcript file.**
   - Encode the current working directory as a session-dir name: replace every `/` with `-`. (Example: `/Users/me/project` → `-Users-me-project`)
   - Sessions live at `~/.claude/projects/<encoded-cwd>/`
   - The most-recently-modified `.jsonl` in that directory is the current session's transcript.
   - If there's exactly one, use it. If there are multiple, pick the one with the latest mtime.

2. **Run the filter script.** Charter ships a tested filter that handles the edge cases (harness injections, image placeholders, interrupt markers vs genuine `[`-prefixed prompts):

   ```bash
   python3 "${CLAUDE_PLUGIN_ROOT}/scripts/replay-filter.py" <PATH-TO-TRANSCRIPT.jsonl> > /tmp/session-dialog.txt
   ```

   It writes the filtered dialogue (`### USER` / `### ASSISTANT` blocks) to `/tmp/session-dialog.txt` and a one-line count summary to stderr, e.g. `[counts] genuine user prompts: 28 | assistant text replies: 95`.

   The script excludes: tool calls and tool results, assistant thinking, subagent/sidechain records, and harness-injected user-role records (task notifications, slash-command echoes, `[Request interrupted]` markers, compaction summaries, standalone image placeholders). It keeps genuine human text — including prompts that legitimately start with `[` (logs, `[Image #N]` with real text after).

3. **Report the counts** to the user first (e.g. "28 genuine prompts, 95 replies"), then **read `/tmp/session-dialog.txt`** to rebuild context.

4. **Also load** `docs/CONTEXT.md` (if it exists), `docs/STATUS.md`, and the active branch plan, the same way `/charter-recover` would. The replay gives nuance; the docs give state.

5. **Summarize briefly:** what was being worked on, where we left off, anything the user explicitly emphasized, and any open questions.

## Fallback (if the script is unavailable)

If `${CLAUDE_PLUGIN_ROOT}/scripts/replay-filter.py` can't be found, you can run an inline equivalent — but mind the edge cases the script handles: match the FULL `[Request interrupted` prefix (never a bare `[`, since genuine prompts start with `[`), strip `[Image ...]` placeholders but keep any human text after them, and drop records with `isCompactSummary: true` or tool_result blocks.

## Do NOT

- Read the raw `.jsonl` directly. It contains all the tool I/O and injections you're trying to skip.
- Scroll through tool calls, file reads, or command outputs from earlier in the session.
- Re-fetch URLs or re-run commands whose results are already in the transcript.

The goal is to restore conversational context cheaply. The filtered dialog file is the cheapest viable replay; anything beyond that is wasted tokens.
