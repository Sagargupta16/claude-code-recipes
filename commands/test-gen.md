---
model: sonnet
description: Generate comprehensive tests for a specified file with edge cases and error scenarios
---

Generate a thorough test suite for the file or module specified in `$ARGUMENTS`.

## Step 1 — Analyze the Target

Read the file specified in `$ARGUMENTS`. If a file path is not provided, ask the user which file to test.

Identify:
- All exported functions, classes, and methods
- Input parameters and their types
- Return types and possible return values
- Side effects (I/O, network calls, database access, global state)
- Error conditions (thrown exceptions, rejected promises, error returns)
- Edge cases (empty inputs, boundary values, null/undefined, concurrency)
- Dependencies that will need mocking

## Step 2 — Detect the Testing Framework

Search the project for testing configuration:

1. Check `package.json` for `jest`, `vitest`, `mocha`, `@testing-library/*`
2. Check for `jest.config.*`, `vitest.config.*`, `.mocharc.*`
3. Check for `pytest.ini`, `pyproject.toml [tool.pytest]`, `conftest.py`
4. Check for `_test.go` files, `Cargo.toml [dev-dependencies]`
5. Look at existing test files to match the project's testing patterns

Match the project's existing conventions: import style, describe/it vs test(), assertion library, file naming (`*.test.ts` vs `*.spec.ts` vs `test_*.py`), and directory structure (`__tests__/` vs co-located).

## Step 3 — Plan Test Cases

Organize tests into these categories:

### Happy Path Tests
- Test each function with typical, valid inputs
- Test the primary use case end-to-end
- Verify correct return values and side effects

### Edge Case Tests
- Empty strings, empty arrays, empty objects
- Zero, negative numbers, very large numbers
- Boundary values (min/max of ranges, off-by-one)
- Unicode, special characters, very long strings
- Single-element collections, collections at capacity

### Error Scenario Tests
- Invalid input types (if not caught by type system)
- Missing required parameters
- Network/I/O failures (timeouts, connection refused)
- Permission errors, not-found errors
- Concurrent access or race conditions if applicable

### Integration Points (if applicable)
- Mock external dependencies (HTTP clients, databases, file system)
- Verify correct interaction with dependencies (call count, arguments)
- Test error propagation from dependencies

## Step 4 — Generate the Test File

Write the test file following these principles:

1. **One concept per test.** Each test should verify exactly one behavior.
2. **Descriptive names.** Use names that read like specifications: `it("returns empty array when input list is empty")`.
3. **Arrange-Act-Assert.** Structure every test clearly into setup, execution, and verification.
4. **No test interdependence.** Each test must be able to run independently and in any order.
5. **Minimal mocking.** Only mock what is necessary (external I/O, time, randomness). Do not mock the unit under test.
6. **Deterministic.** No reliance on real time, network, or random values.

Place the test file in the correct location following the project's conventions.

## Step 5 — Verify

Run the test suite to confirm all new tests pass:
- If tests fail, read the failure output, fix the test or identify a real bug, and re-run.
- If a test reveals an actual bug in the source code, report it clearly to the user but do not modify the source — only fix the test expectations if the current behavior is intentional.

## Step 6 — Report

```
## Test Generation Report

**File under test:** path/to/file
**Test file created:** path/to/test/file
**Framework:** jest / vitest / pytest / etc.

**Tests written:** (count)
- Happy path: X
- Edge cases: Y
- Error scenarios: Z

**Test results:** all passing / X failures

**Coverage gaps:** List any functions or branches that are difficult
to test and why (e.g., requires integration test, hardware dependency).
```

If `$ARGUMENTS` includes "coverage", also run the coverage tool and report line/branch coverage percentages.
