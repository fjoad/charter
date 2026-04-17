# Development Workflow

## For every implementation step, follow this sequence:

### 1. Plan (`writing-plans` skill)
- Read the relevant section of `docs/ARCHITECTURE.md`
- Create a detailed implementation plan
- Save plan to `docs/plans/`
- Get user approval before writing code

### 2. Implement (`executing-plans` or `subagent-driven-development` skill)
- Follow the plan step by step
- Use review checkpoints at natural boundaries
- Do not deviate from the plan without user approval

### 3. Test (`test-driven-development` skill)
- Write tests BEFORE implementation code for deterministic logic
- Do NOT mock external service calls — test pure logic only
- Run tests after each stage of implementation

### 4. Verify (`verification-before-completion` skill)
- Run full test suite
- Check that the implementation matches the plan
- Check that docs are updated if needed
- Never claim "done" without running verification

### 5. Finish — MANDATORY CHECKLIST

**Do ALL of these before telling the user a step is complete. No exceptions.**

- [ ] Run full test suite — report pass count (or note if no automated tests for this step)
- [ ] Update `docs/STATUS.md` — mark component done, update "what's next"
- [ ] Update `AGENTS.md` — if project state changed (new commands, new setup steps, etc.)
- [ ] Update `docs/ARCHITECTURE.md` — if architecture changed from what was planned
- [ ] Commit all doc updates
- [ ] Report to user in this format:

```
**Step complete: [name]**
- Tests: X/X pass (or: no automated tests for this step)
- Docs updated: STATUS.md, [list which]
- Commits: [count] commits on [branch]
- Next step: [what STATUS.md says is next]
```

## Decision Records

When a significant design choice is made during implementation (not just brainstorming), create a decision file:
- Path: `docs/decisions/YYYY-MM-DD-short-title.md`
- Content: what was decided, what alternatives existed, why this choice
- "Significant" = changes architecture, adds dependencies, changes interfaces, or would surprise a teammate

## Rules

- **Never skip steps.** Even if the task seems small.
- **Never claim done without the finish checklist.**
- **If a step fails, use `systematic-debugging` skill** before guessing at fixes.
- **If tasks are independent, use `subagent-driven-development`** to run them concurrently.
- **The finish checklist is not optional.** If the user has to ask "did you update the docs?" — you failed.
