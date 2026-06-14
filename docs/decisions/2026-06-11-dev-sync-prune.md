# dev-sync prunes orphan cache dirs — and why that isn't "cache surgery"

**Date:** 2026-06-11
**Status:** Accepted (extends 2026-06-11-dev-sync.md)

## Context

`claude plugin update` adds a new version dir under the plugin cache but never removes the previous one. This session manually `rm`'d orphaned 0.3.0 then 0.6.0 dirs. dev-sync.sh (v0.8.1) automated the update but inherited the orphan-accumulation gap.

This bumps against a principle stated earlier this arc: **"never hand-edit `~/.claude/plugins/*.json` or the cache dir to force an update"** (AGENTS.md). A teammate could reasonably ask: didn't you just say don't touch the cache?

## Decision

dev-sync.sh prunes orphaned version dirs after the CLI update. The distinction that keeps this consistent with the no-surgery rule:

- **Forbidden (surgery):** editing `installed_plugins.json` / cache contents to *force a version change* the CLI didn't make. Fragile because it fakes state the loader trusts.
- **This (cleanup):** *after* the supported `claude plugin update` has set the active version, delete sibling version dirs that `installed_plugins.json` no longer references. The active dir (read from `installPath`) is always kept; we only remove dead, unreferenced files.

Safety in `prune_cache`: no-op if the keep-name is empty (never wipe everything) or the cache root is missing. If the active path can't be read, pruning is skipped entirely — leave orphans rather than risk the live dir.

Implementation detail with its own small lesson: `set -euo pipefail` moved from dev-sync.sh's top level into the direct-execution guard. The prune logic is a sourced function so it's unit-testable without invoking the real CLI; a top-level `set -e` leaked into the test runner and made an *intentional* non-zero exit elsewhere fatal. The full suite caught it.

## Alternatives Considered

1. **Leave orphans; document manual cleanup.** Rejected — orphans accumulate one per release; "run dev-sync" should leave a clean machine.
2. **`claude plugin prune` (the CLI's own prune).** Rejected — it only removes auto-installed *dependency plugins*, not stale version dirs of an actively-installed plugin (verified earlier this session: it reported "nothing to prune" while two orphan dirs sat there).
3. **A separate `scripts/prune-cache.sh`.** Rejected — more surface for one function; it belongs with the update it complements.

## Consequences

- After any dev-sync the machine carries exactly one Charter version dir.
- prune_cache is conservative by construction (keep-name required, active path verified); the worst failure mode is leaving orphans, never deleting the live install.
- The empty `plugins/data/charter-*` state stubs are intentionally left alone — they're plugin data dirs, not version copies.
