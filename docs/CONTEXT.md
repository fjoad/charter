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
- **Recovery is one entry point (v0.9.0):** `/charter-recover` auto-escalates to the replay filter when CONTEXT.md is thin (placeholders or < ~25 real lines); user never picks a tier. `/charter-replay` = direct access. Raw .jsonl remains the never-do anti-pattern. New-command ADRs must now answer "why can't an existing command absorb this?" (workflow.md guardrail).
- **Replay filter lives in `scripts/replay-filter.py` (v0.5.1), not in-prompt.** Edge cases: match FULL `[Request interrupted` (never bare `[` — genuine prompts start with `[`: logs, `[Image #N]`); strip `[Image ...]` placeholders but KEEP human text after; `isCompactSummary` flag for compaction; structural skip for tool_result + isSidechain. Empirically derived from a sweep of ~7,800 transcripts (8,542 genuine vs 288 injections). `isMeta`/`isSidechain` do NOT separate genuine from injected — text-marker matching needed.
- **replay-filter.py is self-contained (v0.7.0): run it with NO args** and it auto-finds the current session transcript (encode cwd via `[^A-Za-z0-9]`→`-`, newest `*.jsonl` under `~/.claude/projects/<encoded>/`), prints dialogue to stdout. `--projects-root` / `CHARTER_PROJECTS_ROOT` override makes auto-find testable. cwd-encoding is every non-alnum→`-`, NOT just `/`→`-` (spaces/parens/dots too).
- **JSONL transcript filter (the heart of /charter-replay):** pipe the session JSONL through Python that keeps `type=user`/`type=assistant` entries and extracts only `{type:"text"}` content blocks, dropping tool_use / tool_result / system reminders. Writes to /tmp/session-dialog.txt. Typically 5-10x smaller than the raw transcript.
- **Session JSONL location convention:** `~/.claude/projects/<encoded-cwd>/<session-uuid>.jsonl` where encoded-cwd replaces `/` with `-`. Most-recently-modified `.jsonl` in that dir is the current session.
- **E2E plugin install test:** `claude -p "say READY" --plugin-dir <local-charter-path> --output-format=stream-json --include-hook-events --verbose --no-session-persistence --setting-sources user`. Parses stream-json for `hook_response` events; extracts `additionalContext` from each. Run with no timeout on macOS.
- **Branch-plan slug matching (in `hooks/session-start.sh`):** Use tail after last `/` for branch slug. Require slug ≥ 3 chars to avoid false-positive matches. YAML frontmatter `branch: <name>` always takes precedence regardless of slug length.
- **Backward-compat pattern:** capability detection, not version coupling. Plugin checks for optional structures (CONTEXT.md, In-flight Branches section, branch-named plan file); missing → today's behavior. New behavior activates only when structures present. Used for v0.2.0 branches and v0.3.0 context — same playbook.
- **Charter's own dev convention:** every non-trivial feature goes on a feature branch named `feat/<short-name>`, with a plan at `docs/plans/YYYY-MM-DD-<short-name>.md`. The plan's filename slug must contain the branch tail so the hook auto-matches.

- **Dev-sync closes the staleness loop (v0.8.1):** release finish ritual now ends with `bash scripts/dev-sync.sh`; opt-in nudge via `~/.config/charter/dev-source` (file containing the source repo path) makes every session warn when installed != source version. v0.9.1 added orphan-cache pruning (each `claude plugin update` leaves the prior version dir behind; prune keeps only the active one).
- **Sourcing a `set -euo pipefail` script leaks `set -e` into the caller.** dev-sync.sh defines testable functions; putting `set -e` at top level broke the test runner (an intentional non-zero exit elsewhere became fatal). Fix: put `set -euo pipefail` inside the `[[ BASH_SOURCE[0] == $0 ]]` direct-execution guard, not at top level. Pattern for any sourced-for-testing shell script.
- **Orient block is budget-bounded (v0.8.0):** completed plans skipped on main; plans cap at 40 lines, CONTEXT.md at 200 (the pruning threshold); STATUS.md deliberately uncapped (What-to-Work-On-Next is at the bottom — head-truncation would cut it). Measure with `scripts/measure-overhead.sh`; CI gates an adversarial fixture at 24k chars.

