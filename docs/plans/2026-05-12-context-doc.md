# v0.3.0 — Working Memory / Context Recovery Plan

**Status:** ✅ Complete (2026-05-12) — all tasks shipped, 44/44 tests pass, ready to merge.
**Branch:** `feat/context-doc`

**Goal:** Add `docs/CONTEXT.md` as a fourth doc category — the AI's working memory across compactions. AI maintains it inline during sessions; auto-loaded by session-start hook; restorable post-compaction via `/charter-recover`.

**Architecture:** Same playbook as v0.2.0 branch handling — capability detection, opt-in via `/charter-adopt context`, fully backward compatible. Behavior lives plugin-side; the doc + rule live user-side. Missing CONTEXT.md → today's behavior.

**Tech stack:** Bash hooks, Python3 (JSON), Markdown.

---

## File Structure

**Plugin-side (auto-updates):**
- `hooks/session-start.sh` — extend to surface CONTEXT.md when present
- `commands/charter-remember.md` — NEW: explicit capture command
- `commands/charter-recover.md` — NEW: post-compaction recovery command
- `commands/charter-adopt.md` — extend to support `context` convention
- `template/docs/CONTEXT.md` — NEW: scaffolded skeleton with sectioned structure
- `template/.claude/rules/context-discipline.md` — NEW: rule telling AI when/how to update CONTEXT.md
- `.claude-plugin/plugin.json`, `package.json` — bump to 0.3.0

**User-side (only changed by user or `/charter-adopt context`):**
- `docs/CONTEXT.md` — the working memory file
- `.claude/rules/context-discipline.md` — the rule (only if adopted)

**Charter's own dogfood:**
- `docs/CONTEXT.md` — scaffold + capture v0.2.0 learnings
- `docs/STATUS.md`, `docs/ARCHITECTURE.md`, `AGENTS.md`, `README.md`
- `docs/decisions/2026-05-12-context-doc.md` — ADR

**Tests:**
- `tests/session-start.test.sh` — append assertions for CONTEXT.md surfacing
- `tests/plugin-structure.test.sh` — verify new commands have required sections

---

## Tasks (compressed — v0.2.0 hardening proved this works)

### Task 1: Feature branch + commit plan
Already done.

### Task 2: Template skeletons
- Create `template/docs/CONTEXT.md` with sectioned structure: Environment Quirks, Working Patterns, Don't Repeat, Open Questions, User Emphases, When to Update
- Create `template/.claude/rules/context-discipline.md` with the when-to-write / when-not-to-write rule

### Task 3: Hook extension (TDD)
- Add test scenarios: scaffold + CONTEXT.md present → content surfaces in orient block; scaffold + no CONTEXT.md → identical to current behavior
- Modify `hooks/session-start.sh`: if `docs/CONTEXT.md` exists, prepend a "Working Memory" section to the orient block before "Project Status"
- Verify backward compat: old projects (no CONTEXT.md) see identical behavior

### Task 4: `/charter-remember` command
- New `commands/charter-remember.md` — takes free text, the AI categorizes and appends to matching section in CONTEXT.md, terse

### Task 5: `/charter-recover` command
- New `commands/charter-recover.md` — instructs AI to read CONTEXT.md + STATUS.md + current branch plan, in that order; explicitly skip transcript / VISION / ARCHITECTURE unless cited

### Task 6: `/charter-adopt context` support
- Extend `commands/charter-adopt.md` with a new "Convention: `context`" block
- Adds CONTEXT.md to docs/ (idempotent)
- Adds context-discipline.md to .claude/rules/ (idempotent)
- Asks before each change like the `branches` convention

### Task 7: Plugin-structure tests
- Add assertions: `charter-remember.md` has expected sections; `charter-recover.md` mentions correct read order; `charter-adopt.md` has both `branches` and `context` conventions

### Task 8: Dogfood — scaffold Charter's own CONTEXT.md
- Create `docs/CONTEXT.md` populated with real v0.2.0 learnings:
  - Working pattern: branch-handling hook plan-matching rules
  - Don't repeat: heredoc `<<'PY'` + pipe to python (Python's stdin is overridden — use `-c "$(...)"`)
  - Environment quirk: macOS lacks `timeout` by default (use just `claude` with no timeout, or `gtimeout` from coreutils)
  - Working pattern: `claude -p --plugin-dir <local> --output-format=stream-json --include-hook-events` for e2e plugin testing
- Add `docs/CONTEXT.md` to Charter's own `.claude/rules/` (via /charter-adopt context applied to Charter itself)

### Task 9: Decision record
- `docs/decisions/2026-05-12-context-doc.md` — capture the design (4th doc category, AI-maintained, auto-loaded, opt-in)

### Task 10: Update Charter's own docs
- `docs/ARCHITECTURE.md`: new "Working Memory (CONTEXT.md)" section
- `docs/STATUS.md`: add component row, In-flight Branches entry, Recent Decision, What to Work On Next update
- `AGENTS.md`: note new doc category and `/charter-remember` + `/charter-recover` commands
- `README.md`: add to Commands table, brief feature bullet
- `template/.claude/rules/project-flow.md`: mention CONTEXT.md in the "Auto-loaded every session" / "Read at session start" map
- `docs/ARCHITECTURE.md` "Last updated" date

### Task 11: Bump to v0.3.0, run full verify, merge
- `.claude-plugin/plugin.json`, `package.json`: 0.2.0 → 0.3.0
- Run `bash scripts/verify-plugin.sh` (must pass)
- Run `bash tests/e2e-install.sh` if feasible (verify plugin still loads cleanly with the new commands/template)
- Mark plan complete
- Merge to main with `--no-ff`
- Main-branch finish: update STATUS.md
- Push origin/main + tag v0.3.0

---

## Non-goals

- Pre-compaction hook detection (no clear hook event for "context filling up"). Punt to v0.4+ if Claude Code exposes this.
- AI-driven turn-by-turn CONTEXT.md update via UserPromptSubmit hook. The rule + skill is enough; adding an automatic nudge is noise.
- Auto-promotion of CONTEXT.md items to decision records. The rule says "prune when stale"; manual is fine for now.
- Separate `findings.md` / `pitfalls.md` doc categories. CONTEXT.md covers the most pressing gap; the other categories can come later as separate `/charter-adopt` conventions.

---

## Backward compatibility checklist (must be preserved)

- [ ] Project without CONTEXT.md → session-start hook output identical to today
- [ ] Project that updates plugin → no auto-edits to user files
- [ ] All existing 32 + 11 (e2e) assertions still pass
- [ ] New tests cover the additive behavior without changing existing tests

---

## CHECKPOINT-equivalent gates (continuing per user delegation "do what you think is best")

- After Task 3 (hook + tests): full suite green, capability detection verified
- After Task 6 (adopt extension): both conventions work independently
- After Task 8 (dogfood): Charter's own CONTEXT.md populated, project demonstrates the pattern
- Pre-merge: e2e install test passes against the v0.3.0 plugin
