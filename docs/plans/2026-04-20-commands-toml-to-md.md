# Charter v0.1.1 — Fix Command Loader Format (TOML → Markdown)

**Author:** Charter project (fjoad)
**Date:** 2026-04-20
**Tier:** Medium (public plugin, marketplace, cross-doc sync, decision record)
**Plan location on execution:** also copy this file to `docs/plans/2026-04-20-commands-toml-to-md.md` per Charter's workflow convention; the canonical version during planning is this file at `~/.claude/plans/`.

---

## Context

Charter v0.1.0 ships six slash commands as `commands/*.toml` files. Claude Code's plugin loader only recognizes flat `commands/*.md` files with YAML frontmatter. None of the six commands have ever registered on any install since launch. Evidence:

- Verified against Claude Code plugin reference (`plugins-reference.md`) via `claude-code-guide` agent — TOML is not a supported command format.
- A live session transcript shared by the user shows `/charter-attach` invoked via the skill-invocation syntax (`/charter:codebase-inference`) because the slash command was unavailable.
- `.claude-plugin/plugin.json` declares no explicit commands array — the loader relies on auto-discovery, and auto-discovery ignores `.toml`.

Additional drift surfaced during exploration:
- `docs/ARCHITECTURE.md:199` actively documents the wrong thing: *"Claude Code auto-discovers `.toml` files in `commands/`"*. This is the root of the bug.
- `docs/ARCHITECTURE.md:186-189` contains a TOML example block that must become Markdown.
- `docs/ARCHITECTURE.md:55-58, 195, 197` still reference a `plugin/` subdirectory that was flattened in commit `27d2719`. Adjacent stale paths; fold into the same doc sweep.
- `docs/STATUS.md` falsely claims "Commands Done" and "End-to-end tests Done". Both rows are incorrect.

**Intended outcome:** ship v0.1.1. Every slash command registers on fresh install. Docs describe the real format. A minimal verify script prevents this class of bug from recurring. Marketplace submission re-notified.

**Out of scope:** every other open sub-project from prior brainstorming (session journal G, macro/micro split B, generic templates A, extension surface C, drift tracking D, audit command E, framing rewrite I.2, branding I, PR context bundles J). Those remain on the running list and are *not* touched by this change. This is a surgical bug-fix release.

---

## File-by-file changes

### Converted (delete + add)

For each of the six command files: delete the `.toml`, add a `.md` with YAML frontmatter. Canonical templates:

**Args-taking command (`charter-init`, `charter-attach`, `charter-finish`):**
```markdown
---
description: "<copy verbatim from the TOML description field>"
argument-hint: "<see hint strings below>"
---

<prompt body verbatim from TOML, with {{args}} replaced by $ARGUMENTS>
```

**No-args command (`charter-next`, `charter-cost`, `charter-off`):**
```markdown
---
description: "<copy verbatim from the TOML description field>"
---

<prompt body verbatim from TOML>
```

Argument-hint strings:
- `charter-init.md` → `"[optional project vision hints]"`
- `charter-attach.md` → `"[optional context about the codebase]"`
- `charter-finish.md` → `"[optional notes about what was completed]"`

No `disable-model-invocation` — these are user-invoked commands; letting the model also invoke them (e.g. when it hears "let's finish this step") is fine and often useful.

### Edits

