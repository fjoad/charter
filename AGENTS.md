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

**Branch awareness (v0.2.0+):** On feature branches, `/charter-finish` updates only the branch plan, not STATUS.md component sections. The session-start hook surfaces the matching plan for the current branch (filename slug match or YAML frontmatter `branch:` key). See [docs/ARCHITECTURE.md § Branch Handling](docs/ARCHITECTURE.md#branch-handling) for the full design.

**Testing:** `npm test` (or `bash scripts/verify-plugin.sh`) runs the fast 44-assertion suite — structural checks plus hook behavior in isolated tmpdirs. Before publishing a release, run `bash tests/e2e-install.sh` to spawn real Claude sessions with the local plugin and verify it actually loads (11 assertions across 4 scenarios, ~2 min, small token cost).

**Working memory (v0.3.0+):** `docs/CONTEXT.md` is the AI's working memory across compactions. Maintained inline per `.claude/rules/context-discipline.md` whenever a non-obvious finding surfaces. Auto-loaded by `session-start.sh`. After `/compact`, run `/charter-recover` to restore orientation from CONTEXT.md + STATUS.md + active branch plan, *without* re-reading the transcript. Use `/charter-remember "..."` for explicit captures. See [docs/ARCHITECTURE.md § Working Memory](docs/ARCHITECTURE.md#working-memory-contextmd).

**Tier-2 recovery (v0.4.0+):** If `/charter-recover` isn't enough (CONTEXT.md was sparse, the user emphasized something not captured, etc.), `/charter-replay` reads the session's JSONL filtered to user-text + assistant-text only — no tool I/O. Typically 5–10× smaller than the raw transcript. Never read the raw `.jsonl` directly; that's tier-3 and a documented anti-pattern.

**Preview / dry-run (v0.5.0+):** `/charter-preview attach` (or `init`, `adopt-branches`, `adopt-context`) lists what would be scaffolded — NEW vs EXISTS per file — without writing anything. Use when evaluating Charter on a new project.

**CONTEXT.md is branch-scoped (v0.3.0, articulated v0.5.0):** unlike STATUS.md component sections (which only update on main), CONTEXT.md edits ARE allowed on feature branches. Each branch has its own working memory. On merge, prune branch-specific entries that don't generalize.

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

Charter's own skills (in `skills/`):
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
skills/                 # Charter's own SKILL.md files
commands/               # Markdown slash commands (*.md with YAML frontmatter)
hooks/                  # SessionStart + UserPromptSubmit scripts
agents/                 # Subagent prompt files
template/               # Scaffolded into user projects
docs/                   # Docs ABOUT Charter (dogfood)
scripts/                # verify-plugin.sh — run before any release
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for full layout with file-level detail.
