# replay-filter.py is self-contained (auto-finds its transcript)

**Date:** 2026-06-09
**Status:** Accepted (extends 2026-06-09-replay-filter-as-script.md)

## Context

`/charter-replay` was a three-step procedure split between the command's instructions and the script: the AI (1) found the session `.jsonl`, (2) ran `replay-filter.py <path>`, (3) read the output file. The file-finding lived in prose the AI had to execute. That left room to fumble (wrong dir, wrong file, encoding mistakes) and meant the script wasn't usable on its own.

The intended mental model is simpler: the agent runs **one** programmatic thing and gets the conversation back. "Run this."

## Decision

Move transcript-finding into `scripts/replay-filter.py`. With no positional argument, the script:
1. Encodes `os.getcwd()` (every non-alphanumeric char → `-`) to the Claude Code session-dir name.
2. Looks under `~/.claude/projects/<encoded>/` (overridable via `--projects-root` or `CHARTER_PROJECTS_ROOT`, which makes auto-find testable).
3. Picks the newest `*.jsonl` by mtime — the current session.
4. Prints the filtered dialogue to **stdout** (so it lands in the agent's tool result = in context) and which-transcript + counts to stderr.

The positional path argument still works and takes precedence (needed for fixtures, explicit use, and the "auto-find picked the wrong file" escape hatch). Output defaults to stdout; redirect to a file for very long sessions.

`/charter-replay.md` collapses to: run `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/replay-filter.py`, read its output, load the docs, summarize.

## Alternatives Considered

1. **Keep file-finding in the command prose.** Rejected — that's the fumble-prone step the user wanted gone, and it kept the script non-standalone.

2. **Default to writing a temp file instead of stdout.** Rejected as the default — stdout makes "run this and it's in your context" literal. The temp-file path is kept as the documented option for very long sessions (so a huge dump doesn't overwhelm one tool result).

3. **Detect the current session by PID / session-id rather than newest-mtime.** Rejected — Claude Code doesn't expose the active session id to a child process reliably; newest-mtime in the encoded-cwd dir is the same heuristic the command already used and is correct in practice (the live transcript is the one being written).

## Consequences

- `/charter-replay` is now a one-shot for the agent. The script also works standalone: `python3 replay-filter.py` from any project dir prints that project's latest session dialogue.
- The encoding convention (`[^A-Za-z0-9]` → `-`) is now codified in `encode_cwd()` and unit-tested, rather than described approximately in prose (the old prose said "replace `/` with `-`", which was incomplete — spaces, parens, dots also become `-`).
- Auto-find is testable via `--projects-root` pointing at a fixture tree; tests cover newest-selection, env-var override, and the no-transcript error path.
- If Claude Code changes its projects-dir layout or encoding, `encode_cwd()` / `find_current_transcript()` are the two functions to update.
