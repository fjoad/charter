# Testing Discipline

## What to Test

**Test deterministic logic.** Functions that transform inputs to outputs with no external dependencies. Parsing, validation, calculation, data transformation, business rules.

**Do NOT test external service calls.** Don't mock AI/LLM calls, API calls, or database queries just to have tests. The mock diverges from reality; the test gives false confidence.

**Test at the boundary.** If a function calls an external service, test the logic around the call (input preparation, output parsing, error handling) without mocking the service itself.

## When to Write Tests

- Write tests BEFORE implementation code for any deterministic logic (TDD)
- Write tests immediately after for logic discovered during implementation
- Never claim a step "done" without running the full test suite

## Test Discipline

- Tests must actually run and pass — not just exist
- A failing test is better than no test (it documents expected behavior)
- If you can't test it automatically, document why and what manual verification covers it
- Test file naming: co-located with source or in `tests/` directory, named `test_<module>` or `<module>.test`

## What Good Tests Look Like

```
class TestFeatureName:
    def test_happy_path(self):
        # given / when / then
        
    def test_edge_case(self):
        # boundary condition
        
    def test_invalid_input_rejected(self):
        # error case
```

## Rules

- **Never mock what you don't own.** External APIs change; mocks don't.
- **Never skip tests because the code "obviously works".** It obviously worked last time too.
- **If the test suite takes too long, fix the suite.** Don't stop running it.
