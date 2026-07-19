---
branch: feat/cross-agent-evidence
status: complete
---

# Cross-agent bootstrap + causal evidence memory

## Goal

Make Charter's scaffold genuinely shared between Claude and Codex, and add an opt-in durable evidence
layer for causal corrections that are too important for the compact/prunable `CONTEXT.md`.

## Design

1. `AGENTS.md` remains the agent-neutral canonical bootstrap. Claude imports it explicitly from
   `CLAUDE.md`; Codex reads it directly. `.claude/rules/` contains automation, never unique facts.
2. Add generic evidence labels and source-precedence guidance to the shared `AGENTS.md` template.
3. Add `/charter-adopt evidence`, idempotently creating `docs/EVIDENCE-AND-LEARNINGS.md`. Keep it opt-in
   for backward compatibility and surface control.
4. Teach preview/help/recovery/context discipline about the evidence layer without auto-loading the full
   document every session. `CONTEXT.md` points to relevant durable learnings; evidence is read on demand.
5. Update Charter's own docs and dogfood the same cross-agent boundary.
6. Ship as v0.10.0, validate structurally and end-to-end, merge to main, tag, push, then refresh the
   installed Claude plugin through `scripts/dev-sync.sh`.

## Files

- Shared scaffolding: `template/AGENTS.md`, `template/CLAUDE.md`,
  `template/.claude/rules/{project-flow,context-discipline}.md`, `template/docs/CONTEXT.md`
- Commands: `charter-adopt.md`, `charter-preview.md`, `charter-help.md`, `charter-recover.md`
- Plugin dogfood equivalents: root `AGENTS.md`, `CLAUDE.md`, `.claude/rules/`, `docs/CONTEXT.md`
- Product docs: `README.md`, `docs/{VISION,ARCHITECTURE,ADOPTING,STATUS}.md`
- Tests/version manifests as required.

## Verification

- Add structural assertions for the explicit `@AGENTS.md` import, cross-agent ownership boundary,
  evidence convention/help/preview coverage, and version synchronization.
- Run `npm test` / `bash scripts/verify-plugin.sh`.
- Run `bash tests/e2e-install.sh` before tagging.
- Confirm no Codex marketplace/cachebuster flow is applicable unless Charter is actually registered as a
  local Codex plugin; do not invent a `.codex-plugin` manifest or edit marketplace state by hand.

Completed 2026-07-19:

- `npm test`: 29 structural + 121 behavioral checks passed.
- `bash tests/e2e-install.sh`: 14/14 assertions passed across five real Claude sessions.
- `bash scripts/measure-overhead.sh`: adversarial orient block remained within its enforced cap; the
  optional evidence document is not injected.
- Source was current with `origin/main`; installed Claude cache matched source v0.9.1 before the update.
- No Charter Codex plugin or personal Codex marketplace entry exists, so Codex cachebuster/reinstall does
  not apply. Cross-agent compatibility is delivered through the shared scaffold.

## Finish

- Commit feature on this branch and push it.
- Merge `--no-ff` into `main`, update `docs/STATUS.md`, tag `v0.10.0`, push main + tag.
- Run `bash scripts/dev-sync.sh`; start a new Claude session to consume the refreshed install.
