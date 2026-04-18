# Charter

**AI-assisted project discipline plugin for Claude Code and Codex CLI.**

You're the manager. The AI is your dev team. Charter is your PMO.

Charter enforces session-to-session continuity through living docs and lightweight rituals layered on top of [superpowers](https://github.com/obra/superpowers). Install once, never re-explain your project again.

---

## The Problem

AI-assisted projects drift. Each new session starts cold: the assistant doesn't know where you left off, which decisions were made and why, or what rituals your project enforces. You re-explain vision, re-derive architecture, and re-approve the same patterns every session.

Charter fixes this.

**Without Charter** — every session starts with:
> "What are we building? Where did we leave off? What decisions did we make?"

**With Charter** — Claude opens with:
> "You're on step 3: implementing the render pipeline. Last session you decided to use Puppeteer over wkhtmltopdf (see docs/decisions/). Next: write the HTML emit stage."

---

## Install

**If Charter is listed in the official plugin directory:**
```
/plugin install superpowers
/plugin install charter
```

**Install directly from GitHub** (always works, use this if the above doesn't):
```
/plugin install superpowers
/plugin marketplace add fjoad/charter
/plugin install charter@fjoad-charter
```

> Charter has been submitted to the official Claude Code plugin directory and is pending review. Once accepted, `/plugin install charter` will work directly. Until then, use the GitHub install path above.

Then for a new project:
```
/charter-init
```

Or for an existing project:
```
/charter-attach
```

---

## What It Does

**At session start:** Reads your STATUS.md and orients Claude before the first message. Zero re-explanation.

**On every request:** Classifies size (trivial/small/medium/major) and applies matching ritual depth. Typo fix → direct execution. Architecture change → full plan, checkpoint, verify, report.

**At step completion:** Enforces the finish checklist. Tests run. Docs updated. Status recorded. Standard report to you.

**Checkpoint-based autonomy:** Plans embed `## CHECKPOINT: user review` markers. AI runs autonomously between checkpoints, pauses at each. You stay in control without micromanaging.

---

## Commands

Charter runs automatically — you don't need these commands for day-to-day use. They're there when you want to explicitly trigger something or take over.

| Command | When to use it |
|---------|---------------|
| `/charter-init` | Once, to bootstrap a new project |
| `/charter-attach` | Once, to attach Charter to an existing project |
| `/charter-next` | Explicitly start the next step (Charter will nudge you anyway) |
| `/charter-finish` | Explicitly run the finish ritual (Charter will remind you anyway) |
| `/charter-cost` | See how many tokens Charter has added this session |
| `/charter-off` | Kill rituals for the rest of the session — just get things done |

---

## What Gets Scaffolded

```
docs/
  VISION.md       # Thesis, goals, non-goals, success criteria
  STATUS.md       # Current state, what's next (the source of truth)
  ARCHITECTURE.md # Technical blueprint
  decisions/      # ADRs for design choices
  plans/          # Implementation plans with CHECKPOINT markers
.claude/rules/    # Auto-loaded session-start + workflow + ritual + testing rules
AGENTS.md         # Canonical guide — works with Claude Code, Codex CLI, and more
CLAUDE.md         # One-line pointer to AGENTS.md
```

---

## Token Overhead

Charter adds ~1.8% of context window overhead per session (~3,550 tokens in a 200k context). See [docs/TOKEN-BUDGET.md](docs/TOKEN-BUDGET.md) for the full breakdown.

---

## How It Compares

- **vs superpowers:** Charter layers on top of superpowers. superpowers handles execution skills; Charter handles routing and session continuity. Use both.
- **vs CLAUDE.md by hand:** Charter templates it correctly, keeps it current via finish ritual, and hooks it into session start automatically.
- **vs spec-driven tools:** Charter is discipline-first, not spec-first. Works iteratively, no upfront spec required.

Full comparison: [docs/COMPARISON.md](docs/COMPARISON.md)

---

## Documentation

- [docs/VISION.md](docs/VISION.md) — thesis and goals
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — plugin layout and hook flow
- [docs/MANIFESTO.md](docs/MANIFESTO.md) — the pitch
- [docs/ADOPTING.md](docs/ADOPTING.md) — install and usage guide
- [docs/TOKEN-BUDGET.md](docs/TOKEN-BUDGET.md) — cost model
- [docs/COMPARISON.md](docs/COMPARISON.md) — Charter vs alternatives

---

## License

MIT — see [LICENSE](LICENSE).
