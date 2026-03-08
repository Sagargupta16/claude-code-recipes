# TypeScript Strict

> Strict TypeScript conventions: strict mode config, no-any rules, utility types, discriminated unions, branded types, and error handling patterns.

## Strict Mode Configuration

Always enable strict mode. Use this `tsconfig.json` base:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    "exactOptionalPropertyTypes": true,
    "verbatimModuleSyntax": true
  }
}
```

### What `strict: true` Enables

- `strictNullChecks` — `null` and `undefined` are their own types
- `strictFunctionTypes` — function parameter types are checked strictly
- `strictBindCallApply` — `bind`, `call`, `apply` are typed correctly
- `strictPropertyInitialization` — class properties must be initialized
- `noImplicitAny` — no implicit `any` types
- `noImplicitThis` — `this` must have an explicit type
- `alwaysStrict` — emit `"use strict"` in every file

## No `any` Rules

1. **Never use `any`** — use `unknown` when the type is truly unknown
2. **Use `unknown` and narrow** — type guards, `instanceof`, `typeof`
3. **Use generics for flexible types** — `function parse<T>(input: string): T`
4. **Use `Record<string, unknown>` over `object`** — more explicit
5. **Suppress with `// @ts-expect-error` (not `// @ts-ignore`)** — `@ts-expect-error` fails if the error is fixed

```typescript
// Bad
function parse(data: any): any {
  return JSON.parse(data);
}

// Good
function parse(data: string): unknown {
  return JSON.parse(data);
}

// Good — with type guard
function isUser(value: unknown): value is User {
  return (
    typeof value === "object" &&
    value !== null &&
    "id" in value &&
    "email" in value
  );
}

const data: unknown = parse(input);
if (isUser(data)) {
  console.log(data.email); // typed as User
}
```

## Utility Types

Use built-in utility types instead of manual type construction:

| Utility | Use Case | Example |
|---------|----------|---------|
| `Partial<T>` | All properties optional | Update DTOs: `Partial<User>` |
| `Required<T>` | All properties required | Override optionals |
| `Pick<T, K>` | Select specific properties | `Pick<User, "id" \| "name">` |
| `Omit<T, K>` | Remove specific properties | `Omit<User, "password">` |
| `Readonly<T>` | All properties readonly | Immutable state |
| `Record<K, V>` | Object with known key/value types | `Record<string, number>` |
| `Extract<T, U>` | Extract union members matching U | `Extract<Status, "active" \| "pending">` |
| `Exclude<T, U>` | Remove union members matching U | `Exclude<Status, "deleted">` |
| `NonNullable<T>` | Remove null/undefined | `NonNullable<string \| null>` -> `string` |
| `ReturnType<T>` | Extract return type of function | `ReturnType<typeof fetchUser>` |
| `Awaited<T>` | Unwrap Promise type | `Awaited<Promise<User>>` -> `User` |

```typescript
// Compose utility types for DTOs
interface User {
  id: string;
  email: string;
  name: string;
  password: string;
  role: "admin" | "user";
  createdAt: Date;
}

type CreateUserInput = Omit<User, "id" | "createdAt">;
type UpdateUserInput = Partial<Omit<User, "id" | "createdAt">>;
type PublicUser = Omit<User, "password">;
```

## Discriminated Unions

Use discriminated unions for type-safe state management and variant types:

```typescript
// Define a discriminated union with a literal "type" field
type ApiResult<T> =
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: Error };

function renderResult<T>(result: ApiResult<T>) {
  switch (result.status) {
    case "loading":
      return <Spinner />;
    case "success":
      return <DataView data={result.data} />;  // data is available
    case "error":
      return <ErrorView error={result.error} />;  // error is available
  }
}
```

### Rules

1. **Use a literal `type` or `kind` field as the discriminant**
2. **Handle all variants** — enable `noFallthroughCasesInSwitch`
3. **Use exhaustive checks** — add a `never` default case

```typescript
// Exhaustive switch — compile error if a variant is missed
function assertNever(value: never): never {
  throw new Error(`Unhandled variant: ${JSON.stringify(value)}`);
}

function handleEvent(event: AppEvent) {
  switch (event.type) {
    case "click":
      return handleClick(event);
    case "keypress":
      return handleKeypress(event);
    default:
      return assertNever(event); // Compile error if new variant is added
  }
}
```

