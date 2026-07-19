# Adopting Charter

---

## Prerequisites

Charter requires [superpowers](https://github.com/obra/superpowers) to be installed. Install it first:

```
/plugin install superpowers
```

---

## Install Charter

```
/plugin install charter
```

Or, during development, install from local path:

```
/plugin install ./path/to/charter
```

---

## Start a New Project (Greenfield)

In your new project directory, with Claude Code open:

```
/charter-init
```

Charter will:
1. Ask 3-5 vision questions
2. Draft `VISION.md` for your review
3. Scaffold `docs/`, `.claude/rules/`, `AGENTS.md`, `CLAUDE.md` after you approve

---

## Attach to an Existing Project (Brownfield)

In your existing project directory:

```
/charter-attach
```

Charter will:
1. Read your README, entry points, and existing docs
2. Draft an inferred `VISION.md` for your correction
3. Scaffold Charter's structure non-destructively alongside existing files (never overwrites)

---

## Daily Use

**Start a session:** Charter's `SessionStart` hook orients Claude automatically. Codex reads the same
canonical `AGENTS.md` and follows its shared STATUS/CONTEXT/evidence reading order.

**Start the next step:**
```
/charter-next
```

**Finish a step:**
```
/charter-finish
```

**Check token overhead:**
```
/charter-cost
```

**Disable rituals for this session:**
```
/charter-off
```

---

## What Gets Scaffolded

After `/charter-init` or `/charter-attach`, your project will have:

```
docs/
  VISION.md           # Your project's thesis, goals, non-goals
  STATUS.md           # Current state, what's next (update this after each step)
  ARCHITECTURE.md     # Technical blueprint (fill in as you build)
  CONTEXT.md          # Compact working memory across compactions
  decisions/
    TEMPLATE.md       # ADR template for design decisions
  plans/
    TEMPLATE.md       # Implementation plan template
.claude/
  rules/
    project-flow.md   # Session-start ritual + doc map
    workflow.md       # Per-step cycle + finish checklist
    turn-ritual.md    # Request tier classifier
    testing.md        # Test discipline
    context-discipline.md # Keeps CONTEXT compact and promotes durable knowledge
  settings.json       # Minimal safe permission allowlist
AGENTS.md             # Canonical shared guide for Claude, Codex, and other assistants
CLAUDE.md             # Explicitly imports @AGENTS.md
```

### Optional durable evidence layer

For research, benchmark, debugging, or incident-heavy projects where conclusions are often corrected:

```text
/charter-adopt evidence
```

This proposes `docs/EVIDENCE-AND-LEARNINGS.md`, shared evidence guidance in `AGENTS.md`, and promotion
rules for durable causal corrections. It is opt-in and idempotent. Preview it first with
`/charter-preview adopt-evidence`.

---

## Keeping It Running

Charter is a discipline system, not a magic wand. Two things you need to do:

1. **Keep `docs/STATUS.md` current.** After each step, update the component table and "What to Work On Next". If this goes stale, Charter's session-start orient becomes misleading.

2. **Run `/charter-finish` at real step boundaries.** Don't skip the finish ritual when you're close to done. That's exactly when it matters most.

---

## Codex CLI

Charter's `AGENTS.md` is auto-discovered by Codex CLI. It contains the shared reading order and evidence
discipline, so Codex recovers STATUS, CONTEXT, relevant evidence, architecture, and active plans without a
second Codex-specific instruction file. `CLAUDE.md` imports that same file for Claude. The hook system
(session-start orient, turn-nudge) remains Claude Code-only; cross-agent compatibility is shared project
truth and recovery semantics, not identical runtime hooks.

---

## Uninstalling

```
/plugin uninstall charter
```

Your project's `docs/`, `.claude/rules/`, and `AGENTS.md` remain. They're yours — Charter just scaffolded them.
