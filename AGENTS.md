# Charter — Operational Guide

> This is the canonical guide for AI assistants working on Charter. CLAUDE.md, Codex CLI, Cursor, and other tools should be pointed here.

---

## What This Project Is

Charter is a Claude Code plugin that enforces session-to-session continuity through living docs and lightweight rituals. See [docs/VISION.md](docs/VISION.md) for the full thesis.

---

## Reading Order (Every Session)

1. **[docs/STATUS.md](docs/STATUS.md)** — current state, what's done, what's next
2. **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** — plugin layout, hook flow, template structure
3. **[docs/VISION.md](docs/VISION.md)** — if you need to understand the thesis behind a decision
4. **Active plan in [docs/plans/](docs/plans/)** — if a step is in progress

If there's no active plan for the current step, create one before writing code.

---

## Session Start Ritual

1. Read STATUS.md — find current step and "What to Work On Next"
2. Read ARCHITECTURE.md — understand how the current step fits
3. Check `docs/plans/` — is there an existing plan for the current step?
4. If plan exists → execute it. If not → create one first.

---

## Deciding What to Do

- STATUS.md says step "In progress" + plan exists → continue executing that plan
- STATUS.md says step "In progress" + no plan → create plan first (`superpowers:writing-plans`)
- STATUS.md says step "Not started" → next step. Create plan.
- STATUS.md says step "Done" → update STATUS.md, move to next step
- Unsure → ask the user

---

## Charter-Enforced Rituals

Every request is classified by tier. Apply the matching ritual:

| Tier | Signal | Ritual |
|------|--------|--------|
| Trivial | typo, rename, single-line | Direct execution |
| Small | <1hr, well-understood | Plan in-context → execute → verify |
| Medium | multi-file, touches interfaces | `writing-plans` → TDD → `verification-before-completion` → finish |
| Major | architecture, new component | `writing-plans` → CHECKPOINT → subagent-driven-dev → verify → finish |

Finish checklist (mandatory for medium/major):
- [ ] Run tests — report pass count
- [ ] Update `docs/STATUS.md`
- [ ] Update `docs/ARCHITECTURE.md` if architecture changed
- [ ] Commit all changes
- [ ] Report to user in standard format

Standard report format:
```
**Step complete: [name]**
- Tests: X/X pass (or: no automated tests for this step)
- Docs updated: [list]
- Commits: [count] on [branch]
- Next step: [what STATUS.md says is next]
```

---

## Skills Available

Charter uses [superpowers](https://github.com/obra/superpowers). Key skills:

| Skill | Use when |
|-------|----------|
| `superpowers:writing-plans` | Starting medium/major work — create implementation plan |
| `superpowers:executing-plans` | Executing a written plan step by step |
| `superpowers:test-driven-development` | Any logic that can be tested — write tests first |
| `superpowers:verification-before-completion` | Before claiming any step done |
| `superpowers:systematic-debugging` | When something fails — diagnose before guessing |
| `superpowers:subagent-driven-development` | Large tasks that benefit from parallel subagents |

Charter's own skills (in `plugin/skills/`):
- `brief-intake` — greenfield vision bootstrap
- `codebase-inference` — brownfield vision bootstrap
- `turn-ritual` — per-tier ritual routing

---

## Key Docs

| Question | Read |
|----------|------|
| What are we building and why? | [docs/VISION.md](docs/VISION.md) |
| Where are we now? What's next? | [docs/STATUS.md](docs/STATUS.md) |
| How does the plugin work? | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| The pitch / philosophy | [docs/MANIFESTO.md](docs/MANIFESTO.md) |
| Past decisions with rationale | [docs/decisions/](docs/decisions/) |
| Implementation plans | [docs/plans/](docs/plans/) |
| Install + usage guide | [docs/ADOPTING.md](docs/ADOPTING.md) |
| Token overhead rationale | [docs/TOKEN-BUDGET.md](docs/TOKEN-BUDGET.md) |
| Comparison to alternatives | [docs/COMPARISON.md](docs/COMPARISON.md) |

---

## Decision Records

Create a decision file when making a significant design choice:
- Path: `docs/decisions/YYYY-MM-DD-short-title.md`
- "Significant" = changes architecture, adds dependencies, changes interfaces, would surprise a teammate

---

## Repository Layout

```
.claude-plugin/         # Plugin manifest + marketplace listing
plugin/
  skills/               # Charter's own SKILL.md files
  commands/             # TOML slash commands
  hooks/                # SessionStart + UserPromptSubmit scripts
  agents/               # Subagent prompt files
template/               # Scaffolded into user projects
docs/                   # Docs ABOUT Charter (dogfood)
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for full layout with file-level detail.