| File | Change |
|---|---|
| `.claude-plugin/plugin.json` | Version `0.1.0` → `0.1.1`. |
| `package.json` | Version `0.1.0` → `0.1.1`. |
| `docs/ARCHITECTURE.md` | Lines 34–39: change `.toml` → `.md` in tree diagram. Lines 186–189: swap TOML example block for Markdown example (frontmatter + body + `$ARGUMENTS`). Line 199: rewrite "auto-discovers `.toml` files" section — describe real format (flat `.md`, YAML frontmatter with `description`, optional `argument-hint`, body uses `$ARGUMENTS`). Lines 55–58, 195, 197: sweep stale `plugin/` path prefix from the earlier flatten refactor. |
| `docs/STATUS.md` | Mark "Commands" and "End-to-end tests" rows as not-verified for v0.1.0. Add new row: "v0.1.1 command format fix — Commands register, install verified." Bump "Last updated" to 2026-04-20. Update "What to Work On Next" to reflect post-fix state. |
| `README.md` | Lines 46–79: sweep any `.toml` string or `{{args}}` mention. Command table command names stay the same. |
| `docs/ADOPTING.md` | Sweep `.toml` and `{{args}}` strings. No structural change. |
| `docs/TOKEN-BUDGET.md` | Line 42: sweep `.toml` if present. |
| `docs/VISION.md` | Lines 40, 43: sweep `.toml` if present. |
| `docs/MANIFESTO.md` | Lines 70, 84: sweep `.toml` if present. |
| `docs/superpowers/specs/2026-04-17-charter-design.md` | Lines 42, 93, 99, 111–116: sweep `.toml` references. Add a dated "Spec drift" callout at the top: original spec assumed TOML command format; real Claude Code format is Markdown. Link to the new decision record. |
| `skills/turn-ritual/SKILL.md` (L58), `skills/brief-intake/SKILL.md` (L3, L25), `skills/codebase-inference/SKILL.md` (L3) | Sweep `.toml` strings. Prefer command names (`/charter-init`) over filenames. |
| `template/.claude/rules/turn-ritual.md` (L45) | Sweep `.toml`. |
| `AGENTS.md` | Add a one-liner under "Reading Order" or a new "Pre-release check" subsection pointing to `scripts/verify-plugin.sh`. |
| `hooks/session-start.sh` | **No change.** Line 12 prints the slash-command hint text — will work correctly once commands are registered. |
| `hooks/turn-nudge.sh`, `hooks/hooks.json` | No change. |
| `.claude-plugin/marketplace.json` | No change — source pointer `./` already tracks the latest tag. |

### New files

- `docs/decisions/2026-04-20-commands-must-be-md.md` — decision record (see content shape below).
- `scripts/verify-plugin.sh` — pre-release verification (see content shape below).

---

## Decision record content shape

`docs/decisions/2026-04-20-commands-must-be-md.md`:

- **Decision:** Charter slash commands must be flat Markdown files in `commands/` with YAML frontmatter and `$ARGUMENTS` placeholder.
- **Assumed (incorrectly):** Claude Code plugin loader auto-discovers `.toml` files. This was written into `docs/ARCHITECTURE.md` and the initial design spec.
- **Actual:** Only `.md` with YAML frontmatter registers; `{{args}}` is not a supported placeholder; `$ARGUMENTS` is.
- **Why undetected:** No install-verify step was part of the v0.1.0 release. Commands were authored, committed, and documented, but never tested in a fresh install. STATUS.md marked "Done" on authoring, not registration.
- **Recurrence guard:** `scripts/verify-plugin.sh` runs pre-push/pre-release; Charter's finish ritual adds a mandatory "plugin verified" checkbox for any change touching `commands/`, `skills/`, or `.claude-plugin/`.
- **Links:** reference this plan, the commit SHAs, and the marketplace notification message.

---

## Prevention mechanism — `scripts/verify-plugin.sh`

Pure bash, no dependencies. Exits non-zero on any failure. Checks:

1. Every file in `commands/` matches `*.md`. Any `.toml`/`.txt`/`.yaml` → fail.
2. Every `commands/*.md` starts with `---` on line 1 (YAML frontmatter present).
3. No file in `commands/` or `skills/**/SKILL.md` contains the literal string `{{args}}`.
4. `.claude-plugin/plugin.json` version matches `package.json` version.
5. Every `skills/*/SKILL.md` has `name:` and `description:` keys in frontmatter.

Wiring: documented in `AGENTS.md` and `docs/decisions/2026-04-20-commands-must-be-md.md`. Not a git hook in this change — user-run. A git pre-push hook can be layered on later if desired; keeping scope minimal.

---

## Commit strategy

Two commits on `main`, bisectable:

1. **`fix: convert commands from TOML to Markdown — TOML never registered`**
   - Delete six `.toml` files, add six `.md` files.
   - Bump `plugin.json` and `package.json` to `0.1.1`.
   - This single commit makes the commands actually work.

2. **`docs: correct command format across docs + decision record + verify script`**
   - All doc sweeps (ARCHITECTURE, STATUS, README, ADOPTING, TOKEN-BUDGET, VISION, MANIFESTO, design spec, three SKILL files, template rule, AGENTS).
   - Adjacent `plugin/`-path sweep in ARCHITECTURE.md.
   - New `docs/decisions/2026-04-20-commands-must-be-md.md`.
   - New `scripts/verify-plugin.sh` (chmod +x).
   - New `docs/plans/2026-04-20-commands-toml-to-md.md` (copy of this plan).

Tag: `v0.1.1` on the second commit. Push `main` + tag.

