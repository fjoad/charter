# Working Memory Doc (CONTEXT.md)

**Date:** 2026-05-12
**Status:** Accepted

## Context

Long Claude Code sessions hit `/compact`, which discards older messages. The AI then has to either re-read the session transcript (often hundreds of thousands of tokens — wasteful and slow) or rediscover environment quirks, working code patterns, and "don't repeat" lessons it had already learned.

Charter's existing doc categories don't cover this:
- `STATUS.md` is coarse, project-state, slow-moving.
- `ARCHITECTURE.md` is structural.
- `decisions/` are forward-looking design choices with weighed alternatives.
- `plans/` are forward-looking implementation steps.

What's missing: a **fast-moving, AI-maintained working memory** of mid-stream learnings — the granular "I just figured out that X needs Y" stuff that currently lives only in the conversation buffer.

A real research-project example surfaced this gap clearly: a user had to manually invent and maintain a `CONTEXT_RECOVERY.md` doc after hitting `/compact` and watching the AI re-discover things it had already learned. The pattern is general.

## Decision

**Introduce `docs/CONTEXT.md` as a fourth doc category — the AI's working memory across compactions.**

Mechanics:
1. **AI-maintained inline.** A new rule `.claude/rules/context-discipline.md` directs the AI to append to CONTEXT.md whenever a non-obvious finding surfaces (environment quirks, working patterns, don't-repeats, user emphases, mid-stream decisions). Entries are terse, 1-2 lines max.
2. **Auto-loaded at session start.** `hooks/session-start.sh` surfaces CONTEXT.md in the orient block before STATUS.md and branch context — when present. Missing CONTEXT.md → identical to today (capability detection, backward compat).
3. **`/charter-remember <text>`** — explicit capture command for emphasis the AI might otherwise miss.
4. **`/charter-recover`** — post-`/compact` orientation restore. Reads CONTEXT.md + STATUS.md + active branch plan, *explicitly forbidding* re-reading the transcript or unrelated docs. This is the lever that solves the original problem.
5. **`/charter-adopt context`** — idempotent install of CONTEXT.md and the discipline rule into existing projects. Same opt-in pattern as v0.2.0's `branches` convention.

CONTEXT.md is **alive, not a log.** The rule explicitly says: when the file crosses ~200 lines, audit and prune. Promote design items to `decisions/`; delete stale entries.

## Alternatives Considered

1. **Detect `/compact` via a hook.** Claude Code doesn't (currently) expose a `PreCompact` or `PostCompact` hook event Charter can use. Rejected as not feasible. `/charter-recover` is the explicit fallback.

2. **Auto-prompt the AI every N turns via UserPromptSubmit.** Reminder noise. The discipline rule + the prospect of `/compact` is enough motivation; an extra-frequent nudge degrades signal-to-noise. Rejected.

3. **Separate categories: `findings.md` / `pitfalls.md` / `environment.md`.** More files to scaffold, load, and load-coordinate. A single CONTEXT.md with sections is simpler and matches what the original CONTEXT_RECOVERY.md prototype did organically. Rejected for v0.3.0; could split later if any single section dominates.

4. **A sidecar `.charter/memory.json` machine-parseable file.** Hidden state file the AI can't naturally read. Against Charter's principle of "everything in docs/, human-readable." Rejected.

5. **No separate command — auto-recover via the existing session-start hook.** `/compact` happens mid-session; SessionStart only fires at session start. The hook alone can't catch a mid-session compaction event. `/charter-recover` is needed for the explicit re-orient case.

## Consequences

- **Existing projects work unchanged.** Plugin update with no CONTEXT.md → identical behavior. Opt-in via `/charter-adopt context`.
- **AI behavior shifts subtly:** with the discipline rule loaded, the AI will pause to append to CONTEXT.md on discoveries. Token cost per turn is small; the savings on post-compaction re-derivation are large.
- **Two new commands** (`/charter-remember`, `/charter-recover`) need maintaining alongside the existing six.
- **`/charter-adopt`'s pattern is now validated for multiple conventions.** Future opt-in features (findings, pitfalls, patterns directories) extend this same command rather than adding new top-level ones.
- **The "third doc" mental model** (STATUS for state, ARCHITECTURE for structure, decisions for choices) becomes a fourth (CONTEXT for working memory) — small cognitive load increase but each doc has a clear, distinct purpose.
