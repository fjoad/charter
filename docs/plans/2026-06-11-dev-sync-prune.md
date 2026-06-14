# v0.9.1 — dev-sync prunes orphan cache dirs

**Status:** ✅ Complete (2026-06-11) — 112/112 tests pass, ready to merge.
**Branch:** `fix/dev-sync-prune`

## Why

`claude plugin update` adds a new version dir under `~/.claude/plugins/cache/<marketplace>/<plugin>/` but never removes the old one. Across this session's arc we manually rm'd orphaned 0.3.0 and then 0.6.0 dirs. dev-sync.sh (v0.8.1) automated the *update* but inherited this gap — it should prune orphans too, so the dev's machine has no stale-version footprint after a sync.

## Design

Restructure `scripts/dev-sync.sh` so the prune logic is a pure, testable function:

- `prune_cache <cache_root> <keep_name>` — removes every immediate subdir of `cache_root` except `keep_name`. Safety: no-op if `keep_name` is empty (never wipe everything) or `cache_root` missing.
- `main()` — runs the CLI update, then derives the active version dir from `installed_plugins.json` (the basename of `installPath`) and calls `prune_cache "$(dirname installPath)" "$(basename installPath)"`. If the path can't be read, skip pruning (fail-safe — leave orphans rather than risk the active dir).
- Source guard: `main` runs only when the script is executed directly (`BASH_SOURCE[0] == $0`), so tests can `source` the file to get `prune_cache` without firing the real CLI calls.

This is cleanup of unreferenced files *after* the supported CLI did the update — not the forbidden "hand-edit plugin state to force an update."

## Tests (TDD) — `tests/dev-sync.test.sh`

- prune removes orphan dirs, keeps the active one
- empty keep_name → no-op (doesn't delete anything) — the critical safety case
- missing cache_root → no-op, no error

## Non-goals

- Pruning other plugins' caches (charter only)
- Touching the empty `plugins/data/charter-*` state stubs (harmless, not versions)
