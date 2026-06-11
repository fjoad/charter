---
description: "Restore orientation after /compact — the single recovery entry point. Reads CONTEXT.md + STATUS.md + active branch plan; auto-escalates to the transcript replay when working memory is thin. Never reads the raw transcript."
---

The user has just run `/compact` (or wants explicit re-orientation). Your job: restore working context **without re-reading the raw conversation transcript**, choosing the cheapest tier that works — automatically, without asking the user to pick.

## Step 1: Assess working memory, pick the tier yourself

Check `docs/CONTEXT.md`:

- **Healthy** (exists, has real entries — more than ~25 lines of actual content, not just `_None recorded yet._` placeholders) → **Tier 1**: proceed with the docs-only read order below.
- **Thin or missing** (no file, mostly placeholders, or clearly sparse relative to a long session) → **auto-escalate to Tier 2**: run the replay filter directly, no need to ask:

  ```bash
  python3 "${CLAUDE_PLUGIN_ROOT}/scripts/replay-filter.py"
  ```

  It auto-finds this session's transcript and prints the genuine dialogue (tool I/O and harness injections stripped; counts to stderr). For very long sessions redirect to `/tmp/session-dialog.txt` and read in chunks. (`/charter-replay` is the direct route to this same script if the user ever wants it explicitly.)

Tier 3 — reading the raw `.jsonl` — is an anti-pattern. Never do it; it's hundreds of thousands of tokens of tool noise.

## Step 2: Recovery read order (both tiers)

1. **`docs/CONTEXT.md`** — working memory: environment quirks, working patterns, don't-repeats, open questions, user emphases (skip if just read in Step 1).
2. **`docs/STATUS.md`** — current project state, component table, what to work on next.
3. **Active branch plan** — run `git rev-parse --abbrev-ref HEAD`. If on a feature branch, find the matching plan in `docs/plans/` (filename slug containing the branch tail) and read it. If on main, skip.

## Do NOT read (unless explicitly cited above)

- The raw session transcript / JSONL
- `docs/ARCHITECTURE.md` (only if STATUS or CONTEXT cites structural concern)
- `docs/VISION.md` (only if the user asks "what are we building")
- Other plans in `docs/plans/` (only the one for the current branch)
- Decision records (only if cited)

## Report

After reading, output 3-5 lines max:

```
Recovered (tier [1|2 — escalated: CONTEXT.md was thin/missing]):
- Project: [one-line project state from STATUS]
- Current step: [from STATUS "What to Work On Next" or branch plan]
- Working memory: [count] entries across [list active sections] (or: thin — consider /charter-remember discipline)
- Open questions / blockers: [from CONTEXT.md Open Questions, or "none"]
- Next: [continue last task / await user input]
```

Then ask the user what to do next, or continue from the last in-flight task if it's obvious from the branch plan.
