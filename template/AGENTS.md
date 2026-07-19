# [Project Name] — Shared Agent Operational Guide

> Canonical bootstrap for **Claude, Codex, and other AI assistants** working on this project. Codex reads
> this file directly; `CLAUDE.md` imports it for Claude. `.claude/rules/` may automate Claude-specific
> rituals, but no project fact should exist only there.

<!-- GUIDANCE: This file is the single source of truth for how an AI assistant should work in this project. Fill it in after Charter bootstraps your docs. Keep it up to date — a stale AGENTS.md is worse than none. -->

---

## What This Project Is

<!-- GUIDANCE: 2-3 sentences. What are we building? Link to VISION.md for more. -->

See [docs/VISION.md](docs/VISION.md) for the full thesis.

---

## Reading Order (Every Session)

1. **[docs/STATUS.md](docs/STATUS.md)** — current state, what's done, what's next
2. **[docs/CONTEXT.md](docs/CONTEXT.md) if present** — compact working memory and don't-repeats
3. **`docs/EVIDENCE-AND-LEARNINGS.md` if present** — read when STATUS/CONTEXT cites it, when revisiting
   a corrected/contested claim, or when interpreting a discriminating experiment or debugging result
4. **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** — how the system is structured
5. **[docs/VISION.md](docs/VISION.md)** — if you need to understand the thesis behind a decision
6. **Active plan in [docs/plans/](docs/plans/)** — if a step is in progress

If there's no active plan for the current step, create one before writing code.

---

## Session Start Ritual

1. Read STATUS.md — find current step and "What to Work On Next"
2. Read CONTEXT.md if present — recover active caveats and don't-repeats
3. Read EVIDENCE-AND-LEARNINGS.md only when STATUS/CONTEXT cites it, a claim was corrected/contested, or
   a discriminating experiment/debugging result needs interpretation
4. Read ARCHITECTURE.md — understand how the current step fits
5. Check `docs/plans/` — is there an existing plan for the current step?
6. If plan exists → execute it. If not → create one first.

## Evidence Discipline

- Use **VERIFIED**, **OBSERVED**, **INFERRED**, **HYPOTHESIS**, **INVALIDATED**, and **OPEN** consistently.
- Rank evidence by directness, discriminating power, and provenance—not source type or recency alone.
  For technical claims, prefer direct reproduction/artifacts and dated audits over derived summaries. For
  requirements and intent, a direct user statement is primary evidence even when recovered from a transcript.
- When evidence overturns a conclusion, preserve the causal chain: former belief, disconfirming evidence,
  root cause, current conclusion, confidence, and remaining uncertainty. Do not silently rewrite history.
- `STATUS.md` says what is true now. `CONTEXT.md` is compact/prunable active memory. When adopted,
  `EVIDENCE-AND-LEARNINGS.md` keeps durable causal corrections. Decisions record deliberate choices.
- Update the evidence record when a mistake would otherwise be plausibly relearned by a future session.

---

## Charter Rituals

Every request is classified by tier. Apply the matching ritual per `.claude/rules/turn-ritual.md`:

| Tier | Signal | Ritual |
|------|--------|--------|
| Trivial | typo, rename, single-line | Direct execution |
| Small | <1hr, well-understood | Plan in-context → execute → verify |
| Medium | multi-file, interfaces | `writing-plans` → TDD → verify → finish |
| Major | architecture, new component | `writing-plans` → CHECKPOINT → subagent-dev → verify → finish |

Finish checklist (mandatory for medium/major) — see `.claude/rules/workflow.md`.

---

## Skills Available

<!-- GUIDANCE: Update this list with skills relevant to your project. Remove irrelevant ones. -->

Requires [superpowers](https://github.com/obra/superpowers):

| Skill | Use when |
|-------|----------|
| `superpowers:writing-plans` | Starting medium/major work |
| `superpowers:test-driven-development` | Any logic that can be tested |
| `superpowers:verification-before-completion` | Before claiming any step done |
| `superpowers:systematic-debugging` | When something fails |
| `superpowers:subagent-driven-development` | Parallel independent subtasks |

---

## Key Docs

| Question | Read |
|----------|------|
| What are we building and why? | [docs/VISION.md](docs/VISION.md) |
| Where are we now? What's next? | [docs/STATUS.md](docs/STATUS.md) |
| What must this session remember? | [docs/CONTEXT.md](docs/CONTEXT.md) |
| Why did a belief change? How strong is the evidence? | `docs/EVIDENCE-AND-LEARNINGS.md` (if adopted) |
| How does the system work? | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| Past decisions with rationale | [docs/decisions/](docs/decisions/) |
| Implementation plans | [docs/plans/](docs/plans/) |

---

## Decision Records

Create a decision file when making a significant design choice:
- Path: `docs/decisions/YYYY-MM-DD-short-title.md`
- "Significant" = changes architecture, adds dependencies, changes interfaces, would surprise a teammate

---

## Project-Specific Notes

<!-- GUIDANCE: Add anything that would surprise a new contributor. Stack-specific commands, unusual constraints, known gotchas, test commands. -->

<!-- Example:
**Run tests:** `npm test` / `pytest tests/` / `go test ./...`
**Dev server:** `npm run dev`
**Gotcha:** [something surprising]
-->
