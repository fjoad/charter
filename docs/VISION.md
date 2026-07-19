# Charter — Vision

**Last updated:** 2026-07-19

---

## Thesis

AI-assisted development projects drift. Each new session starts cold: the assistant doesn't know where you left off, which decisions were made and why, or what rituals the project enforces. Developers re-explain vision, re-derive architecture, and re-approve the same patterns every session.

Charter enforces session-to-session continuity through living docs and lightweight rituals. The model is simple: you're the manager, the AI is your dev team, and Charter is your PMO. It keeps the dev team oriented and disciplined so you don't have to.

---

## What Charter Is

A Claude Code plugin with an agent-neutral project scaffold that:
1. **Scaffolds living docs** into any project (VISION, STATUS, ARCHITECTURE, decisions, plans)
2. **Shares one project contract across Claude and Codex** through canonical `AGENTS.md`; Claude imports
   it and receives automatic hooks, while Codex reads it directly
3. **Classifies every request** by size and applies matching ritual depth — no under-discipline, no over-discipline
4. **Enforces finish rituals** — docs updated, tests run, status recorded before declaring done
5. **Separates active memory from durable causal knowledge** — CONTEXT is compact/prunable; the optional
   evidence record preserves why beliefs changed and how strong the evidence is

Charter layers on top of [superpowers](https://github.com/obra/superpowers). It doesn't replace superpowers skills; it coordinates when to invoke them.

---

## Non-Goals

- **Not a code generator.** Charter disciplines the development process; it doesn't generate code.
- **Not spec-driven.** Charter doesn't require upfront specs. It works with whatever docs exist.
- **Not a language framework.** No Python/TS/Go assumptions baked in. Templates are generic.
- **Not a workflow enforcer for solo scripts.** Charter is for projects that span multiple sessions.
- **Not a replacement for superpowers.** Charter routes to superpowers skills; it doesn't duplicate them.

---

## Success Criteria

- [ ] A greenfield project can be bootstrapped with `/ charter-init` in under 5 minutes
- [ ] An existing project can have Charter attached with `/charter-attach` non-destructively
- [ ] A new session in a Charter-managed project requires zero manual orientation by the user
- [ ] Claude and Codex recover the same canonical project facts without maintaining duplicate instruction files
- [ ] A corrected conclusion can preserve its causal/evidence chain without requiring transcript replay
- [ ] Every request is classified to the correct tier at least 90% of the time
- [ ] `/charter-finish` produces a complete standard report with no missing steps
- [ ] Charter manages its own development (dogfood test passes)
- [ ] Charter can be installed from the Claude Code marketplace with a single command

---

## Key Domain Concepts

**Living docs:** VISION.md, STATUS.md, ARCHITECTURE.md — updated as the project evolves, not written once and forgotten. The AI reads these at session start.

**Ritual tiering:** Trivial / Small / Medium / Major. Every incoming request is auto-classified. Each tier has a corresponding ritual depth. A typo fix doesn't trigger a full TDD cycle; an architecture change does.

**Checkpoint-based autonomy:** Plans embed `## CHECKPOINT: user review` markers. Between checkpoints, the AI runs autonomously. At each checkpoint, it pauses with a standard report. The manager decides whether to continue, redirect, or stop.

**Session orientation:** The `SessionStart` hook reads STATUS.md and injects the current state into Claude's context. Claude always knows where the project stands before responding to the first message.

**Shared agent bootstrap:** `AGENTS.md` is canonical. `CLAUDE.md` imports it; Codex discovers it directly.
Agent-specific rules automate behavior but may not contain unique project truth.

**Causal evidence memory:** `EVIDENCE-AND-LEARNINGS.md` is an opt-in durable layer for invalidated beliefs,
discriminating evidence, root causes, confidence, and open uncertainty. It is read on demand rather than
injected every session.

**Standard report:** The canonical finish output format. Tests pass/fail, docs updated, commits pushed, next step. No variation.

---

## Future Scope (v2+)

- `npx charter` CLI for Cursor / Copilot / non-Claude-Code environments
- Language-specific overlays (`charter-python`, `charter-typescript`, `charter-go`)
- Research overlay (`charter-research`) — EXPERIMENTS.md, RQ tables, experiment tracking
- STATUS.md drift enforcement hook (if real-use data shows drift)
- Monorepo support (nested AGENTS.md per workspace)
