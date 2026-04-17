# Charter — Design Spec

**Status:** Approved 2026-04-17  
**Author:** fjoad  
**Spec type:** Product + plugin architecture

---

## Problem

Long AI-assisted projects drift across sessions. A new session doesn't know where the previous one left off. Rituals (test-first, verify-before-done, doc updates) get skipped when context pressure mounts. Decisions get made but rationale is lost. User re-explains vision, re-derives architecture, re-approves patterns every session.

---

## Thesis

Session-to-session continuity through living docs + minimal rituals fired at three scopes:
- **Session start** (~200 tokens): orient Claude at current state
- **Per-turn** (~20 tokens): classify request tier, apply matching ritual depth
- **Step complete** (~500 tokens): verify, update docs, commit, report

User metaphor: "You're the manager. The AI is your dev team. Charter is your PMO."

---

## Scope (v1)

**In:** Claude Code + Codex CLI support  
**Out:** Cursor, Copilot, `npx charter` CLI (v2+)

---

## Locked Decisions

| # | Decision | Value |
|---|---|---|
| 1 | Name | `charter` |
| 2 | License | MIT |
| 3 | Superpowers relationship | Soft dependency — README + plugin description note required install; no fork |
| 4 | Canonical doc file | `AGENTS.md`. `CLAUDE.md` = one-line pointer |
| 5 | Autonomy model | Checkpoint-based. Plans embed `## CHECKPOINT:` markers |
| 6 | Ritual tiering | Auto-classified: trivial/small/medium/major. `/charter-off` escape hatch |
| 7 | Vision intake | Interactive (`brief-intake` skill). `--vision-file` override deferred to v2 |
| 8 | Ritual enforcement | Rule-first (`turn-ritual.md`) + lightweight `UserPromptSubmit` hook (~20 tokens). `SessionStart` hook injects orient-block (~200 tokens, once per session) |
| 9 | STATUS.md honesty | Trust + audit. No enforcement in v1 |
| 10 | Distribution | Public GitHub + marketplace submission |
| 11 | Dogfood | Charter repo = this project. Charter's own docs use Charter's own templates |
| 12 | Repo folder name | `test` during build, renamed `charter` at last step |
| 13 | Initial GitHub visibility | Public from first commit |

---

## Plugin Architecture

```
.claude-plugin/
  plugin.json           # manifest + hooks
  marketplace.json      # marketplace listing
plugin/
  skills/
    brief-intake/       # greenfield vision bootstrap
    codebase-inference/ # brownfield vision bootstrap
    turn-ritual/        # per-tier ritual orchestrator
  commands/             # TOML slash commands (6)
  hooks/
    session-start.sh    # orient: read STATUS + ARCH + active plan
    turn-nudge.sh       # 20-token per-turn tier reminder
  agents/
    vision-drafter.md   # subagent for VISION.md drafting
template/               # scaffolded into user projects
  docs/                 # VISION/STATUS/ARCHITECTURE skeletons
  .claude/rules/        # project-flow, workflow, turn-ritual, testing
  AGENTS.md             # canonical operational guide
  CLAUDE.md             # one-line pointer
docs/                   # Charter's own dogfood docs
```

---

## Three-Tier Ritual (new — not in arc scaffold)

| Tier | Trigger | Ritual |
|------|---------|--------|
| Trivial | typo fix, rename, single-line edit | Direct execution. No plan. |
| Small | < 1hr work, well-understood | Plan in-context, implement, verify |
| Medium | multi-file, touches interfaces | writing-plans → TDD → verify → finish |
| Major | architecture change, new component | writing-plans → CHECKPOINT → subagent-driven-dev → verify → finish |

---

## Bootstrap Modes

**Greenfield (`/charter-init`):**
1. `brief-intake` skill asks 3-5 vision questions
2. `vision-drafter` subagent drafts `VISION.md`
3. User approves
4. Template scaffold copies into project

**Brownfield (`/charter-attach`):**
1. `codebase-inference` skill reads README + entry points + existing docs
2. `vision-drafter` subagent drafts inferred `VISION.md`
3. User corrects
4. Template scaffold merges non-destructively

---

## Slash Commands

| Command | Action |
|---------|--------|
| `/charter-init` | Greenfield bootstrap |
| `/charter-attach` | Brownfield bootstrap |
| `/charter-next` | Read STATUS, start next step at correct tier |
| `/charter-finish` | Run step-complete ritual |
| `/charter-cost` | Report token overhead for this session |
| `/charter-off` | Disable rituals for rest of session |

---

## Token Budget

- Session-start hook: ~200 tokens (once per session)
- Per-turn nudge: ~20 tokens (every turn)
- 100-turn session: ~2,200 tokens = ~1.5% overhead on 150k context
- Step-complete ritual: ~500 tokens (triggered by user)

---

## Spec Self-Review

**Placeholders:** None. All `{{...}}` resolved.

**Scope consistency:** All v1 items are buildable as a single Claude Code plugin. Nothing requires external infrastructure.

**Ambiguities resolved:**
- Hook output format: JSON with `additionalContext` (confirmed from caveman reference)
- Command format: TOML (confirmed from caveman reference)
- Skill format: SKILL.md with frontmatter `description` = "Use when..." trigger (confirmed from superpowers)
- AGENTS.md: canonical multi-tool doc (confirmed — 60k+ repos use it)

**Risks:**
- Marketplace submission process unknown — plan says submit to `platform.claude.com/plugins/submit`, may require manual approval
- Hook environment variables `${CLAUDE_PLUGIN_ROOT}` / `${CLAUDE_CONFIG_DIR}` — confirmed from caveman, assume stable API
- superpowers version coupling — no pinned version, README prose note only (acceptable for v1)

**Verdict:** Spec is complete and implementable. No blockers.
