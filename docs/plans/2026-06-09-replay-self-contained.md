# v0.7.0 — self-contained replay-filter (one-shot "run this")

**Status:** ✅ Complete (2026-06-09) — 81/81 tests pass, one-shot auto-find verified live, ready to merge.
**Branch:** `feat/replay-self-contained`

## Why

Today `/charter-replay` is a 3-step dance the AI performs: (1) find the session JSONL, (2) run `replay-filter.py <path>`, (3) read the output file. The user wants it to be a single programmatic "run this" — the agent runs ONE script that finds its own session transcript, extracts dialogue, and prints it. The file-finding moves from AI-instructions into the script, so the agent can't fumble it and the script is genuinely standalone.

## Design

`scripts/replay-filter.py`:
- **No positional arg → auto-find** the current session's transcript: encode `os.getcwd()` (every non-alphanumeric char → `-`), look in `~/.claude/projects/<encoded>/`, pick the newest `*.jsonl` by mtime.
- **Positional path arg still works** (precedence) — needed for tests/fixtures and explicit use.
- **`--projects-root <dir>`** override (also env `CHARTER_PROJECTS_ROOT`) so auto-find is testable against a fixture tree.
- **Default output: stdout** (so "run this" puts the dialogue straight into the agent's tool result = into context). Counts + which-transcript-used → stderr.
- Clear error to stderr + non-zero exit if no projects dir / no transcript found.

Encoding verified against real dirs, e.g. `/Users/fjoad/Documents/projects/charter` → `-Users-fjoad-Documents-projects-charter`, and `…/Personal Information (1)/tax 2026` → `…-Personal-Information--1--tax-2026` (every non-alnum → `-`).

`commands/charter-replay.md`: collapse to "run `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/replay-filter.py` — its output is the filtered conversation; read it. (For very long sessions, redirect to /tmp/session-dialog.txt and read in chunks.)"

## Tasks (TDD)

1. Branch + plan ✓
2. Tests first: auto-find against a fixture projects-root (compute this cwd's encoding, drop fixture, assert counts); no-transcript → error exit; explicit path still works; `--projects-root` honored.
3. Implement auto-find in replay-filter.py.
4. Update charter-replay.md to the one-shot form (keep the inline fallback note).
5. Docs: ARCHITECTURE, CONTEXT dogfood, ADR (supersedes the "AI finds the file" split), STATUS, AGENTS.
6. Bump 0.6.0 → 0.7.0, verify, e2e, merge, push, tag, delete branch.

## Non-goals

- Removing the path arg (kept for tests + explicit use)
- Changing the filter logic itself (v0.5.1 inventory unchanged)
