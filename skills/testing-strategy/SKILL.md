# Testing Strategy

> Testing approach: unit/integration/e2e split, what to test, test structure (AAA pattern), mocking strategies, and coverage targets.

## Testing Pyramid

Follow the testing pyramid — more unit tests, fewer integration tests, even fewer e2e tests:

```
        /  E2E  \           ~5%   — Critical user journeys
       /----------\
      / Integration \       ~20%  — Module boundaries, API contracts
     /----------------\
    /    Unit Tests     \   ~75%  — Functions, components, utilities
   /____________________\
```

| Level | Speed | Scope | Quantity |
|-------|-------|-------|----------|
| Unit | Fast (ms) | Single function/component | Many |
| Integration | Medium (seconds) | Module interactions, DB, API | Some |
| E2E | Slow (seconds-minutes) | Full user flows | Few |

## What to Test

### Always Test

- Business logic and calculations
- Data transformations and mappings
- Validation rules
- Error handling paths
- Edge cases: empty inputs, boundary values, null/undefined
- Public API of modules (exported functions)
- State transitions (reducers, state machines)
- Critical user journeys (e2e)

### Don't Test

- Third-party library internals
- Simple getters/setters with no logic
- Framework boilerplate (constructor, lifecycle method existence)
- Implementation details (private methods, internal state shape)
- Constants and configuration values
- CSS styling (use visual regression tools instead)

## Test Structure — AAA Pattern

Every test should follow **Arrange, Act, Assert**:

```typescript
describe("OrderService", () => {
  describe("calculateTotal", () => {
    it("applies percentage discount to subtotal", () => {
      // Arrange
      const items = [
        { name: "Widget", price: 25.00, quantity: 2 },
        { name: "Gadget", price: 15.00, quantity: 1 },
      ];
      const discount = { type: "percentage", value: 10 };

      // Act
      const total = calculateTotal(items, discount);

      // Assert
      expect(total).toBe(58.50); // (50 + 15) * 0.90
    });
  });
});
```

### Naming Rules

1. **Describe blocks name the unit** — `describe("OrderService")`, `describe("calculateTotal")`
2. **Test names describe the behavior** — `it("applies percentage discount to subtotal")`
3. **Use the pattern**: `it("<expected behavior> when <condition>")`
4. **Don't start with "should"** — `it("returns null for invalid input")` not `it("should return null...")`

### Structure Rules

1. **One assertion per test** (conceptual, not literal — multiple `expect` calls are fine if testing one behavior)
2. **No logic in tests** — no `if`, `for`, or `switch` in test code
3. **No test interdependencies** — each test sets up and tears down its own state
4. **Use `beforeEach` for shared setup, not `beforeAll`** — isolation matters more than speed
5. **Group related tests with nested `describe` blocks**

## Mocking Strategies

### When to Mock

| Mock | Don't Mock |
|------|-----------|
| External APIs and services | The unit under test |
| Database calls (in unit tests) | Simple utility functions |
| File system access | Data transformations |
| Timers and dates | Pure functions |
| Network requests | Collaborators (in integration tests) |
| Third-party services | Standard library methods |

### Mocking Hierarchy

Prefer lighter mocking techniques when possible:

1. **Stubs** — return a fixed value: `jest.fn().mockReturnValue(42)`
2. **Spies** — observe calls without changing behavior: `jest.spyOn(service, 'save')`
3. **Fakes** — lightweight in-memory implementation: `new InMemoryUserRepository()`
4. **Mocks** — full behavior replacement: `jest.mock('./database')`

### Rules

1. **Mock at the boundary** — mock the database client, not the repository method
2. **Don't mock what you don't own** — wrap third-party APIs in your own adapter, mock the adapter
3. **Reset mocks between tests** — use `afterEach(() => jest.restoreAllMocks())`
4. **Verify interactions sparingly** — prefer asserting on output over asserting mock was called

