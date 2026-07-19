---
description: "Adopt an optional Charter convention into this project. Idempotent — safe to run multiple times. Supported: branches, context, evidence."
argument-hint: "<convention>  (branches | context | evidence)"
---

The user is opting into a Charter convention.

$ARGUMENTS

Parse the argument as the convention name. Currently supported: `branches`, `context`, `evidence`.

If the argument is empty or unrecognized, list the supported conventions and stop:

```
Supported conventions:
  branches — enable branch-aware workflows (plans tied to feature branches, branch-aware finish ritual)
  context  — enable working-memory doc (docs/CONTEXT.md surviving /compact, with /charter-remember and /charter-recover commands)
  evidence — enable durable causal memory (why beliefs changed, evidence strength, invalidated conclusions)
```

---

## Convention: `branches`

Goal: enable Charter to treat each feature branch as a self-contained unit of work, with its own plan file.

Make the following changes, **asking the user before each one** so they can skip any:

### Change 1: Add "In-flight Branches" section to docs/STATUS.md

Check if `docs/STATUS.md` already contains a heading exactly matching `## In-flight Branches`. If yes, skip — already adopted.

If no, propose adding the following section after "Branch State" (or at the end if "Branch State" is absent):

```markdown
---

## In-flight Branches

<!-- GUIDANCE: One line per active feature branch. Format: `- \`branch-name\` → docs/plans/<plan-file>.md — short status` -->

_None active._
```

Show the user the proposed insertion location and exact content. Ask: "Add this section to STATUS.md? (yes/no)" If yes, edit the file; if no, skip.

### Change 2: Add branch-discipline note to .claude/rules/workflow.md

Check if `.claude/rules/workflow.md` already contains the phrase `On feature branches`. If yes, skip.

If no, propose appending the following section at the end of the file:

```markdown
---

## Branch Discipline

On feature branches:
- Edit only your branch's plan file in `docs/plans/`
- Do NOT edit STATUS.md Component Status, What to Work On Next, or Recent Decisions sections
- These sections only update on merge to main (handled by `/charter-finish` on the main branch)
- This avoids merge conflicts and keeps STATUS.md as the canonical "shipped" state

When starting work on a new feature:
1. Create the branch: `git checkout -b feat/<short-name>`
2. Create a plan file: `docs/plans/YYYY-MM-DD-<short-name>.md` (filename should include `<short-name>` so the session-start hook can match it to the branch)
3. Optionally add a line to STATUS.md "In-flight Branches" pointing at the plan
```

Show the user the proposed addition. Ask: "Add this rule to workflow.md? (yes/no)" If yes, append; if no, skip.

### Change 3: Optional plan rename suggestion

If `docs/plans/` contains plan files that don't match any branch name slug, mention them as informational only — do NOT modify or rename them. Existing plans keep working.

---

After all changes are applied (or skipped), report:

```
**Adoption complete: branches**
- STATUS.md: [added section / skipped — already present / skipped — user declined]
- workflow.md: [added rule / skipped — already present / skipped — user declined]
- Next: on feature branches, create a plan in docs/plans/ with the branch name in the filename. The session-start hook will surface it automatically.
```

If the user declined every change, report that adoption was a no-op and explain that the plugin will still work in legacy mode.

---

## Convention: `context`

Goal: enable working memory that survives `/compact`. The AI maintains `docs/CONTEXT.md` during sessions; after `/compact`, `/charter-recover` reads it to restore orientation without re-scanning the transcript.

Make the following changes, **asking the user before each one**:

### Change 1: Scaffold docs/CONTEXT.md

Check if `docs/CONTEXT.md` exists. If yes, skip — already adopted.

If no, propose creating it with the following content (substitute the project name from `docs/STATUS.md`'s top heading; use today's date for [DATE]):

```markdown
# [Project Name] — Working Memory

