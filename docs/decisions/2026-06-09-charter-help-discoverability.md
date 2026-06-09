# /charter-help and AI-facing discoverability

**Date:** 2026-06-09
**Status:** Accepted

## Context

Three separate Charter sessions independently rebuilt features Charter already shipped:
1. Branch cleanup after merge (→ fixed in v0.4.1's finish ritual)
2. A session-transcript recap/filter script (→ Charter already had `/charter-replay`; hardened in v0.5.1)
3. (the same pattern, earlier) manual plugin-reinstall surgery

The common thread is not missing features — it's **discoverability**. The AI in a sibling session didn't know the feature existed, either because it was running an old cached plugin version or simply was never told what Charter provides. The most-affected audience is the *AI itself* mid-task, not the human.

## Decision

Two-part fix:

1. **`/charter-help`** — a curated, grouped catalog of every command, opt-in convention, and recovery tier. Includes an explicit "For the AI reading this" section that says: before building recovery/transcript/branch/working-memory/scaffolding tooling, check the catalog first.

2. **AI-facing pointer in the session-start orient block.** One line, injected every session: "Before building any session-recovery, transcript, branch-management, working-memory, or scaffolding tooling: check what Charter already provides (run or read /charter-help)." This puts the anti-reinvention nudge in front of the AI at the exact moment it matters — session start, before it starts building.

## Anti-staleness

`/charter-help` is curated rather than auto-generated (grouping by purpose reads far better than a flat frontmatter dump). To keep it from drifting, a plugin-structure test asserts that **every `commands/*.md` (except charter-help itself) is referenced by name in `charter-help.md`.** Adding a command without cataloging it fails CI. The finish ritual (`workflow.md`) also names this as a step.

## Alternatives Considered

1. **Auto-generate help from command frontmatter.** Rejected — loses the purposeful grouping (setup / daily / recovery / conventions) that makes the catalog scannable. The sync test gives the freshness guarantee without sacrificing curation.

2. **Only a `/charter-help` command, no orient-block pointer.** Rejected — you have to know to run `/charter-help`, which is the same discoverability gap one level up. The orient-block line reaches the AI without anyone invoking anything.

3. **Only the orient-block pointer, no command.** Rejected — the pointer needs something to point *at*. The command is the reference.

4. **Heavier token budget: list all commands in every orient block.** Rejected — that's ~300 tokens every session. One pointer line (~25 tokens) plus an on-demand command is the right cost/benefit. See TOKEN-BUDGET.md philosophy.

## Consequences

- The orient block grows by one line (~25 tokens/session). Justified by preventing whole features from being rebuilt.
- New commands must be added to `/charter-help` (test-enforced) — a small, caught-automatically maintenance step.
- This is the highest-leverage fix for the recurring "sibling session reinvents Charter" pattern. If it works, the rebuild incidents stop. If they continue, the next hypothesis is version staleness (old cached plugin), which would point at a `scripts/dev-install.sh` or update-nudge instead.
