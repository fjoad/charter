# Charter — Working Memory

<!-- AI working memory across compactions. Maintained inline per .claude/rules/context-discipline.md. Run /charter-recover after /compact. Keep entries terse. -->

**Last updated:** 2026-05-12 (v0.4.0)

---

## Environment Quirks

- **macOS lacks `timeout` by default.** When testing CLI commands that need a timeout (e.g., `claude -p ...`), either install `gtimeout` via coreutils or just run without timeout. (cost: ~2 min to discover during e2e test build)
- **Each installed plugin fires its own SessionStart hook.** When parsing `--output-format=stream-json --include-hook-events` output, multiple `hook_response` events appear. Identify Charter's hook by content match (`"Charter: Project Orientation"` or `"no Charter scaffold"`), not by hook_id (which is random per run).
- **`git init` without commit leaves `HEAD` unborn.** `git rev-parse --abbrev-ref HEAD` returns `"HEAD"` instead of `"main"`. Test helpers that create tmpdirs must do an initial commit before checking branch name, otherwise branch-aware code paths misfire.

## Working Patterns

- **CONTEXT.md is branch-scoped working memory by design.** Each feature branch has its own. On merge to main, prune branch-specific entries that don't generalize. Articulated explicitly in v0.5.0 (ARCHITECTURE.md § Working Memory + Branch Discipline rules).
- **`/charter-preview <mode>` for dry-run.** Before `/charter-init` or `/charter-attach` writes anything, `/charter-preview attach` lists every candidate file from `template/` and marks each NEW or EXISTS. Use when evaluating Charter on a new project.
- **Three-tier post-/compact recovery:** `/charter-recover` (CONTEXT.md only, cheapest) → `/charter-replay` (filtered transcript, medium) → never read the raw .jsonl (anti-pattern). Each tier loaded into both context-discipline rule files (project + template) so the discipline travels.
- **JSONL transcript filter (the heart of /charter-replay):** pipe the session JSONL through Python that keeps `type=user`/`type=assistant` entries and extracts only `{type:"text"}` content blocks, dropping tool_use / tool_result / system reminders. Writes to /tmp/session-dialog.txt. Typically 5-10x smaller than the raw transcript.
- **Session JSONL location convention:** `~/.claude/projects/<encoded-cwd>/<session-uuid>.jsonl` where encoded-cwd replaces `/` with `-`. Most-recently-modified `.jsonl` in that dir is the current session.
- **E2E plugin install test:** `claude -p "say READY" --plugin-dir <local-charter-path> --output-format=stream-json --include-hook-events --verbose --no-session-persistence --setting-sources user`. Parses stream-json for `hook_response` events; extracts `additionalContext` from each. Run with no timeout on macOS.
- **Branch-plan slug matching (in `hooks/session-start.sh`):** Use tail after last `/` for branch slug. Require slug ≥ 3 chars to avoid false-positive matches. YAML frontmatter `branch: <name>` always takes precedence regardless of slug length.
- **Backward-compat pattern:** capability detection, not version coupling. Plugin checks for optional structures (CONTEXT.md, In-flight Branches section, branch-named plan file); missing → today's behavior. New behavior activates only when structures present. Used for v0.2.0 branches and v0.3.0 context — same playbook.
- **Charter's own dev convention:** every non-trivial feature goes on a feature branch named `feat/<short-name>`, with a plan at `docs/plans/YYYY-MM-DD-<short-name>.md`. The plan's filename slug must contain the branch tail so the hook auto-matches.

## Don't Repeat

- **Bash heredoc `<<'PY'` overrides pipes to the same command.** `printf '%s' "$raw" | python3 <<'PY' ... PY` → the heredoc wins; python's stdin is the script, not the piped data. Use `python3 -c "$(cat <<'PY' ... PY)"` instead, or save script to a file.
- **Python `return` at top level → SyntaxError.** Heredoc-style python scripts need a `def`-wrap or use `sys.exit()` / `break` for early termination.
- **Don't put `\textcolor{violet}{...}` around a multi-page block in LaTeX** (analog from another project, noted as a general rule). For colored regions spanning floats/sections, use `\begingroup\color{violet}` ... `\endgroup`.
- **Don't leave merged feature branches dangling locally.** After `git merge --no-ff feat/x` to main + push, run `git branch -d feat/x` immediately. v0.2.0–v0.4.0 finish rituals missed this; ended up with 5 stale local-only branch refs that confused a sibling Charter session. Fixed in workflow.md + charter-finish.md as of v0.4.1.
- **Nested triple-backtick code blocks break markdown rendering.** When sharing a prompt that contains a code fence, use ONE outer fence with the inner code as indented plain text (no second fence). Otherwise the inner fence prematurely closes the outer one and the second half spills as raw text.
- **Don't attach Charter on a feature branch as the first install.** Charter's canonical docs are designed to live on main; attaching on a branch inverts the topology and makes `main` look unconfigured until merge. Correct sequence: attach on main → switch to feature branch → branch inherits scaffold via merge-base. Surfaced by a sibling Charter session evaluating Charter on ProactiveAgents.

## Open Questions

_None active._

## User Emphases

- **Backward compatibility is the most important property.** Existing Charter projects must work identically after a plugin update. Branch handling, context-doc — every feature is purely additive via capability detection.
- **Seamless updates.** Users shouldn't need to relearn Charter or run a migration. New behavior either auto-activates when structures appear, or is opt-in via `/charter-adopt <convention>`.
- **Dogfood Charter's own conventions on Charter.** Use feature branches with matching plans; use CONTEXT.md for working memory; run the same finish ritual.

---

## When to Update This File

Inline, mid-session, per `.claude/rules/context-discipline.md`. When CONTEXT.md crosses ~200 lines, audit and prune — promote design-y items to `docs/decisions/`, delete stale entries. CONTEXT.md is alive, not a log.