---

## Verification (post-execution, before reporting done)

1. `scripts/verify-plugin.sh` exits 0 locally.
2. In a temp directory: install Charter fresh (or `claude plugin update charter` in an existing session). Restart Claude Code.
3. Type `/char` in the command palette — confirm all six commands autocomplete: `/charter-init`, `/charter-attach`, `/charter-next`, `/charter-finish`, `/charter-cost`, `/charter-off`.
4. Run one args command (`/charter-attach testing with a sample project`) and confirm the prompt the model received contains the passed argument text (visible because `codebase-inference` will reference it).
5. Run one no-args command (`/charter-cost`) and confirm it executes.
6. In the same session, confirm the existing skills still work (`/charter:codebase-inference` etc.) — non-regression check.

Optional post-push: in a *different* machine/account if available, install from marketplace source once fjoad/charter main is pushed — final smoke test.

---

## Marketplace reviewer notification (post-push)

Short message appended to the submission thread:

> v0.1.0 shipped slash commands as TOML; Claude Code's plugin loader only supports Markdown. No commands registered on any install. v0.1.1 converts all six commands to the correct format and adds a verify script. Plugin is otherwise unchanged. Commits: `<fix SHA>`, `<docs SHA>`. Decision record: `docs/decisions/2026-04-20-commands-must-be-md.md`. Please re-review at tag v0.1.1. Apologies for the churn.

---

## Finish checklist (per `workflow.md`)

- [ ] `scripts/verify-plugin.sh` passes (0 / 5 checks fail).
- [ ] Manual install verification per §Verification passes (6/6 commands register, 1 args invocation + 1 no-args invocation succeed, skills still work).
- [ ] `docs/STATUS.md` updated: v0.1.1 row, false "Done" rows corrected, `Last updated` = 2026-04-20.
- [ ] `docs/ARCHITECTURE.md` updated: command format section correct, tree diagram correct, stale `plugin/` paths swept.
- [ ] `AGENTS.md` updated: `scripts/verify-plugin.sh` referenced.
- [ ] Decision record committed.
- [ ] Two commits on `main`, tag `v0.1.1` created, both pushed.
- [ ] Marketplace reviewer notified.
- [ ] Standard report delivered to user:
  ```
  Step complete: v0.1.1 command-loader fix
  - Tests: scripts/verify-plugin.sh pass; manual install 6/6 commands register, 2/2 invocations succeed; skills non-regressed.
  - Docs updated: STATUS.md, ARCHITECTURE.md, README.md, ADOPTING.md, TOKEN-BUDGET.md, VISION.md, MANIFESTO.md, design spec, 3 SKILL.md files, template/turn-ritual.md, AGENTS.md, decision record, plan.
  - Commits: 2 on main, tag v0.1.1 pushed.
  - Next step: marketplace reviewer notified; await re-review. Back to running-list priority G (session journal).
  ```

---

## Risks

- **Marketplace may have already approved v0.1.0 broken.** Mitigation: even if so, v0.1.1 push + direct message surfaces the issue; users re-pulling get the fix.
- **`argument-hint` semantics unverified against every Claude Code version.** Mitigation: keep the hint optional and minimal; fallback behavior (no hint shown) is harmless.
- **Two-commit strategy assumes no one else is pushing to `main`.** Confirmed clean tree / up-to-date with origin at plan time. Re-verify before first commit.
- **Adjacent `plugin/` path sweep could miss a reference.** Mitigation: verify script grep #5 can be extended to fail on `plugin/skills/` or `plugin/commands/` string matches; skipped for this release to stay minimal, but worth adding in a follow-up.

---

## Execution order (one-line summary)

1. Pre-flight: confirm clean tree, create `docs/plans/2026-04-20-commands-toml-to-md.md` (copy of this plan).
2. Convert six command files (delete `.toml`, create `.md`, replace `{{args}}` → `$ARGUMENTS`, add `argument-hint` for three).
3. Bump versions in `plugin.json` + `package.json`.
4. Write `scripts/verify-plugin.sh`, chmod +x.
5. Run `scripts/verify-plugin.sh` — must pass.
6. Commit 1 (`fix:`).
7. Doc sweeps per file-by-file list.
8. Write decision record.
9. Update STATUS.md, AGENTS.md.
10. Commit 2 (`docs:`).
11. Tag `v0.1.1`, push `main` + tag.
12. Fresh-install verification (temp dir).
13. Marketplace notification.
14. Standard report.
