# Charter — Project Status

**Last updated:** 2026-04-17  
**Current branch:** `main`

---

## Component Status

| Component | Status | Location | Notes |
|-----------|--------|----------|-------|
| Design spec | Done | `docs/superpowers/specs/2026-04-17-charter-design.md` | 13 decisions locked, spec self-reviewed |
| Foundation docs | Done | `docs/` | VISION, STATUS, ARCHITECTURE, MANIFESTO written |
| Root AGENTS.md + CLAUDE.md | Done | repo root | Canonical operational guide in place |
| Plugin manifest | Not started | `.claude-plugin/` | plugin.json + marketplace.json + package.json |
| Hooks | Not started | `plugin/hooks/` | session-start.sh + turn-nudge.sh |
| Skills | Not started | `plugin/skills/` | brief-intake, codebase-inference, turn-ritual |
| Commands | Not started | `plugin/commands/` | 6 TOML files |
| Subagent | Not started | `plugin/agents/` | vision-drafter.md |
| Template files | Not started | `template/` | Rules + doc skeletons + ADR/plan templates |
| Docs (extended) | Not started | `docs/` | ADOPTING, TOKEN-BUDGET, COMPARISON, ADR |
| Full README | Not started | `README.md` | Public landing page |
| End-to-end tests | Not started | — | Greenfield + brownfield + ritual + session-start |

---

## Branch State

| Branch | Purpose | Status |
|--------|---------|--------|
| `main` | Active development | Current |

---

## Recent Decisions

| Date | Decision | Why |
|------|----------|-----|
| 2026-04-17 | AGENTS.md canonical, CLAUDE.md = pointer | Multi-tool future-proofing (60k+ repos use AGENTS.md) |
| 2026-04-17 | Soft superpowers dependency (README prose) | No formal dep field in plugin.json API yet |
| 2026-04-17 | Rename `test` → `charter` deferred to Step 10 | Renaming mid-session breaks bash tool cwd |
| 2026-04-17 | Checkpoint-based autonomy model | Manager/dev-team metaphor — AI runs between checkpoints, pauses at each |
| 2026-04-17 | Three-tier ritual (trivial/small/medium/major) | Prevent under-discipline AND over-discipline |

---

## What to Work On Next

1. ~~Design spec + self-review~~ (done)
2. ~~Foundation docs (VISION, STATUS, ARCHITECTURE, MANIFESTO, AGENTS.md)~~ (done)
3. **Plugin manifest** — `.claude-plugin/plugin.json`, `marketplace.json`, `package.json` **(next)**
4. **Hooks** — `session-start.sh`, `turn-nudge.sh`
5. **Core template files** — `template/.claude/rules/` (4 files) + `template/docs/` skeletons + ADR + plan templates
6. **Skills** — `brief-intake`, `codebase-inference`, `turn-ritual`
7. **Commands** — 6 TOML files
8. **Subagent** — `vision-drafter.md`
9. **Extended docs** — ADOPTING, TOKEN-BUDGET, COMPARISON, ADR for initial architecture, full README
10. **End-to-end dogfood tests** — greenfield + brownfield + ritual + session-start + finish + cost
11. **Publish** — rename folder, push to GitHub, submit to marketplace
