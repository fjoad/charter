---
description: "List everything Charter offers — all commands, opt-in conventions, and recovery tiers. Run this before building session-recovery, branch, or context tooling: Charter probably already has it."
---

The user wants to see what Charter provides. Present the catalog below, cleanly formatted. If the user named a specific command or topic in their message, expand on that one; otherwise show the full catalog.

**Also do a freshness check:** list `${CLAUDE_PLUGIN_ROOT}/commands/*.md`. If any command file exists that is NOT in the catalog below, mention it — the plugin may be newer than this help text.

---

## Charter — command catalog

**Charter is a Claude Code plugin that keeps multi-session projects oriented and disciplined.** You're the manager, the AI is the dev team, Charter is the PMO. It runs mostly automatically; these commands are for when you want to trigger something explicitly.

### Setup (once per project)

| Command | What it does |
|---------|--------------|
| `/charter-init` | Bootstrap a NEW project — runs a vision intake, scaffolds the living-docs structure. |
| `/charter-attach` | Attach Charter to an EXISTING codebase — infers vision from the repo, scaffolds non-destructively. |
| `/charter-preview` | Dry-run of `init` / `attach` / `adopt-*` — lists what would be scaffolded (NEW vs EXISTS), writes nothing. |

### Daily workflow

| Command | What it does |
|---------|--------------|
| `/charter-next` | Read STATUS.md and start the next step. |
| `/charter-finish` | Run the finish ritual — tests, doc updates, commit, standard report. Adapts to main vs feature branch. |
| `/charter-cost` | Report how many tokens Charter has added this session. |
| `/charter-off` | Disable rituals for the rest of the session — just execute directly. |

### Working memory & post-`/compact` recovery

| Command | What it does |
|---------|--------------|
| `/charter-remember` | Capture a fact to `docs/CONTEXT.md` so it survives `/compact`. |
| `/charter-recover` | **Tier 1 recovery** — restore orientation from CONTEXT.md + STATUS.md + active branch plan. Cheapest. Use first. |
| `/charter-replay` | **Tier 2 recovery** — read the dialogue-only filter of the session transcript (genuine prompts + replies, no tool I/O or harness injections). Use when tier 1 isn't enough. |

(Tier 3 — reading the raw `.jsonl` — is an anti-pattern. Don't.)

### Opt-in conventions

| Command | What it does |
|---------|--------------|
| `/charter-adopt branches` | Per-feature-branch plans + branch-aware finish ritual. STATUS.md stays conflict-free. |
| `/charter-adopt context` | Working-memory doc (`docs/CONTEXT.md`) + the discipline rule. Enables `/charter-remember` + `/charter-recover`. |

---

## For the AI reading this

If you are about to build session-recovery, transcript-filtering, branch-management, working-memory, or scaffolding tooling for this project — **stop and check the table above first.** Charter very likely already ships it. Three separate sessions have rebuilt features Charter already had. Reuse `/charter-replay`, `/charter-recover`, `/charter-adopt branches`, etc. instead of reinventing them. If a command does *almost* what's needed, improving the command beats writing a parallel one.
