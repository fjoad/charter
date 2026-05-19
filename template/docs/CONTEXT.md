# [Project Name] — Working Memory

<!-- GUIDANCE: This is the AI's working memory across compactions — things discovered during sessions that would otherwise be lost when `/compact` runs. The AI maintains this inline during sessions per `.claude/rules/context-discipline.md`. After `/compact`, run `/charter-recover` to restore orientation from this file + STATUS.md + the active branch plan. Keep entries terse (1-2 lines each). Prune stale items rather than letting the file grow forever. -->

**Last updated:** [DATE]

---

## Environment Quirks

<!-- GUIDANCE: Non-obvious facts about the runtime, OS, tools, or services. Cost-tagged if known (e.g., "30 min to figure out"). -->

_None recorded yet._

---

## Working Patterns

<!-- GUIDANCE: Code snippets and commands that work, with a one-line "why" so they aren't re-derived. Reusable templates, common invocations, idiomatic shapes. -->

_None recorded yet._

---

## Don't Repeat

<!-- GUIDANCE: Things tried that don't work. Symptom + cause + the right alternative, so a future session doesn't retry. -->

_None recorded yet._

---

## Open Questions

<!-- GUIDANCE: Mid-stream threads not yet captured in a plan or decision file. Pending choices, unresolved findings, things awaiting external input. -->

_None recorded yet._

---

## User Emphases

<!-- GUIDANCE: Things the user has explicitly said to remember, weighted heavily, or repeated. Direct quotes are fine. -->

_None recorded yet._

---

## When to Update This File

The AI should update CONTEXT.md inline (mid-session, not as a finish step) when:

- A non-obvious environment fact surfaces
- A code pattern works after debugging
- A path is tried and fails
- The user emphasizes something multiple times
- A mid-stream decision is made that doesn't yet warrant an ADR

When CONTEXT.md grows past ~200 lines, audit and prune. Promote design-y items to `docs/decisions/`, empirical items to a findings record, and delete items that are now obvious or stale.
