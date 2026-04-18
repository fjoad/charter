# Charter — Project Status

**Last updated:** 2026-04-18  
**Current branch:** `main`

---

## Component Status

| Component | Status | Location | Notes |
|-----------|--------|----------|-------|
| Design spec | Done | `docs/superpowers/specs/` | 13 decisions locked |
| Foundation docs | Done | `docs/` | VISION, STATUS, ARCHITECTURE, MANIFESTO |
| Plugin manifest | Done | `.claude-plugin/` | plugin.json + marketplace.json |
| Hooks | Done | `hooks/` | session-start.sh + turn-nudge.sh + hooks.json |
| Skills | Done | `skills/` | brief-intake, codebase-inference, turn-ritual |
| Commands | Done | `commands/` | 6 TOML files |
| Subagent | Done | `agents/` | vision-drafter.md |
| Template files | Done | `template/` | 4 rules + 3 doc skeletons + ADR/plan templates |
| Extended docs | Done | `docs/` | ADOPTING, TOKEN-BUDGET, COMPARISON, README |
| End-to-end tests | Done | — | Hooks, scaffold, skills, orient all verified |
| Published to GitHub | Done | https://github.com/fjoad/charter | Public, MIT |
| Submitted to marketplace | Done | — | Pending Anthropic review |

---

## Branch State

| Branch | Purpose | Status |
|--------|---------|--------|
| `main` | Active development | Current |

---

## Recent Decisions

| Date | Decision | Why |
|------|----------|-----|
| 2026-04-18 | hooks/ → hooks/hooks.json | Standard plugin structure per Claude Code docs |
| 2026-04-18 | skills/ at root (not plugin/) | Claude Code discovers by convention, not plugin.json |
| 2026-04-18 | session-start hints init/attach when no scaffold | Users shouldn't need docs to know next step |
| 2026-04-18 | vision-drafter returns content, never writes files | brief-intake owns file writing after user approval |
| 2026-04-17 | Checkpoint-based autonomy model | Manager/dev-team metaphor |

---

## What to Work On Next

1. ~~Everything through publish~~ (done)
2. **Iterate based on real usage** — open issues, UX improvements, marketplace acceptance **(current)**
3. Update install instructions once marketplace accepted
4. Monitor for user feedback and bug reports
