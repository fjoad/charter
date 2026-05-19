# Charter — Project Status

**Last updated:** 2026-05-12 (v0.3.0 in progress)  
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
| End-to-end tests | Done (v0.1.1) | — | All 6 commands verified on fresh install 2026-04-20 |
| Published to GitHub | Done | https://github.com/fjoad/charter | Public, MIT — v0.1.1 pushed |
| Submitted to marketplace | Pending re-review | — | v0.1.0 submitted broken; v0.1.1 fix needs push + reviewer notification |
| Branch handling | Done (v0.2.0) | `hooks/`, `commands/`, `template/`, `tests/` | Merged 2026-05-12 — see [decision](decisions/2026-05-12-branch-handling.md) and [plan](plans/2026-05-12-branch-handling.md) |
| Test harness | Done (v0.2.0) | `tests/`, `scripts/verify-plugin.sh` | Shell-based test runner; 32 fast assertions across session-start, turn-nudge, and plugin-structure |
| CI | Done (v0.2.0) | `.github/workflows/test.yml` | GitHub Actions runs verify-plugin.sh on push to main + PRs |
| E2E install test | Done (v0.2.0) | `tests/e2e-install.sh` | Spawns real `claude -p` sessions, verifies plugin loads + hook fires; 11 assertions, run manually before release (not in CI — costs tokens) |
| Working memory (CONTEXT.md) | Done (v0.3.0) | `template/`, `hooks/`, `commands/`, `.claude/rules/` | AI-maintained working memory across compactions; auto-loaded by session-start; `/charter-remember` + `/charter-recover` + opt-in `/charter-adopt context` |

---

## Branch State

| Branch | Purpose | Status |
|--------|---------|--------|
| `main` | Active development | Current |

---

## In-flight Branches

<!-- One line per active feature branch. Format: `- \`branch-name\` → docs/plans/<plan-file>.md — short status`. The session-start hook reads this section. -->

- `feat/context-doc` → [docs/plans/2026-05-12-context-doc.md](plans/2026-05-12-context-doc.md) — v0.3.0 working memory, in progress

---

## Recent Decisions

| Date | Decision | Why |
|------|----------|-----|
| 2026-05-12 | Working memory doc (CONTEXT.md) | AI scratchpad across compactions, auto-loaded; same capability-detection backward-compat (see decisions/2026-05-12-context-doc.md) |
| 2026-05-12 | Branch handling via capability detection | Backward-compat, opt-in, plans-as-branch-unit (see decisions/2026-05-12-branch-handling.md) |
| 2026-04-20 | Commands must be `.md` not `.toml` | Claude Code plugin loader only reads flat MD with YAML frontmatter |
| 2026-04-18 | hooks/ → hooks/hooks.json | Standard plugin structure per Claude Code docs |
| 2026-04-18 | skills/ at root (not plugin/) | Claude Code discovers by convention, not plugin.json |
| 2026-04-18 | session-start hints init/attach when no scaffold | Users shouldn't need docs to know next step |
| 2026-04-18 | vision-drafter returns content, never writes files | brief-intake owns file writing after user approval |
| 2026-04-17 | Checkpoint-based autonomy model | Manager/dev-team metaphor |

---

## What to Work On Next

1. ~~Everything through publish~~ (done)
2. ~~v0.1.1 fix complete — commands verified, docs updated, pushed~~ (done)
3. ~~Branch handling (v0.2.0) — merged + pushed + tagged 2026-05-12~~ (done)
4. **Working memory / CONTEXT.md (v0.3.0)** **(current — feat/context-doc)**
5. Await marketplace review acceptance
6. Update install instructions once marketplace accepted
7. Monitor for user feedback and bug reports