```typescript
// Good — mock at the boundary
const mockDb = { query: jest.fn().mockResolvedValue([{ id: 1, name: "Alice" }]) };
const repo = new UserRepository(mockDb);
const user = await repo.findById(1);
expect(user.name).toBe("Alice");

// Bad — mocking the unit under test
jest.spyOn(repo, "findById").mockResolvedValue({ id: 1, name: "Alice" });
```

### Test Doubles for Common Scenarios

```typescript
// Fixed time
beforeEach(() => {
  jest.useFakeTimers();
  jest.setSystemTime(new Date("2025-06-15T12:00:00Z"));
});
afterEach(() => jest.useRealTimers());

// API responses
const mockFetch = jest.fn().mockResolvedValue({
  ok: true,
  json: async () => ({ data: { id: 1 } }),
});
global.fetch = mockFetch;

// Environment variables
const originalEnv = process.env;
beforeEach(() => {
  process.env = { ...originalEnv, API_KEY: "test-key" };
});
afterEach(() => {
  process.env = originalEnv;
});
```

## Integration Tests

1. **Test module boundaries** — service calls repository, repository calls database
2. **Use a real (test) database** — SQLite in-memory or Docker containers
3. **Test API endpoints end-to-end** — use supertest or similar
4. **Seed data in `beforeEach`** — don't rely on database state from other tests
5. **Test error paths** — connection failures, timeouts, constraint violations

```typescript
describe("POST /api/users", () => {
  it("creates a user and returns 201", async () => {
    const response = await request(app)
      .post("/api/users")
      .send({ email: "test@example.com", name: "Test User" })
      .expect(201);

    expect(response.body.data).toMatchObject({
      email: "test@example.com",
      name: "Test User",
    });
    expect(response.body.data.id).toBeDefined();
  });

  it("returns 400 for invalid email", async () => {
    const response = await request(app)
      .post("/api/users")
      .send({ email: "not-an-email", name: "Test User" })
      .expect(400);

    expect(response.body.error.code).toBe("VALIDATION_ERROR");
  });
});
```

## E2E Tests

1. **Test critical user journeys only** — sign up, purchase, core workflow
2. **Use realistic data** — not "test123" or "foo bar"
3. **Use data-testid attributes** — `data-testid="submit-button"`, not CSS selectors
4. **Handle async operations explicitly** — wait for elements, not fixed timeouts
5. **Run in CI against a staging environment**
6. **Keep under 10 minutes total**

## Coverage Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Line coverage | 80%+ | Higher for critical modules |
| Branch coverage | 75%+ | Ensures conditional paths are tested |
| Function coverage | 85%+ | All public functions tested |
| Critical paths | 100% | Payment, auth, data integrity |

### Rules

1. **Coverage is a floor, not a ceiling** — don't write bad tests to hit a number
2. **Track coverage trends** — it should go up or stay flat, never down
3. **Enforce in CI** — fail the build if coverage drops below the threshold
4. **Exclude generated code** — don't count auto-generated files, configs, or type definitions

## Test File Organization

```
src/
  services/
    order.service.ts
    order.service.test.ts        # Unit tests colocated
  api/
    routes/
      users.route.ts
tests/
  integration/
    api/
      users.test.ts              # Integration tests separate
  e2e/
    flows/
      checkout.test.ts           # E2E tests separate
  fixtures/
    users.json                   # Shared test data
  helpers/
    test-db.ts                   # Shared test utilities
```

## Anti-patterns

- **Testing implementation details** — test behavior, not how it's implemented
- **Snapshot overuse** — snapshots are brittle; use them for serializable output, not UI
- **Flaky tests** — fix or delete them; a flaky test is worse than no test
- **Test setup duplication** — extract to helper functions or fixtures
- **Ignoring test failures** — a skipped test is a known bug you're choosing to keep
- **100% coverage obsession** — diminishing returns past 85%; focus on meaningful tests
