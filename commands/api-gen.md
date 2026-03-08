---
model: sonnet
description: Generate REST API endpoints with routes, validation, error handling, and tests
---

Generate production-quality REST API endpoints from a description provided in `$ARGUMENTS`.

## Step 1 — Understand the Requirements

Parse `$ARGUMENTS` to determine:
- **Resource name** (e.g., "users", "products", "orders")
- **Operations** needed (CRUD by default, or specific operations if stated)
- **Fields and types** (if specified, otherwise infer reasonable defaults)
- **Relationships** to other resources (if mentioned)
- **Authentication requirements** (if mentioned)

If `$ARGUMENTS` is vague (e.g., just "users"), generate a standard CRUD API with sensible defaults and ask the user to confirm the field list before writing code.

## Step 2 — Detect the Project's Stack

Search the project to determine:
1. **Framework:** Express, Fastify, Koa, NestJS, Django REST Framework, Flask, FastAPI, Gin, Echo, etc.
2. **Language:** TypeScript, JavaScript, Python, Go, etc.
3. **Database/ORM:** Prisma, TypeORM, Sequelize, SQLAlchemy, Django ORM, GORM, etc.
4. **Validation library:** Zod, Joi, class-validator, Pydantic, marshmallow, etc.
5. **Project structure:** Where do routes, controllers, models, and tests live?
6. **Existing patterns:** Read 1-2 existing route files to match the project's conventions exactly.

If no existing backend framework is found, ask the user which stack to use. Do not assume.

## Step 3 — Design the API

Create a specification before writing any code:

```
## API Design: [Resource]

Base path: /api/[resource]

| Method | Path            | Description          | Auth | Status Codes       |
|--------|-----------------|----------------------|------|--------------------|
| GET    | /               | List all (paginated) | Yes  | 200, 401           |
| GET    | /:id            | Get one by ID        | Yes  | 200, 401, 404      |
| POST   | /               | Create new           | Yes  | 201, 400, 401, 409 |
| PUT    | /:id            | Update by ID         | Yes  | 200, 400, 401, 404 |
| DELETE | /:id            | Delete by ID         | Yes  | 204, 401, 404      |

### Request/Response Shapes
(show the JSON schema for request body and response body)
```

Present this design to the user and ask for confirmation before generating code.

## Step 4 — Generate the Code

Create files following the project's existing structure. Generate:

### Model / Schema
- Database model or schema definition with all fields, types, and constraints
- Indexes for commonly queried fields
- Timestamps (createdAt, updatedAt) if the project uses them

### Validation
- Input validation for create and update operations
- Validate required fields, types, string lengths, number ranges, email format, etc.
- Use the project's existing validation library
- Separate create vs. update schemas (update fields are typically optional)

### Controller / Handler
- One handler function per endpoint
- Proper HTTP status codes (201 for create, 204 for delete, 404 for not found)
- Error handling: catch database errors, validation errors, and unexpected errors
- Pagination on list endpoints (offset/limit or cursor-based, matching project convention)
- Filtering and sorting if reasonable for the resource

### Routes
- Route definitions connecting HTTP methods + paths to handlers
- Middleware for authentication (if the project uses it)
- Middleware for validation (validate before hitting the handler)

### Error Handling
- Consistent error response format matching existing project patterns:
  ```json
  {
    "error": {
      "code": "NOT_FOUND",
      "message": "User with ID 123 not found"
    }
  }
  ```
- Map database constraint violations to user-friendly messages
- Never leak stack traces or internal details in error responses

## Step 5 — Generate Tests

Write tests for every endpoint:

- **Success cases:** Create, read, update, delete with valid data
- **Validation errors:** Missing required fields, invalid types, out-of-range values
- **Not found:** Operations on non-existent IDs
- **Duplicate handling:** Creating a resource that conflicts with a unique constraint
- **Pagination:** Verify limit/offset or cursor behavior
- **Authentication:** Requests without auth return 401 (if auth is required)

Use the project's existing test framework and patterns. Place test files where the project convention dictates.

## Step 6 — Verify

1. Run the linter/type checker to confirm no errors.
2. Run the test suite (including new tests).
3. If tests fail, fix them before reporting.

## Step 7 — Report

```
## API Generation Report

**Resource:** [name]
**Endpoints:** [count]

### Files Created
- (path) — model/schema
- (path) — validation
- (path) — controller/handlers
- (path) — routes
- (path) — tests

### Endpoints
| Method | Path | Description |
|--------|------|-------------|
| ...    | ...  | ...         |

### Tests Written
- [count] test cases covering success, validation, not-found, and auth scenarios

### Next Steps
- Add business-specific validation rules
- Implement authorization (who can access what)
- Add rate limiting if this is a public API
- Update API documentation
```
