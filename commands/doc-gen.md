---
model: haiku
description: Generate documentation — JSDoc, docstrings, README sections, or API docs
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Edit
  - Write
---

Generate documentation for the code specified in `$ARGUMENTS`. The argument may be a file path, a directory, a function name, or a keyword like "readme" or "api".

## Step 1 — Determine Documentation Type

Parse `$ARGUMENTS` to figure out what kind of documentation is needed:

| Argument contains | Action |
|---|---|
| A file path (e.g., `src/auth.ts`) | Add inline JSDoc/docstrings to that file |
| A directory (e.g., `src/utils/`) | Document all exported members in that directory |
| `readme` or `README` | Generate or update the project README |
| `api` | Generate API reference documentation |
| A function/class name | Find and document that specific symbol |
| Nothing | Ask the user what they want documented |

## Step 2a — Inline Documentation (JSDoc / Docstrings)

For each exported function, class, method, type, and constant in the target file(s):

**JavaScript/TypeScript — JSDoc:**
```typescript
/**
 * Brief one-line description of what this function does.
 *
 * Longer explanation if the behavior is non-obvious, including
 * algorithm notes, performance characteristics, or caveats.
 *
 * @param name - Description of the parameter
 * @returns Description of the return value
 * @throws {ErrorType} When and why this error is thrown
 * @example
 * const result = myFunction("input");
 * // result === "expected output"
 */
```

**Python — Docstrings (Google style):**
```python
def my_function(name: str) -> str:
    """Brief one-line description.

    Longer explanation if needed.

    Args:
        name: Description of the parameter.

    Returns:
        Description of the return value.

    Raises:
        ValueError: When and why this error is raised.

    Example:
        >>> my_function("input")
        'expected output'
    """
```

Rules:
- Do not state the obvious. `@param id - The id` is useless. Write `@param id - Unique identifier used to look up the user record`.
- Document **why**, not just **what**, when the purpose is non-obvious.
- Include at least one `@example` for public API functions.
- Document thrown errors and edge-case behavior.
- Preserve existing documentation — only add or improve, never remove unless it is incorrect.

## Step 2b — README Generation

If generating a README, include these sections:

1. **Project title and badges** (build status, npm version, license if detectable)
2. **One-paragraph description** — what the project does and who it is for
3. **Quick start** — install and run in under 5 commands
4. **Usage** — primary use cases with code examples
5. **API overview** — table of main exports with one-line descriptions
6. **Configuration** — environment variables, config files
7. **Development** — how to set up locally, run tests, and contribute
8. **License** — detected from LICENSE file or package.json

Detect real values from the codebase (package name, scripts, entry points). Do not invent placeholder values.

## Step 2c — API Reference

If generating API documentation:

1. Find all route definitions (Express, Fastify, Django, Flask, etc.)
2. For each endpoint, document:
   - HTTP method and path
   - Description of what it does
   - Request parameters (path, query, body) with types
   - Response shape with status codes
   - Authentication requirements
   - Example request and response

Format as a Markdown document with a table of contents.

## Step 3 — Write the Documentation

Apply the documentation using the Edit tool for inline docs (to preserve surrounding code) or the Write tool for standalone doc files.

## Step 4 — Summary

List all files modified or created and the number of documentation blocks added. If any functions were skipped (e.g., trivial one-liners or private internals), note them and explain why.
