# API Design

> REST API conventions: URL structure, HTTP methods, status codes, pagination, filtering, error responses, and versioning.

## URL Structure

1. **Use nouns, not verbs** — the HTTP method provides the verb
2. **Use plural resource names** — `/users`, `/orders`, `/products`
3. **Use kebab-case for multi-word resources** — `/order-items`, not `/orderItems`
4. **Nest resources to show relationships** — max 2 levels deep
5. **Use query parameters for filtering, not path segments**

```
# Good
GET    /api/v1/users
GET    /api/v1/users/123
GET    /api/v1/users/123/orders
POST   /api/v1/users
PATCH  /api/v1/users/123
DELETE /api/v1/users/123

# Bad
GET    /api/v1/getUsers
GET    /api/v1/user/123
POST   /api/v1/users/123/orders/456/items/789/notes   # too deeply nested
```

## HTTP Methods

| Method | Purpose | Idempotent | Request Body | Success Code |
|--------|---------|:----------:|:------------:|:------------:|
| GET | Read resource(s) | Yes | No | 200 |
| POST | Create resource | No | Yes | 201 |
| PUT | Replace resource entirely | Yes | Yes | 200 |
| PATCH | Partial update | No* | Yes | 200 |
| DELETE | Remove resource | Yes | No | 204 |

*PATCH is not guaranteed idempotent, but should be designed to be when possible.

### Rules

1. **GET requests must be safe** — no side effects, no state changes
2. **POST for creation** — return the created resource with `Location` header
3. **Use PATCH over PUT** — partial updates are more practical than full replacement
4. **DELETE should be idempotent** — deleting a non-existent resource returns 204, not 404

## Status Codes

Use the correct status code. When in doubt, refer to this table:

### Success (2xx)

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST that creates a resource |
| 204 | No Content | Successful DELETE, or PUT/PATCH with no response body |

### Client Errors (4xx)

| Code | Meaning | When to Use |
|------|---------|-------------|
| 400 | Bad Request | Malformed JSON, invalid field values, validation errors |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but lacks permission |
| 404 | Not Found | Resource does not exist |
| 409 | Conflict | Duplicate resource, state conflict |
| 422 | Unprocessable Entity | Valid JSON but fails business rules |
| 429 | Too Many Requests | Rate limit exceeded |

### Server Errors (5xx)

| Code | Meaning | When to Use |
|------|---------|-------------|
| 500 | Internal Server Error | Unexpected server failure |
| 502 | Bad Gateway | Upstream service failure |
| 503 | Service Unavailable | Server overloaded or in maintenance |

## Error Responses

Use a consistent error format across all endpoints:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed.",
    "details": [
      {
        "field": "email",
        "message": "Must be a valid email address.",
        "code": "INVALID_FORMAT"
      },
      {
        "field": "age",
        "message": "Must be at least 18.",
        "code": "MIN_VALUE"
      }
    ]
  }
}
```

### Rules

1. **Always include a machine-readable error code** — `VALIDATION_ERROR`, `NOT_FOUND`, `RATE_LIMITED`
2. **Include a human-readable message** — suitable for developer debugging
3. **Never expose internal errors** — no stack traces, SQL queries, or file paths in production
4. **Field-level errors in `details` array** — for validation errors, specify which field failed

## Pagination

Use cursor-based pagination for large datasets, offset-based for simple cases.

### Offset-based (simple)

```
GET /api/v1/users?page=2&per_page=25

Response:
{
  "data": [ ... ],
  "pagination": {
    "page": 2,
    "per_page": 25,
    "total": 150,
    "total_pages": 6
  }
}
```

### Cursor-based (scalable)

```
GET /api/v1/users?limit=25&cursor=eyJpZCI6MTAwfQ

Response:
{
  "data": [ ... ],
  "pagination": {
    "limit": 25,
    "has_more": true,
    "next_cursor": "eyJpZCI6MTI1fQ"
  }
}
```

### Rules

1. **Default page size: 25, max: 100** — prevent clients from requesting unlimited data
2. **Always return pagination metadata** — clients need to know if there are more pages
3. **Use cursor-based for real-time data or large tables** — offset-based breaks with concurrent writes

## Filtering and Sorting

```
# Filter by field values
GET /api/v1/users?status=active&role=admin

# Date ranges
GET /api/v1/orders?created_after=2025-01-01&created_before=2025-12-31

# Search
GET /api/v1/products?q=keyboard

# Sort (prefix with - for descending)
GET /api/v1/users?sort=created_at
GET /api/v1/users?sort=-updated_at

# Combine everything
GET /api/v1/orders?status=shipped&sort=-created_at&page=1&per_page=25
```

### Rules

1. **Use `snake_case` for query parameter names**
2. **Support multiple sort fields** — `?sort=-created_at,name`
3. **Validate all filter parameters** — return 400 for unknown fields
4. **Document allowed filter fields per endpoint**

## Request and Response Conventions

1. **Use `snake_case` for all JSON keys** — `created_at`, `first_name`, `order_id`
2. **Use ISO 8601 for dates** — `2025-06-15T14:30:00Z`
3. **Use UUIDs or opaque strings for IDs** — avoid exposing auto-increment integers
4. **Wrap collections in a `data` key** — `{ "data": [...] }`, not a bare array
5. **Include `created_at` and `updated_at` in all resources**
6. **Use `null` for absent optional fields** — don't omit them entirely

```json
{
  "data": {
    "id": "usr_a1b2c3d4",
    "email": "user@example.com",
    "first_name": "Jane",
    "last_name": "Doe",
    "role": "admin",
    "avatar_url": null,
    "created_at": "2025-06-15T14:30:00Z",
    "updated_at": "2025-06-15T14:30:00Z"
  }
}
```

## Versioning

1. **Use URL path versioning** — `/api/v1/`, `/api/v2/`
2. **Increment the major version only for breaking changes**
3. **Support the previous version for at least 6 months after deprecation**
4. **Return a `Deprecation` header on deprecated endpoints**
5. **Document migration guides between versions**

## Authentication

1. **Use Bearer tokens in the `Authorization` header** — `Authorization: Bearer <token>`
2. **Never pass tokens in query parameters** — they end up in server logs
3. **Return 401 for missing/invalid tokens, 403 for insufficient permissions**
4. **Include rate limit headers** — `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

## Anti-patterns

- **Verbs in URLs** — use HTTP methods instead
- **Returning 200 with error body** — use proper status codes
- **Nested resources deeper than 2 levels** — flatten with query parameters
- **Inconsistent naming** — pick `snake_case` or `camelCase` and stick with it
- **Missing pagination on list endpoints** — always paginate collections
- **Exposing internal IDs** — use prefixed opaque IDs like `usr_`, `ord_`, `prod_`
