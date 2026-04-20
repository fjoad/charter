# Charter — Project Status

**Last updated:** 2026-04-20  
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
| Commands | Done (v0.1.1) | `commands/` | 6 MD files — TOML never registered, fixed in v0.1.1 |
| Subagent | Done | `agents/` | vision-drafter.md |
| Template files | Done | `template/` | 4 rules + 3 doc skeletons + ADR/plan templates |
| Extended docs | Done | `docs/` | ADOPTING, TOKEN-BUDGET, COMPARISON, README |
| Verify script | Done | `scripts/verify-plugin.sh` | Pre-release checks: format, frontmatter, versions |
| End-to-end tests | Not verified | — | Commands never tested on fresh install in v0.1.0; v0.1.1 pending manual verify |
| Published to GitHub | Done | https://github.com/fjoad/charter | Public, MIT — 2 commits ahead of origin, not yet pushed |
| Submitted to marketplace | Pending re-review | — | v0.1.0 submitted broken; v0.1.1 fix needs push + reviewer notification |

---

## Branch State

| Branch | Purpose | Status |
|--------|---------|--------|
| `main` | Active development | Current |

---

## Recent Decisions

| Date | Decision | Why |
|------|----------|-----|
| 2026-04-20 | Commands must be `.md` not `.toml` | Claude Code plugin loader only reads flat MD with YAML frontmatter |
| 2026-04-18 | hooks/ → hooks/hooks.json | Standard plugin structure per Claude Code docs |
| 2026-04-18 | skills/ at root (not plugin/) | Claude Code discovers by convention, not plugin.json |
| 2026-04-18 | session-start hints init/attach when no scaffold | Users shouldn't need docs to know next step |
| 2026-04-18 | vision-drafter returns content, never writes files | brief-intake owns file writing after user approval |
| 2026-04-17 | Checkpoint-based autonomy model | Manager/dev-team metaphor |

---

## What to Work On Next

1. ~~Everything through publish~~ (done)
2. **v0.1.1 fix shipped locally — push + verify + notify reviewer** **(current)**
3. Manual install verification: fresh install, confirm all 6 commands register
4. Marketplace reviewer notification (message template in plan `docs/plans/2026-04-20-commands-toml-to-md.md`)
5. Update install instructions once marketplace accepted
6. Monitor for user feedback and bug reports
