---
description: "Dry-run for /charter-init and /charter-attach. Lists what would be scaffolded into this project, marks each file as NEW or COLLISION (existing files are skipped — Charter is non-destructive). Writes nothing."
argument-hint: "[init | attach | adopt-branches | adopt-context]  (default: attach)"
---

The user wants to preview what Charter would scaffold into this project before committing to it. **Write nothing to disk. This is a dry-run.**

$ARGUMENTS

Parse the argument:
- `init` or empty → preview what `/charter-init` would scaffold (greenfield: also runs the vision intake mentally but doesn't actually ask questions)
- `attach` → preview what `/charter-attach` would scaffold (brownfield: non-destructive, skips existing files)
- `adopt-branches` → preview what `/charter-adopt branches` would add
- `adopt-context` → preview what `/charter-adopt context` would add

If the argument is unrecognized, list the supported options and stop.

## How to preview (works the same for init/attach)

1. **Walk the plugin's template directory** (`${CLAUDE_PLUGIN_ROOT}/template/`) — list every file recursively. These are the candidates that would be written.

2. **For each candidate, check whether it already exists in the current project** (relative paths preserved). Mark:
   - `NEW` → file doesn't exist; would be created
   - `EXISTS` → file already exists; would be SKIPPED (Charter never overwrites)

3. **Report in this format** (group by NEW vs EXISTS):

```
**Preview: /charter-attach in <pwd>**

Would CREATE (NEW):
  docs/VISION.md           — thesis, goals, non-goals, success criteria
  docs/STATUS.md           — current state, what's next
  docs/ARCHITECTURE.md     — technical blueprint
  docs/CONTEXT.md          — AI working memory (v0.3.0+)
  docs/decisions/TEMPLATE.md
  docs/plans/TEMPLATE.md
  .claude/rules/project-flow.md
  .claude/rules/workflow.md
  .claude/rules/turn-ritual.md
  .claude/rules/testing.md
  .claude/rules/context-discipline.md
  .claude/settings.json
  AGENTS.md
  CLAUDE.md
  .gitignore (only if no .gitignore exists — Charter never touches existing .gitignore)

Would SKIP (EXISTS — Charter is non-destructive):
  [list any matches]

Available opt-in conventions after scaffold:
  /charter-adopt branches  — per-feature-branch plans, branch-aware finish ritual
  /charter-adopt context   — working-memory across /compact

To actually scaffold: run /charter-attach (no flags needed — it'll run the codebase-inference skill to fill the docs with project-specific content).
To preview a convention: /charter-preview adopt-branches or /charter-preview adopt-context.
```

## For `adopt-branches` and `adopt-context`

Read the corresponding section in `commands/charter-adopt.md` and list the changes it would propose, with the same NEW/EXISTS marking. Don't actually run anything from `charter-adopt.md`.

## Hard rule

**Never write a file. Never modify an existing file. Never commit.** If the user wants to actually scaffold after seeing the preview, they run `/charter-init` or `/charter-attach`.