<!-- GUIDANCE: This is the AI's working memory across compactions — things discovered during sessions that would otherwise be lost when `/compact` runs. The AI maintains this inline during sessions per `.claude/rules/context-discipline.md`. After `/compact`, run `/charter-recover` to restore orientation from this file + STATUS.md + the active branch plan. Keep entries terse (1-2 lines each). Prune stale items rather than letting the file grow forever. -->

**Last updated:** [DATE]

---

## Environment Quirks

_None recorded yet._

---

## Working Patterns

_None recorded yet._

---

## Don't Repeat

_None recorded yet._

---

## Open Questions

_None recorded yet._

---

## User Emphases

_None recorded yet._

---

## When to Update This File

The AI should update CONTEXT.md inline (mid-session, not as a finish step) when a non-obvious environment fact surfaces, a code pattern works after debugging, a path is tried and fails, the user emphasizes something multiple times, or a mid-stream decision is made.

When CONTEXT.md grows past ~200 lines, audit and prune.
```

Show the user the proposed content. Ask: "Create docs/CONTEXT.md with this content? (yes/no)" If yes, create; if no, skip.

### Change 2: Add context-discipline rule

Check if `.claude/rules/context-discipline.md` exists. If yes, skip.

If no, propose creating it with the following content:

```markdown
# Context Discipline

Charter maintains `docs/CONTEXT.md` as working memory across compactions. The AI updates it **inline** during the session — not as a separate finish step.

## When to Write

Append to CONTEXT.md when ANY of these happen:
- Environment quirk: non-obvious fact about runtime, OS, tools, services
- Working pattern: code/command that solved a non-trivial problem (with one-line "why")
- Don't repeat: tried-and-fails, with symptom + the right alternative
- User emphasis: the user explicitly says something is important or repeats it
- Mid-stream decision: a choice not yet warranting a decision record

## When NOT to Write

- Project state → STATUS.md
- Architecture → ARCHITECTURE.md
- Design choices with alternatives → `docs/decisions/`
- Trivial output, single test passes, command exit codes
- Genuinely ephemeral state

## How to Write

Append to matching section. Terse: 1-2 lines max. Update "Last updated".

## When the User Runs /compact

Capture anything important to CONTEXT.md *before* it's lost. `/charter-remember "..."` is the explicit version.

## Pruning

When CONTEXT.md crosses ~200 lines: promote design items to decisions/, empirical items to findings, delete stale entries. CONTEXT.md is alive, not a log.
```

Ask: "Add this rule to `.claude/rules/`? (yes/no)" If yes, create; if no, skip.

---

After both changes are applied (or skipped), report:

```
**Adoption complete: context**
- CONTEXT.md: [created / skipped — already present / skipped — user declined]
- context-discipline.md: [created / skipped — already present / skipped — user declined]
- Next: the AI will now maintain CONTEXT.md inline during sessions. After /compact, run /charter-recover to restore orientation. Use /charter-remember "..." for explicit captures.
```

---

## Convention: `evidence`

Goal: preserve durable causal and epistemic context that should not be pruned from `CONTEXT.md`: what was
believed, what evidence changed it, the root cause, the corrected conclusion, and remaining uncertainty.
This is useful for research, benchmarks, complex debugging, incident-heavy systems, and any project where
a plausible wrong conclusion could be relearned by a future session.

Make the following changes, **asking the user before each one**:

### Change 1: Scaffold docs/EVIDENCE-AND-LEARNINGS.md

Check if `docs/EVIDENCE-AND-LEARNINGS.md` exists. If yes, skip — already adopted.

If no, propose creating it with the following content (substitute the project name from `docs/STATUS.md`;
use today's date for `[DATE]`):

```markdown
# [Project Name] — Evidence and Causal Learnings

**Last updated:** [DATE]

## Purpose

This document preserves why conclusions changed: former belief, disconfirming or supporting evidence,
root cause, current conclusion, confidence, and remaining uncertainty. `STATUS.md` says what is true now;
`CONTEXT.md` is compact active memory; this file prevents durable causal knowledge from being pruned or
reconstructed from raw transcripts.

