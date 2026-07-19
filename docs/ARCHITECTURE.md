# Charter — Architecture

**Last updated:** 2026-07-19 (v0.10.0: shared-agent bootstrap + durable evidence convention)

---

## Overview

Charter is a Claude Code plugin whose scaffold is agent-neutral. It has two parallel components:

- **Plugin components** (`skills/`, `commands/`, `hooks/`, `agents/`) — installed into Claude Code, runs in any project
- **`template/`** — shared project contract scaffolded for Claude, Codex, and other assistants when users
  run `/charter-init` or `/charter-attach`

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

1. Reads `docs/STATUS.md` — injected in full (deliberately uncapped: "What to Work On Next" lives at the bottom; head-truncation would cut it)
2. Reads `docs/CONTEXT.md` if present — capped at 200 lines (the context-discipline pruning threshold; the truncation marker nudges pruning)
3. Reads the relevant plan from `docs/plans/` — branch-matched on feature branches, most-recent on main. Capped at 40 lines with a read-the-file marker. **Plans whose header says `Status: … Complete` are skipped entirely on main** — history is not orientation.
4. Outputs JSON `{ "additionalContext": "..." }`; Claude receives it before the user's first message

The orient block is budget-gated: a CI test feeds an adversarial fixture (600-line CONTEXT + 1,200-line plan) and fails if output exceeds 24,000 chars (~6k tokens). Measure any project's real number with `scripts/measure-overhead.sh` (which `/charter-cost` uses). See `docs/TOKEN-BUDGET.md` and `docs/decisions/2026-06-11-token-budget.md`.

If no `docs/STATUS.md` found, outputs a one-line hint to run /charter-init or /charter-attach.

### UserPromptSubmit

Fires on every user message. Outputs JSON with ~20-token nudge:
```
Classify this request as trivial/small/medium/major and apply matching ritual from .claude/rules/turn-ritual.md.
```

This fires silently. User doesn't see it. Claude applies it before responding.

## Cross-agent bootstrap (v0.10.0)

Charter has one canonical project instruction file: **`AGENTS.md`**.

- **Claude:** `CLAUDE.md` uses Claude Code's `@AGENTS.md` import, then `.claude/rules/` automates
  session/turn rituals. No unique project fact belongs only in `CLAUDE.md` or `.claude/rules/`.
- **Codex:** discovers `AGENTS.md` directly and follows its shared reading order for STATUS, CONTEXT,
  on-demand evidence, architecture, vision, and active plans.
- **Other assistants:** can be pointed at the same `AGENTS.md` rather than maintaining another copy.

Hooks remain Claude Code-only. Cross-agent compatibility means shared project truth and recovery
semantics, not pretending Codex executes Claude's plugin hooks.

---

## Working Memory (CONTEXT.md)

Charter maintains a fourth doc category beyond STATUS / ARCHITECTURE / decisions: **`docs/CONTEXT.md`**, the AI's working memory across compactions.

### Why

Long Claude Code sessions hit `/compact`, discarding older messages. Without a persistent scratchpad, the AI either re-reads the entire transcript (wasteful — often >400k tokens) or re-derives environment quirks, working patterns, and "don't repeat" lessons. CONTEXT.md captures these inline as they surface, so post-compaction recovery is fast and cheap.

### How

1. **AI-maintained inline** per `.claude/rules/context-discipline.md`. The AI appends to CONTEXT.md whenever a non-obvious finding emerges — environment quirks, working patterns, don't-repeats, user emphases, mid-stream decisions. Entries are terse (1-2 lines).
2. **Auto-loaded by `session-start.sh`** when `docs/CONTEXT.md` exists. Surfaces in the orient block before branch context and STATUS. Missing file → identical to today's behavior (capability detection).
3. **`/charter-remember <text>`** — explicit capture command.
4. **`/charter-recover`** — post-`/compact` re-orientation. Reads CONTEXT.md + STATUS.md + active branch plan; explicitly forbids re-reading the transcript or unrelated docs.
5. **`/charter-adopt context`** — idempotent install of CONTEXT.md + the discipline rule into existing projects.

### Three-tier recovery model (v0.4.0)

When the user runs `/compact`, the AI picks the cheapest viable recovery tier:

| Tier | Command | Reads | Cost |
|---|---|---|---|
| 1 | `/charter-recover` | CONTEXT.md + STATUS.md + active branch plan | cheapest |
| 2 | `/charter-replay` | filtered session transcript (user + assistant text, no tool I/O) | medium |
| 3 | (no command) | raw .jsonl | anti-pattern — 400k+ tokens of tool noise |

Tier 1 assumes the context-discipline rule was followed during the session. Tier 2 is the safety net when CONTEXT.md is sparse, stale, or missing nuance. Tier 3 is what burned hundreds of thousands of tokens in real cases; documented as something to avoid, not a Charter command.