## Don't Repeat

- **`git stash` clobbers uncommitted tracked edits — including ones you just made with Edit/Write.** Used `git stash -q` mid-task to compare against an old hook version; it silently reverted an uncommitted command rewrite (recovered via `git stash pop`). For point-in-time file comparisons, use `git archive <ref> <path> | tar -x -C $TMP` (no working-tree mutation) — never stash around uncommitted work.
- **Bash heredoc `<<'PY'` overrides pipes to the same command.** `printf '%s' "$raw" | python3 <<'PY' ... PY` → the heredoc wins; python's stdin is the script, not the piped data. Use `python3 -c "$(cat <<'PY' ... PY)"` instead, or save script to a file.
- **Python `return` at top level → SyntaxError.** Heredoc-style python scripts need a `def`-wrap or use `sys.exit()` / `break` for early termination.
- **Don't put `\textcolor{violet}{...}` around a multi-page block in LaTeX** (analog from another project, noted as a general rule). For colored regions spanning floats/sections, use `\begingroup\color{violet}` ... `\endgroup`.
- **Don't leave merged feature branches dangling locally.** After `git merge --no-ff feat/x` to main + push, run `git branch -d feat/x` immediately. v0.2.0–v0.4.0 finish rituals missed this; ended up with 5 stale local-only branch refs that confused a sibling Charter session. Fixed in workflow.md + charter-finish.md as of v0.4.1.
- **Nested triple-backtick code blocks break markdown rendering.** When sharing a prompt that contains a code fence, use ONE outer fence with the inner code as indented plain text (no second fence). Otherwise the inner fence prematurely closes the outer one and the second half spills as raw text.
- **Don't attach Charter on a feature branch as the first install.** Charter's canonical docs are designed to live on main; attaching on a branch inverts the topology and makes `main` look unconfigured until merge. Correct sequence: attach on main → switch to feature branch → branch inherits scaffold via merge-base. Surfaced by a sibling Charter session evaluating Charter on ProactiveAgents.
- **Sibling sessions keep rebuilding Charter features (3rd time: branch-cleanup→v0.4.1, replay-filter→v0.5.1).** Root cause is DISCOVERABILITY — people don't know a command exists, or run an old cached Charter version. FIXED in v0.6.0: `/charter-help` catalog + an AI-facing pointer in the session-start orient block ("check /charter-help before building recovery/branch/context tooling"). If rebuilds continue, next hypothesis is version staleness (old cached plugin) → consider scripts/dev-install.sh.
- **`/charter-help` is curated, kept in sync by a test.** A plugin-structure assertion fails if any `commands/*.md` isn't referenced in charter-help.md. Add new commands to the catalog or CI breaks.
- **To refresh/iterate the plugin, never hand-edit `~/.claude/plugins/*.json`.** A sibling session did JSON surgery to force an update and hit a malformed-timestamp bug (`date %3N` is GNU-only, not on macOS). Supported paths: `claude --plugin-dir "$(pwd)"` for testing local changes (no install), or `/plugin uninstall charter && /plugin install charter@fjoad-charter` to refresh from GitHub (push first). Documented in AGENTS.md § Iterating on Charter.

## Open Questions

_None active._

## User Emphases

- **Backward compatibility is the most important property.** Existing Charter projects must work identically after a plugin update. Branch handling, context-doc — every feature is purely additive via capability detection.
- **Seamless updates.** Users shouldn't need to relearn Charter or run a migration. New behavior either auto-activates when structures appear, or is opt-in via `/charter-adopt <convention>`.
- **Dogfood Charter's own conventions on Charter.** Use feature branches with matching plans; use CONTEXT.md for working memory; run the same finish ritual.

---

## When to Update This File

Inline, mid-session, per `.claude/rules/context-discipline.md`. When CONTEXT.md crosses ~200 lines, audit and prune — promote design-y items to `docs/decisions/`, delete stale entries. CONTEXT.md is alive, not a log.
