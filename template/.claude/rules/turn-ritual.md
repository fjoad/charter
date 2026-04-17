# Turn Ritual

Every incoming request is classified by tier before responding. Apply the matching ritual.

## Tier Classification

| Tier | Signal | Examples |
|------|--------|---------|
| **Trivial** | Single-line change, no logic, no interfaces | Fix typo, rename variable, update a constant |
| **Small** | Under 1 hour, well-understood, no interface changes | Add a flag, fix a known bug, update a config value |
| **Medium** | Multi-file, touches interfaces, moderate risk | Add a feature, refactor a module, update an API |
| **Major** | Architecture change, new component, high risk | New subsystem, dependency change, data model change |

## Ritual by Tier

### Trivial
1. Execute directly
2. Verify the specific change is correct
3. No plan, no commit required (unless user requests)

### Small
1. State what you're doing in one sentence
2. Implement
3. Verify (run tests if relevant, check output)
4. Report result

### Medium
1. Use `superpowers:writing-plans` — create implementation plan, save to `docs/plans/`
2. Get user approval (or proceed if plan is straightforward)
3. Use `superpowers:test-driven-development` — tests first for logic
4. Implement per plan
5. Use `superpowers:verification-before-completion` — verify before claiming done
6. Run finish checklist from `workflow.md`

### Major
1. Use `superpowers:writing-plans` — create implementation plan with `## CHECKPOINT: user review` markers
2. **CHECKPOINT** — pause, present plan, wait for user approval
3. Use `superpowers:subagent-driven-development` for parallel subtasks if applicable
4. Use `superpowers:test-driven-development` throughout
5. Use `superpowers:verification-before-completion` at each checkpoint
6. Run finish checklist from `workflow.md`

## Escape Hatch

If the user says "skip ritual", "no ritual", "just do it", or invokes `/charter-off`, revert to direct execution for the rest of the session. Resume ritual classification at next session start.

## Ambiguous Tier

When in doubt, classify one tier higher. Over-discipline is recoverable; under-discipline causes drift.