## Evidence vocabulary

- **VERIFIED:** directly reproduced or confirmed by a discriminating artifact/audit.
- **OBSERVED:** visible in an output or trace, but the cause may remain unresolved.
- **INFERRED:** best explanation supported by evidence but not isolated experimentally.
- **HYPOTHESIS:** plausible explanation awaiting a discriminating test.
- **INVALIDATED:** contradicted by later evidence; retained so it is not repeated.
- **OPEN:** unresolved or awaiting external state.

Rank evidence by directness, discriminating power, and provenance—not source type or recency alone.
For technical claims, prefer direct reproduction/artifacts and dated audits over derived summaries. For
requirements and intent, a direct user statement is primary evidence even when recovered from a transcript.

## Causal record

_None recorded yet._

## How to add a learning

Use this shape:

### Claim or incident

- **Former belief/status:**
- **Disconfirming or supporting evidence:**
- **Root cause (if isolated):**
- **Current conclusion + evidence label:**
- **Remaining uncertainty / blast radius:**
- **Source artifacts:**

Preserve invalidated beliefs rather than deleting them. That is what stops the next session from deriving
the same plausible but wrong explanation.
```

Show the user the proposed content. Ask: "Create docs/EVIDENCE-AND-LEARNINGS.md? (yes/no)" If yes,
create it; if no, skip.

### Change 2: Add shared evidence guidance to AGENTS.md

Check whether `AGENTS.md` already contains both `## Evidence Discipline` and
`EVIDENCE-AND-LEARNINGS.md`. If yes, skip. If only one is present, update the existing material instead of
adding a duplicate section. Otherwise, propose adding a short reading-order entry plus this section:

```markdown
## Evidence Discipline

- Use VERIFIED, OBSERVED, INFERRED, HYPOTHESIS, INVALIDATED, and OPEN consistently.
- Preserve corrections: former belief → disconfirming evidence → root cause → current conclusion →
  confidence and remaining uncertainty. Do not silently rewrite history.
- STATUS.md says what is true now; CONTEXT.md is compact active memory;
  EVIDENCE-AND-LEARNINGS.md keeps durable causal corrections.
- Read EVIDENCE-AND-LEARNINGS.md when interpreting results, debugging disputed failures, or encountering
  corrected claims. It is on-demand evidence, not mandatory full-session context.
```

Ask: "Add the shared evidence guidance to AGENTS.md? (yes/no)" If yes, edit; if no, skip. This shared
location is what makes the convention work for Codex and Claude; do not put the only copy in `.claude/`.

### Change 3: Add promotion rule to context-discipline.md

Check whether `.claude/rules/context-discipline.md` exists and already mentions
`EVIDENCE-AND-LEARNINGS.md`. If already present, skip. If the rule file does not exist, report that the
shared AGENTS guidance still works and suggest `/charter-adopt context`; do not create unrelated context
scaffolding silently.

Otherwise propose adding:

```markdown
- Durable causal corrections (former belief → disconfirming evidence → root cause → new conclusion) →
  `docs/EVIDENCE-AND-LEARNINGS.md`. Leave only a terse pointer in CONTEXT.md if the learning is still active.
```

Ask: "Teach context-discipline.md to promote durable causal corrections? (yes/no)" If yes, edit; if no,
skip.

After all changes are applied (or skipped), report:

```text
**Adoption complete: evidence**
- EVIDENCE-AND-LEARNINGS.md: [created / skipped — already present / skipped — user declined]
- AGENTS.md: [updated / skipped — already evidence-aware / skipped — user declined]
- context-discipline.md: [updated / absent — adopt context first / skipped — already aware / user declined]
- Next: record causal corrections when evidence changes a conclusion; keep current state in STATUS.md and
  compact active memory in CONTEXT.md.
```
