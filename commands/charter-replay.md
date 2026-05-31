---
description: "Tier-2 recovery: rebuild conversational context by reading the dialogue-only filter of this session's transcript (user turns + your text replies, skipping all tool I/O). Use when /charter-recover wasn't enough."
---

Recover the context of THIS conversation by reading only the user's messages and your text replies — not the tool calls and tool results.

## When to use this vs `/charter-recover`

- **`/charter-recover`** (tier 1) — reads `docs/CONTEXT.md` + `docs/STATUS.md` + the active branch plan. Cheapest. Use first if CONTEXT.md was maintained well.
- **`/charter-replay`** (tier 2, this command) — reads the filtered conversation transcript. Use when CONTEXT.md is sparse, missing nuance, or the user explicitly asks for the conversational through-line. Costs more tokens than `recover` but far less than re-reading the raw .jsonl.
- **Full transcript read** (tier 3) — almost never the right answer. The raw .jsonl contains all the tool I/O that's exactly the noise you're trying to skip.

## Steps

1. **Find this session's transcript file.**
   - Encode the current working directory as a session-dir name: replace every `/` with `-`. (Example: `/Users/me/project` → `-Users-me-project`)
   - Sessions live at `~/.claude/projects/<encoded-cwd>/`
   - The most-recently-modified `.jsonl` in that directory is the current session's transcript.
   - If there's exactly one, use it. If there are multiple, pick the one with the latest mtime.

2. **Extract dialogue only.** Run this Bash + Python pipeline against the transcript path, writing the filtered output to `/tmp/session-dialog.txt`:

   ```bash
   python3 -c '
   import sys, json
   for line in sys.stdin:
       try:
           e = json.loads(line)
       except Exception:
           continue
       role = e.get("type")
       if role not in ("user", "assistant"):
           continue
       msg = e.get("message") or {}
       c = msg.get("content")
       if isinstance(c, str):
           texts = [c]
       elif isinstance(c, list):
           texts = [b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text"]
       else:
           continue
       joined = "\n".join(s.strip() for s in texts if s and s.strip())
       if not joined:
           continue
       label = "USER" if role == "user" else "ASSISTANT"
       print(f"### {label}")
       print(joined)
       print()
   ' < <PATH-TO-TRANSCRIPT.jsonl> > /tmp/session-dialog.txt
   ```

3. **Read `/tmp/session-dialog.txt`.** This file contains only the conversational turns — no tool I/O, system reminders, or hook events. It's typically 5–10× smaller than the raw transcript.

4. **Also load** `docs/CONTEXT.md` (if it exists), `docs/STATUS.md`, and the active branch plan, the same way `/charter-recover` would. The replay gives nuance; the docs give state.

5. **Summarize briefly:** what was being worked on, where we left off, anything the user explicitly emphasized, and any open questions.

## Do NOT

- Read the raw `.jsonl` directly. It contains all the tool I/O you're trying to skip.
- Scroll through tool calls, file reads, or command outputs from earlier in the session.
- Re-fetch URLs or re-run commands whose results are already in the transcript.

The goal is to restore conversational context cheaply. The filtered dialog file is the cheapest viable replay; anything beyond that is wasted tokens.
