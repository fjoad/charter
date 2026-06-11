# Charter — Project Status

**Last updated:** 2026-06-11 (v0.8.0 in progress)  
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
| Working memory (CONTEXT.md) | Done (v0.3.0) | `template/`, `hooks/`, `commands/`, `.claude/rules/` | AI-maintained working memory across compactions; auto-loaded by session-start; `/charter-remember` + `/charter-recover` + opt-in `/charter-adopt context`. Merged 2026-05-12. |
| Tier-2 recovery (/charter-replay) | Done (v0.4.0) | `commands/`, `.claude/rules/` | Filtered-transcript recovery for when CONTEXT.md isn't enough. Three-tier model documented. |
| Preview command + CONTEXT-per-branch articulation | Done (v0.5.0) | `commands/charter-preview.md`, `docs/ARCHITECTURE.md`, rules | Dry-run for init/attach/adopt-*. CONTEXT.md branch-scoped behavior made explicit. |
| Replay filter hardening | Done (v0.5.1) | `scripts/replay-filter.py`, `commands/charter-replay.md`, `tests/` | Committed, unit-tested filter excludes harness injections + adds turn counts. Inventory from 11-project transcript sweep. |
| Discoverability (/charter-help) | Done (v0.6.0) | `commands/charter-help.md`, `hooks/session-start.sh` | Command catalog + AI-facing orient-block pointer. Test-enforced sync. Addresses 3 sibling-session reinventions. |
| Self-contained replay-filter | Done (v0.7.0) | `scripts/replay-filter.py`, `commands/charter-replay.md` | One-shot: auto-finds the session transcript (no path arg), prints dialogue to stdout. |
| Token budget (enforced) | Done (v0.8.0) | `hooks/session-start.sh`, `scripts/measure-overhead.sh` | Completed plans skipped; plans cap 40 lines, CONTEXT 200; CI budget gate at 24k chars; /charter-cost measures for real. |
| Dev-sync (staleness) | Done (v0.8.1) | `scripts/dev-sync.sh`, `hooks/session-start.sh`, workflow.md | Release ritual refreshes own install; opt-in version-drift nudge via ~/.config/charter/dev-source. |

---

## Branch State

| Branch | Purpose | Status |
|--------|---------|--------|
| `main` | Active development | Current |

---

## In-flight Branches

<!-- One line per active feature branch. Format: `- \`branch-name\` → docs/plans/<plan-file>.md — short status`. The session-start hook reads this section. -->

_None active._

---

## Recent Decisions

| Date | Decision | Why |
|------|----------|-----|
| 2026-06-11 | Dev-sync: staleness fixed via finish ritual + opt-in nudge | Stale installs caused the sibling reinventions; the ritual that caused it now cures it (see decisions/2026-06-11-dev-sync.md) |
| 2026-06-11 | Orient-block token budget enforced | Completed plans skipped, caps + CI gate; "measure, prune" applied to Charter itself (see decisions/2026-06-11-token-budget.md) |
| 2026-06-09 | replay-filter.py self-contained (auto-find transcript) | Collapse /charter-replay to a one-shot "run this"; script finds its own session JSONL (see decisions/2026-06-09-replay-self-contained.md) |
| 2026-06-09 | /charter-help + AI-facing discoverability | 3 sibling sessions rebuilt shipped features; orient block now points the AI at /charter-help before it reinvents (see decisions/2026-06-09-charter-help-discoverability.md) |
| 2026-06-09 | /charter-replay filter as committed script | Edge cases (interrupt `[` over-match, image strip-keep) too fiddly to re-derive in-prompt; now unit-tested (see decisions/2026-06-09-replay-filter-as-script.md) |
| 2026-06-04 | /charter-preview + CONTEXT-per-branch articulation | Dry-run UX for evaluation; clarifies CONTEXT.md is allowed on feature branches unlike STATUS sections (see decisions/2026-06-04-preview-and-context-per-branch.md) |
| 2026-05-12 | /charter-replay tier-2 recovery | Filtered-transcript fallback for when CONTEXT.md is sparse; bridges tier-1 (cheap) and full-transcript (anti-pattern) (see decisions/2026-05-12-replay-command.md) |
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
4. ~~Working memory / CONTEXT.md (v0.3.0) — merged + pushed + tagged 2026-05-12~~ (done)
5. ~~Tier-2 recovery / /charter-replay (v0.4.0) — merged + pushed + tagged 2026-05-12~~ (done)
6. ~~Branch-cleanup finish-ritual patch (v0.4.1) — merged + pushed + tagged 2026-06-04~~ (done)
7. ~~Preview + CONTEXT-per-branch articulation (v0.5.0) — merged 2026-06-04~~ (done)
8. ~~Replay filter hardening (v0.5.1) — merged 2026-06-09~~ (done)
9. ~~`/charter-help` + AI-facing discoverability (v0.6.0) — merged 2026-06-09~~ (done)
10. ~~Self-contained replay-filter (v0.7.0) — merged 2026-06-09~~ (done)
11. **Workflow-hardening arc: ~~v0.8.0 token budget~~ → ~~v0.8.1 dev-sync~~ → v0.9.0 smart recover** **(current — v0.9.0 next)**
12. Think through monorepo support (v2+ scope) — design pass only, no build
11. Await marketplace review acceptance
12. Update install instructions once marketplace accepted
13. Monitor for user feedback and bug reports