### Common Patterns

```typescript
// Action types for reducers
type Action =
  | { type: "SET_USER"; payload: User }
  | { type: "SET_ERROR"; payload: string }
  | { type: "RESET" };

// API responses
type Response =
  | { ok: true; data: User[] }
  | { ok: false; error: string };

// Form field types
type FormField =
  | { kind: "text"; value: string; maxLength?: number }
  | { kind: "number"; value: number; min?: number; max?: number }
  | { kind: "select"; value: string; options: string[] }
  | { kind: "checkbox"; value: boolean };
```

## Branded Types

Use branded types to prevent mixing semantically different values that share a primitive type:

```typescript
// Define branded types
type UserId = string & { readonly __brand: "UserId" };
type OrderId = string & { readonly __brand: "OrderId" };
type Email = string & { readonly __brand: "Email" };

// Constructor functions with validation
function UserId(id: string): UserId {
  if (!id.startsWith("usr_")) throw new Error("Invalid user ID");
  return id as UserId;
}

function Email(value: string): Email {
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
    throw new Error("Invalid email");
  }
  return value as Email;
}

// Type safety — can't mix them up
function getUser(id: UserId): Promise<User> { /* ... */ }
function getOrder(id: OrderId): Promise<Order> { /* ... */ }

const userId = UserId("usr_abc123");
const orderId = OrderId("ord_xyz789");

getUser(userId);    // OK
getUser(orderId);   // Compile error — OrderId is not UserId
```

## Error Handling Patterns

### Result Type

Use a Result type instead of throwing exceptions for expected errors:

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

// Helper constructors
function ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

function err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

// Usage
async function createUser(input: CreateUserInput): Promise<Result<User, CreateUserError>> {
  const existing = await db.findByEmail(input.email);
  if (existing) {
    return err({ code: "EMAIL_EXISTS", message: "Email already registered" });
  }

  const user = await db.create(input);
  return ok(user);
}

// Caller handles both cases
const result = await createUser(input);
if (result.ok) {
  console.log("Created:", result.value.id);
} else {
  console.error("Failed:", result.error.message);
}
```

### Custom Error Classes

```typescript
class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 500,
    public readonly cause?: unknown,
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} not found: ${id}`, "NOT_FOUND", 404);
  }
}

class ValidationError extends AppError {
  constructor(
    message: string,
    public readonly fields: Record<string, string>,
  ) {
    super(message, "VALIDATION_ERROR", 400);
  }
}
```

### Rules

1. **Use Result types for expected failures** — validation, not-found, business rules
2. **Throw exceptions for unexpected failures** — programming errors, system failures
3. **Type your errors** — don't use `catch (e: any)`
4. **Use `cause` for error chains** — `new Error("Failed to save", { cause: originalError })`

## Type Narrowing Techniques

```typescript
// typeof
function format(value: string | number): string {
  if (typeof value === "string") return value.trim();
  return value.toFixed(2);
}

// instanceof
function handleError(error: unknown): string {
  if (error instanceof AppError) return error.code;
  if (error instanceof Error) return error.message;
  return String(error);
}

// in operator
function getArea(shape: Circle | Rectangle): number {
  if ("radius" in shape) return Math.PI * shape.radius ** 2;
  return shape.width * shape.height;
}

// Custom type guard
function isDefined<T>(value: T | null | undefined): value is T {
  return value !== null && value !== undefined;
}

const users = [getUser(1), getUser(2), null].filter(isDefined);
// type: User[]
```

## Anti-patterns

- **Using `any` to silence type errors** — find the correct type or use `unknown`
- **Type assertions (`as`) without validation** — narrow with type guards instead
- **Enums** — prefer union types of string literals for better tree-shaking
- **`Boolean` constructor as filter** — `.filter(Boolean)` loses type narrowing; use `.filter(isDefined)`
- **Ignoring `strictNullChecks`** — the single most valuable strict check
- **Overusing `!` non-null assertion** — it lies to the compiler; handle the null case
- **Complex conditional types in application code** — keep them in library/utility code
