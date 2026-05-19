# Charter — Architecture

**Last updated:** 2026-05-12

---

## Overview

Charter is a Claude Code plugin. It has two parallel components:

- **Plugin components** (`skills/`, `commands/`, `hooks/`, `agents/`) — installed into Claude Code, runs in any project
- **`template/`** — scaffolded into user projects when they run `/charter-init` or `/charter-attach`

Charter layers on top of [superpowers](https://github.com/obra/superpowers). It doesn't replace superpowers skills — it coordinates when to invoke them.

---

## Plugin Layout

```
.claude-plugin/
  plugin.json           # Plugin manifest. Declares hooks, name, version, author.
  marketplace.json      # Marketplace listing for discovery.

skills/
  brief-intake/
    SKILL.md            # Greenfield vision bootstrap skill
  codebase-inference/
    SKILL.md            # Brownfield vision bootstrap skill
  turn-ritual/
    SKILL.md            # Per-tier ritual orchestrator skill
commands/
  charter-init.md       # /charter-init — greenfield scaffold
  charter-attach.md     # /charter-attach — brownfield scaffold
  charter-next.md       # /charter-next — read STATUS, start next step
  charter-finish.md     # /charter-finish — run step-complete ritual
  charter-cost.md       # /charter-cost — report token overhead
  charter-off.md        # /charter-off — disable rituals this session
hooks/
  session-start.sh      # SessionStart hook — orients Claude at session start
  turn-nudge.sh         # UserPromptSubmit hook — 20-token tier reminder
agents/
  vision-drafter.md     # Subagent for drafting VISION.md
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

## Branch Handling

Charter supports feature-branch workflows via two mechanisms:

### Branch-aware session-start hook

`hooks/session-start.sh` reads the current git branch. If on a non-main branch, it searches `docs/plans/` for a matching plan file. Matching rules, in order:

1. Plan has YAML frontmatter with `branch: <name>` exactly matching the current branch.
2. Plan filename slug contains the branch slug, where the branch slug is derived from the part of the branch name **after the last `/`** (so `feat/branch-handling` matches a plan with `branch-handling` in its name; prefixes like `feat/`, `fix/`, `chore/` are stripped).

If a plan matches, it's surfaced in the orient block. If no plan matches, a soft hint suggests `/charter-adopt branches`.

On main (or master, or detached HEAD), the legacy behavior is preserved: the most-recently-modified plan is surfaced.

### Branch-aware finish ritual

`/charter-finish` checks the current branch:
- **Main:** the original finish flow — update STATUS.md, ARCHITECTURE.md, AGENTS.md, commit, report.
- **Feature branch:** update only the branch plan and any "In-flight Branches" entry. Do NOT touch STATUS.md component sections. Route to `superpowers:finishing-a-development-branch` for merge/PR decisions.

### Opt-in via `/charter-adopt branches`

For existing projects, `/charter-adopt branches` idempotently adds an "In-flight Branches" section to STATUS.md and a branch-discipline rule to workflow.md, asking before each change.

### Capability detection

All branch-aware behavior is purely additive. Missing structures (no plan file, no "In-flight Branches" section, no branch-discipline rule) default to today's behavior. Existing Charter projects continue to work without modification after a plugin update.

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
  → /charter-init command fires
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
  "version": "0.1.1",
  "hooks": {
    "SessionStart": [{"hooks": [{"type": "command", "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh\"", "timeout": 5}]}],
    "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/turn-nudge.sh\"", "timeout": 5}]}]
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

### Markdown command

```markdown
---
description: "Bootstrap a new project with Charter's living-docs scaffold."
argument-hint: "[optional project vision hints]"
---

Invoke the brief-intake skill to gather vision, then scaffold the Charter template into this project.
```

---

## How to Extend

**Add a new ritual tier:** Edit `skills/turn-ritual/SKILL.md` tier table + `template/.claude/rules/turn-ritual.md`.

**Add a new template file:** Add to `template/`, update `commands/charter-init.md` and `commands/charter-attach.md` to copy it.

**Add a new slash command:** Create `commands/<name>.md` with YAML frontmatter (`description`, optional `argument-hint`) and prompt body. Use `$ARGUMENTS` to capture user input. Claude Code auto-discovers `.md` files in `commands/`.

**Add a new skill:** Create `skills/<name>/SKILL.md` with proper frontmatter.

**Add a new opt-in convention:** Extend `commands/charter-adopt.md` with a new convention block. Each convention should: detect whether it's already adopted, propose changes to user files one at a time, ask before each, report what changed.

---

## Testing

Two tiers of tests live in `tests/`:

### Structural + unit (`scripts/verify-plugin.sh`)

Runs on every commit (via CI) and locally with `npm test`. Fast (~1s). Covers:

- Plugin file structure (commands are `.md` with frontmatter, no `{{args}}`, version sync)
- `hooks/session-start.sh` and `hooks/turn-nudge.sh` behavior in isolated tmpdirs (32 assertions)
- JSON validity of `plugin.json`, `package.json`, `hooks.json`
- Hook command paths reference real files
- Required content in `commands/*.md`

### End-to-end install (`tests/e2e-install.sh`)

Spawns 4 real `claude -p --plugin-dir <local-charter>` sessions, each in a fresh tmpdir, and asserts on the SessionStart hook's `additionalContext` output. This is the only test that verifies the plugin actually loads into Claude Code. Slow (~30s per scenario) and costs a small amount in API tokens, so it is **not** run by `verify-plugin.sh` automatically — run it manually before publishing a release:

```bash
bash tests/e2e-install.sh
```

11 assertions cover: no-scaffold hint, main-branch orient, feature-branch matching plan, feature-branch no-plan soft hint.