`/charter-replay` runs the committed filter `scripts/replay-filter.py` (v0.7.0+) as a **one-shot — no path argument**: the script auto-locates the current session's transcript (encodes `cwd` via `[^A-Za-z0-9]`→`-`, finds the newest `*.jsonl` under `~/.claude/projects/<encoded-cwd>/`), filters it, and prints the dialogue to stdout (which-transcript + counts to stderr). It keeps genuine human prompts + assistant text and excludes tool I/O, thinking, sidechain records, and harness-injected user-role records (task notifications, slash-command echoes, `[Request interrupted]` markers, compaction summaries, standalone image placeholders). The positional path arg still works (precedence) for fixtures/explicit use. The filter is unit-tested (`tests/replay-filter.test.sh` against `tests/fixtures/replay-sample.jsonl`, including auto-find via `--projects-root`). Its injection inventory was empirically derived from a parallel sweep of ~7,800 transcripts across 11 projects — see `docs/decisions/2026-06-09-replay-filter-as-script.md` (committed script) and `2026-06-09-replay-self-contained.md` (self-contained auto-find).

### Alive, not a log

The discipline rule says: when CONTEXT.md crosses ~200 lines, audit and prune. Promote design items to `decisions/`; promote empirical items to findings (or write one); delete entries that are now obvious or stale. CONTEXT.md is currently-active working memory — not a forever-growing journal.

### CONTEXT.md is already per-branch (v0.3.0+, articulated v0.5.0)

CONTEXT.md is a tracked file in `docs/`, so it travels with the branch like any other file. This means **each feature branch has its own working memory**, distinct from main's:

- A learning discovered while working on `feat/X` goes into `feat/X`'s CONTEXT.md. It does not pollute main's CONTEXT.md until merge.
- On merge to main, CONTEXT.md merges like any other file. Usually you keep entries that are generally useful and drop branch-specific ones during the merge or right after via prune.
- **CONTEXT.md edits ARE allowed on feature branches** — unlike STATUS.md component sections. CONTEXT is branch-scoped working memory; STATUS is canonical project state. Different roles, different rules.

This was implicit in the v0.3.0 design (CONTEXT.md is just a file, files live on branches) but never said out loud. Documented here so the branch discipline rule and finish ritual are unambiguous.

## Durable causal evidence (v0.10.0, opt-in)

`/charter-adopt evidence` adds `docs/EVIDENCE-AND-LEARNINGS.md` for knowledge that must survive CONTEXT
pruning. It records former beliefs, discriminating evidence, root causes, corrected conclusions,
confidence labels, remaining uncertainty, and source artifacts.

The layers have deliberately different lifecycles:

| Layer | Question | Lifecycle |
|---|---|---|
| `STATUS.md` | What is true and next now? | Continuously rewritten |
| `CONTEXT.md` | What must the current branch/session remember? | Compact, pruned at ~200 lines |
| `EVIDENCE-AND-LEARNINGS.md` | Why did a belief change and how strong is the evidence? | Durable; supersession preserved |
| `decisions/` | What did we deliberately choose and why? | Durable ADRs |

The evidence document is **not auto-injected** by `session-start.sh`; a growing historical record should
not become a permanent token tax. `AGENTS.md` and `/charter-recover` route assistants to relevant sections
on demand when a result is disputed, a conclusion was corrected, or STATUS/CONTEXT cites it.

Adoption is additive and idempotent. Existing projects behave identically until they run
`/charter-adopt evidence`; current templates are evidence-aware but tolerate the file being absent.

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
    CONTEXT.md          # Compact working memory across compactions
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
      context-discipline.md # CONTEXT routing + durable-evidence promotion
    settings.json       # Minimal safe permission allowlist
  AGENTS.md             # Canonical shared operational guide (Claude/Codex/other agents)
  CLAUDE.md             # Explicit @AGENTS.md import; no duplicate project truth
  .gitignore            # Standard patterns
```

When `/charter-init` or `/charter-attach` runs, this tree is copied into the user's project. Existing files are never overwritten (brownfield safe).
`EVIDENCE-AND-LEARNINGS.md` is deliberately not in the default tree; `/charter-adopt evidence` proposes
it only for projects that need durable causal memory.

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

For Codex, the equivalent flow is file-based rather than hook-based:

```text
Codex opens the project
  → discovers AGENTS.md
  → follows the shared reading order
  → reads STATUS + CONTEXT, and evidence on demand
  → works from the same canonical project state as Claude
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

**Add a new opt-in convention:** Extend `commands/charter-adopt.md`, `charter-preview.md`, and
`charter-help.md`. Each convention should detect whether it is already adopted, propose changes one at a
time, ask before each, report what changed, and preserve capability-detected backward compatibility.

---

## Testing

Two tiers of tests live in `tests/`:

### Structural + unit (`scripts/verify-plugin.sh`)

Runs on every commit (via CI) and locally with `npm test`. Fast (~1s). Covers:

- Plugin file structure (commands are `.md` with frontmatter, no `{{args}}`, version sync)
- `hooks/session-start.sh` and `hooks/turn-nudge.sh` behavior in isolated tmpdirs (121 assertions)
- JSON validity of `plugin.json`, `package.json`, `hooks.json`
- Hook command paths reference real files
- Required content in `commands/*.md`

### End-to-end install (`tests/e2e-install.sh`)

Spawns 5 real `claude -p --plugin-dir <local-charter>` sessions, each in a fresh tmpdir, and asserts on the SessionStart hook's `additionalContext` output. This is the only test that verifies the plugin actually loads into Claude Code. Slow (~30s per scenario) and costs a small amount in API tokens, so it is **not** run by `verify-plugin.sh` automatically — run it manually before publishing a release:

```bash
bash tests/e2e-install.sh
```

14 assertions cover: no-scaffold hint, main-branch orient, feature-branch matching plan, feature-branch
no-plan soft hint, and CONTEXT.md injection.
