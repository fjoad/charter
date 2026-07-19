---
description: "List everything Charter offers — all commands, opt-in conventions, and recovery tiers. Run this before building session-recovery, branch, or context tooling: Charter probably already has it."
---

The user wants to see what Charter provides. Present the catalog below, cleanly formatted. If the user named a specific command or topic in their message, expand on that one; otherwise show the full catalog.

**Also do a freshness check:** list `${CLAUDE_PLUGIN_ROOT}/commands/*.md`. If any command file exists that is NOT in the catalog below, mention it — the plugin may be newer than this help text.

---

## Charter — command catalog

**Charter is a Claude Code plugin that keeps multi-session projects oriented and disciplined.** You're the manager, the AI is the dev team, Charter is the PMO. It runs mostly automatically; these commands are for when you want to trigger something explicitly.

### Daily

| Command | What it does |
|---------|--------------|
| `/charter-next` | Read STATUS.md and start the next step. |
| `/charter-finish` | Run the finish ritual — tests, doc updates, commit, standard report. Adapts to main vs feature branch. |
| `/charter-recover` | **The recovery command.** After `/compact`, restores orientation from CONTEXT.md + STATUS.md + branch plan — and auto-escalates to a transcript replay if working memory is thin. You never pick a tier; it does. |
| `/charter-remember` | Capture a fact to `docs/CONTEXT.md` so it survives `/compact`. |
| `/charter-off` | Disable rituals for the rest of the session — just execute directly. |

### Setup (once per project)

| Command | What it does |
|---------|--------------|
| `/charter-init` | Bootstrap a NEW project — vision intake, scaffolds the living-docs structure. |
| `/charter-attach` | Attach Charter to an EXISTING codebase — infers vision, scaffolds non-destructively. |
| `/charter-preview` | Dry-run of `init` / `attach` / `adopt-*` — lists what would be scaffolded, writes nothing. |
| `/charter-adopt branches` | Opt-in: per-feature-branch plans + branch-aware finish ritual. |
| `/charter-adopt context` | Opt-in: working-memory doc (`docs/CONTEXT.md`) + discipline rule. |
| `/charter-adopt evidence` | Opt-in: durable causal/evidence record so invalidated conclusions and confidence survive beyond prunable working memory. |

### Power / occasional

| Command | What it does |
|---------|--------------|
| `/charter-replay` | Direct access to the transcript replay (`scripts/replay-filter.py` — one-shot, auto-finds the session, strips tool I/O + harness injections). `/charter-recover` runs this for you when needed; reach for it directly only when you explicitly want the full dialogue. |
| `/charter-cost` | Measure Charter's token overhead for this session (runs `scripts/measure-overhead.sh` for the real orient-block number). |

(Reading the raw session `.jsonl` is never the answer — it's hundreds of thousands of tokens of tool noise. `/charter-recover` handles recovery.)

---

## For the AI reading this

If you are about to build session-recovery, transcript-filtering, branch-management, working-memory,
causal-evidence, or scaffolding tooling for this project — **stop and check the table above first.**
Charter very likely already ships it. Reuse `/charter-recover`, `/charter-adopt evidence`, etc. instead
of reinventing them. If a command does *almost* what's needed, improving the command beats writing a
parallel one.
