# Charter — Architecture

**Last updated:** 2026-04-17

---

## Overview

Charter is a Claude Code plugin. It has two parallel trees:

- **`plugin/`** — the plugin itself (installed into Claude Code, runs in any project)
- **`template/`** — scaffolded into user projects when they run `/charter-init` or `/charter-attach`

Charter layers on top of [superpowers](https://github.com/obra/superpowers). It doesn't replace superpowers skills — it coordinates when to invoke them.

---

## Plugin Layout

```
.claude-plugin/
  plugin.json           # Plugin manifest. Declares hooks, name, version, author.
  marketplace.json      # Marketplace listing for discovery.

plugin/
  skills/
    brief-intake/
      SKILL.md          # Greenfield vision bootstrap skill
    codebase-inference/
      SKILL.md          # Brownfield vision bootstrap skill
    turn-ritual/
      SKILL.md          # Per-tier ritual orchestrator skill
  commands/
    charter-init.toml   # /charter-init — greenfield scaffold
    charter-attach.toml # /charter-attach — brownfield scaffold
    charter-next.toml   # /charter-next — read STATUS, start next step
    charter-finish.toml # /charter-finish — run step-complete ritual
    charter-cost.toml   # /charter-cost — report token overhead
    charter-off.toml    # /charter-off — disable rituals this session
  hooks/
    session-start.sh    # SessionStart hook — orients Claude at session start
    turn-nudge.sh       # UserPromptSubmit hook — 20-token tier reminder
  agents/
    vision-drafter.md   # Subagent for drafting VISION.md
```

---

## Hook Flow

### SessionStart

Fires once per session. Detects whether the current project has Charter scaffold (checks for `docs/STATUS.md`). If yes:

1. Reads `docs/STATUS.md` — extracts current step + what's next
2. Reads active plan from `docs/plans/` (most recently modified)
3. Outputs JSON `{ "additionalContext": "..." }` with ~200-token orient block
4. Claude receives this before the user's first message

If no `docs/STATUS.md` found, outputs nothing (plugin is installed but project not scaffolded yet).

### UserPromptSubmit

Fires on every user message. Outputs JSON with ~20-token nudge:
```
Classify this request as trivial/small/medium/major and apply matching ritual from .claude/rules/turn-ritual.md.
```

This fires silently. User doesn't see it. Claude applies it before responding.

---

## Skill Invocation Patterns

Skills are SKILL.md files. Claude Code loads them via the `Skill` tool.

**brief-intake**: Invoked by `/charter-init`. Asks clarifying questions about thesis, goals, non-goals, success criteria. Delegates VISION.md drafting to `vision-drafter` subagent.

**codebase-inference**: Invoked by `/charter-attach`. Reads README + entry points + existing docs. Delegates VISION.md drafting to `vision-drafter` subagent.

**turn-ritual**: Invoked automatically by `turn-nudge.sh` prompt injection. Classifies request tier. Routes:
- Trivial → direct execution
- Small → in-context plan + execute + verify
- Medium → `superpowers:writing-plans` → `test-driven-development` → `verification-before-completion` → finish
- Major → `superpowers:writing-plans` → CHECKPOINT → `subagent-driven-development` → verify → finish

---

## Template Layout

```
template/
  docs/
    VISION.md           # Skeleton with <!-- GUIDANCE: --> comments
    STATUS.md           # Seeded: "Step 0: vision approved; next: architecture"
    ARCHITECTURE.md     # Skeleton with section headers
    decisions/
      TEMPLATE.md       # ADR skeleton
    plans/
      TEMPLATE.md       # Implementation plan skeleton (incl. CHECKPOINT markers)
  .claude/
    rules/
      project-flow.md   # Session-start ritual + decision tree (generic)
      workflow.md       # Per-step cycle + finish checklist (generic)
      turn-ritual.md    # Per-turn tier classifier (new — not in legacy arc)
      testing.md        # Testing discipline (generic, no Python specifics)
    settings.json       # Minimal safe permission allowlist
  AGENTS.md             # Canonical operational guide (model-agnostic)
  CLAUDE.md             # One-line pointer to AGENTS.md
  .gitignore            # Standard patterns
```

When `/charter-init` or `/charter-attach` runs, this tree is copied into the user's project. Existing files are never overwritten (brownfield safe).

---

## Dependency Relationship to superpowers

Charter is a consumer of superpowers, not a fork:

- Charter's `turn-ritual.md` rule routes to superpowers skills by name
- Charter's commands reference `superpowers:writing-plans`, `superpowers:test-driven-development`, etc.
- superpowers must be installed separately (`/plugin install superpowers`)
- Charter's README and plugin description note this requirement

No import relationship. No version pinning in v1. If superpowers skill names change, Charter's routing rules need updating.

---

## Data Flow: Greenfield Bootstrap

```
User: /charter-init "A CLI tool for..."
  → charter-init.toml command fires
  → Skill: brief-intake
    → Claude asks 3-5 vision questions
    → Agent: vision-drafter.md
      → Drafts VISION.md content
    → Claude presents draft to user
    → User approves/edits
  → Template scaffold copies to project
  → STATUS.md seeded: "Step 0: vision approved; next: architecture"
  → AGENTS.md + CLAUDE.md written
```

## Data Flow: Session Orient

```
User opens Claude Code in Charter-managed project
  → SessionStart hook fires (session-start.sh)
  → Script reads docs/STATUS.md
  → Script reads latest plan from docs/plans/
  → Outputs { "additionalContext": "<orient block>" }
  → Claude receives orient block before first user message
  → Claude knows: current step, what's next, active plan
```

---

## Key Interfaces

### plugin.json

```json
{
  "name": "charter",
  "version": "0.1.0",
  "hooks": {
    "SessionStart": [{"hooks": [{"type": "command", "command": "bash \"${CLAUDE_PLUGIN_ROOT}/plugin/hooks/session-start.sh\"", "timeout": 5}]}],
    "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "bash \"${CLAUDE_PLUGIN_ROOT}/plugin/hooks/turn-nudge.sh\"", "timeout": 5}]}]
  }
}
```

### SKILL.md frontmatter

```markdown
---
name: brief-intake
description: Use when starting a new project with Charter after /charter-init. Asks vision questions and drafts VISION.md.
---
```

### TOML command

```toml
description = "Bootstrap a new project with Charter's living-docs scaffold."
prompt = "Invoke the brief-intake skill to gather vision, then scaffold the Charter template into this project."
```

---

## How to Extend

**Add a new ritual tier:** Edit `plugin/skills/turn-ritual/SKILL.md` tier table + `template/.claude/rules/turn-ritual.md`.

**Add a new template file:** Add to `template/`, update `plugin/commands/charter-init.toml` and `charter-attach.toml` to copy it.

**Add a new slash command:** Create `plugin/commands/<name>.toml` with `description` and `prompt`. No registration needed — Claude Code auto-discovers `.toml` files in `commands/`.

**Add a new skill:** Create `plugin/skills/<name>/SKILL.md` with proper frontmatter.
