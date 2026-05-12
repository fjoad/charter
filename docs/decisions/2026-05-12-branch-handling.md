# Branch Handling

**Date:** 2026-05-12
**Status:** Accepted

## Context

Charter's session-start hook and finish ritual were built assuming a single-branch workflow. STATUS.md was treated as the global source of truth, but it's a file in the repo, so it's per-branch by accident. Feature branches diverged STATUS.md, causing merge conflicts and confusing the session-start orientation.

Real development needs feature branches. Charter didn't support them.

## Decision

**Plans become the unit of branch-scoped work.** Each feature branch owns a plan file in `docs/plans/`. The session-start hook is branch-aware: on a non-main branch, it surfaces the matching plan instead of (or in addition to) the latest one. STATUS.md component sections are only edited at merge to main — feature branches leave them alone.

**Backward compatibility via capability detection.** The hook and commands don't require new structures; they detect them. An old project that updates the plugin and changes nothing sees identical behavior. Branch awareness activates only when the user is on a feature branch AND opts in (creates a branch-named plan file, or runs `/charter-adopt branches`).

**Opt-in via `/charter-adopt branches`.** A new command idempotently adds an "In-flight Branches" section to STATUS.md and a branch-discipline rule to workflow.md, asking before each change. Power users who want explicit conventions in their rules can opt in; everyone else benefits from the hook behavior without any user-file changes.

## Alternatives Considered

1. **Branch-local STATUS.md, accept conflicts.** Simplest but produces routine merge conflicts on STATUS.md. Rejected — conflicts erode the "frictionless continuity" thesis.

2. **Required schema migration.** Have `/charter-upgrade` rewrite user STATUS.md to a new shape. Cleaner long-term but breaks backward compatibility — users who don't run the migration are stranded. Rejected — Charter's update must never break a project.

3. **Branch metadata in a sidecar file (`.charter/branches.json`).** Cleaner separation but introduces a hidden state file Claude can't naturally read. Rejected — Charter's principle is "everything in docs/, human-readable."

4. **Active branch lifecycle commands (`/charter-branch-start`, `/charter-branch-finish`).** Considered for v0.3+. For v0.2.0 we ship the smallest coherent slice: branch-aware hook + branch-aware finish + opt-in adoption. Lifecycle commands can be added later without breaking anything.

## Consequences

- Existing projects work unchanged until they opt in.
- Users on feature branches get a soft "no plan for this branch — run /charter-adopt" hint at session start. Discovery without disruption.
- The hook's plan-matching logic uses filename slug matching (stripping the `feat/`-style prefix to match on the tail) with YAML frontmatter `branch:` as an explicit override. Straightforward and debuggable.
- Forward-compat: the hook composes from multiple optional context sources. Future additions (stacked PRs, named work streams) extend the composer; they don't replace it.
- New automated test infrastructure (`tests/`) was added alongside this feature. Future features can use it.
