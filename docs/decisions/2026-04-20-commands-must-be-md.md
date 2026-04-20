# Decision: Charter slash commands must be Markdown, not TOML

**Date:** 2026-04-20  
**Status:** Accepted  
**Affects:** `commands/`, `docs/ARCHITECTURE.md`, `scripts/verify-plugin.sh`

---

## Decision

Charter slash commands must be flat Markdown files (`commands/*.md`) with YAML frontmatter. Body uses `$ARGUMENTS` as the placeholder for user-supplied arguments. TOML is not supported.

## What was assumed (incorrectly)

`docs/ARCHITECTURE.md` documented that Claude Code auto-discovers `.toml` files in `commands/`. This was written into the initial design spec and all six v0.1.0 commands were shipped as `.toml`. The assumption was never verified against a fresh install.

## What is actually true

- Claude Code plugin loader only registers `commands/*.md` with YAML frontmatter.
- `{{args}}` is not a valid placeholder — `$ARGUMENTS` is.
- `.toml` files are silently ignored; no error is raised.

## Impact

All six slash commands (`/charter-init`, `/charter-attach`, `/charter-next`, `/charter-finish`, `/charter-cost`, `/charter-off`) were non-functional on every install of v0.1.0 since launch. `docs/STATUS.md` falsely marked "Commands Done" and "End-to-end tests Done".

## Why undetected

No install-verify step was part of the v0.1.0 release process. Commands were authored, committed, and documented, but never tested in a fresh Claude Code session.

## Recurrence guard

- `scripts/verify-plugin.sh` — checks command format, frontmatter presence, `$ARGUMENTS` usage, and version consistency. Run before any release.
- Charter's finish ritual checklist now includes a mandatory "plugin verified" checkbox for any change touching `commands/`, `skills/`, or `.claude-plugin/`.

## Links

- Fix plan: `docs/plans/2026-04-20-commands-toml-to-md.md`
- Fix commits: `437b3d0` (commands), `5be7848` (docs)
