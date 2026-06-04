# /charter-preview + CONTEXT-per-branch Articulation

**Date:** 2026-06-04
**Status:** Accepted

## Context

Two adjacent issues surfaced in a sibling Charter session evaluating whether to attach Charter to a feature branch:

1. **No dry-run path.** A user wanting to evaluate Charter before committing has only one option: run `/charter-init` or `/charter-attach` and have it actually write files. There's no way to see what would be scaffolded first. Forces a "commit and revert if I don't like it" workflow.

2. **CONTEXT.md's per-branch behavior was implicit.** v0.3.0 shipped CONTEXT.md as a tracked file in `docs/`, so it naturally travels with branches like any other file. But the Branch Discipline rule (v0.2.0) was written before CONTEXT.md existed; it says "don't edit STATUS.md sections on feature branches" without clarifying that CONTEXT.md is different. Reading the rules cold, you'd reasonably assume CONTEXT.md is also off-limits on feature branches — which would defeat its purpose.

## Decision

Ship both as v0.5.0.

**1. Add `/charter-preview`.** New command, no file writes. Walks `template/`, reports each candidate file as NEW (would be created) or EXISTS (would be skipped — Charter is non-destructive). Supports modes: `init`, `attach`, `adopt-branches`, `adopt-context`. The output is a single report so users can read the full scaffold proposal in one screen before deciding to attach.

**2. Articulate CONTEXT-per-branch explicitly** in three places:
   - `docs/ARCHITECTURE.md` § Working Memory — new "CONTEXT.md is already per-branch" subsection
   - `.claude/rules/workflow.md` and `template/.claude/rules/workflow.md` Branch Discipline section — bullet stating CONTEXT.md edits ARE allowed on feature branches
   - `commands/charter-finish.md` Feature Branch Flow — clarify CONTEXT.md updates are permitted (and expected)

No code changes for item 2 — CONTEXT.md was always per-branch (it's a tracked file). This decision just makes the design intent unambiguous so future readers don't misread the Branch Discipline rule.

## Alternatives Considered

**For /charter-preview:**

1. **A `--dry-run` flag on `/charter-attach`.** Rejected — Claude Code slash commands take string args, not POSIX flags. The convention here would be `/charter-attach --dry-run` which feels off vs `/charter-preview`. Also: a separate command makes the dry-run intent obvious in the command list.

2. **Output the diff that would be created** (not just file list). Rejected for v0.5 — file list is enough to evaluate. Diff-style output adds noise and parsing complexity. Could add later if real users want it.

3. **An interactive "y/n per file" preview.** Rejected — Claude Code commands are one-shot; the preview is intended to be readable in a single response, not a multi-turn dialog.

**For CONTEXT-per-branch:**

1. **Auto-merge / promote CONTEXT entries on merge.** Rejected — too much machinery. The right pattern is human/AI review of CONTEXT.md during merge, with the discipline rule guiding what to keep vs drop.

2. **Make CONTEXT.md a single root-level file like STATUS.md (canonical only).** Rejected — that's the v0.3 design rolled back. Per-branch working memory is the whole point; CONTEXT.md needs to be branch-scoped to be useful while working.

3. **Add a separate `docs/CONTEXT-branch.md` for branch-scoped working memory.** Rejected — splits the concept across two files. CONTEXT.md already IS this, just hadn't been named.

## Consequences

- One more command to maintain (`/charter-preview`), but it's pure-instruction with no plugin behavior to break.
- The Branch Discipline rule is now unambiguous about which docs/ files are off-limits on feature branches (STATUS sections) vs which are encouraged (CONTEXT.md, branch plan).
- Existing Charter projects updating to v0.5.0 see the new preview command immediately. No opt-in needed. No existing behavior changes.
- Future commands (`/charter-recover`, `/charter-replay`) can lean on "CONTEXT.md is branch-scoped" as a documented property when reading working memory after `/compact`.
