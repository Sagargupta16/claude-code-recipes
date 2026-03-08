# CLAUDE.md — Team Project Template

> Copy this file to your project root as `CLAUDE.md` and customize each section.

## Project

<!-- Brief description of the project, its purpose, and target users -->
[Project name] is a [web app / API / CLI / library] for [target users] that [core functionality]. It is maintained by the [team name] team.

## Tech Stack

- **Language**: [TypeScript 5.x / Python 3.12 / etc.]
- **Framework**: [Next.js 15 / Django 5 / Express / etc.]
- **Database**: [PostgreSQL 16 / MongoDB 7 / etc.]
- **ORM**: [Prisma / Drizzle / SQLAlchemy / etc.]
- **Auth**: [NextAuth / Auth0 / custom JWT / etc.]
- **Styling**: [Tailwind CSS 4 / CSS Modules / etc.]
- **Testing**: [Vitest / Jest / Pytest / etc.]
- **CI/CD**: [GitHub Actions / GitLab CI / etc.]
- **Hosting**: [Vercel / AWS / GCP / etc.]

## Commands

```bash
# Install
[npm install / pip install -e ".[dev]"]

# Dev server
[npm run dev / python manage.py runserver]

# Run all tests
[npm test / pytest]

# Run single test file
[npm test -- path/to/file.test.ts / pytest path/to/test_file.py]

# Run tests with coverage
[npm test -- --coverage / pytest --cov]

# Lint
[npm run lint / ruff check .]

# Format
[npm run format / ruff format .]

# Type check
[npx tsc --noEmit / mypy .]

# Build
[npm run build / python -m build]

# Database migrations
[npx prisma migrate dev / alembic upgrade head]

# Seed database
[npm run db:seed / python manage.py seed]
```

## Project Structure

```
src/
  app/               # Next.js app router pages and layouts
  components/
    ui/              # Reusable UI primitives (Button, Input, Modal)
    features/        # Feature-specific components (UserProfile, OrderList)
  lib/               # Shared utilities, constants, and helpers
  services/          # Business logic and external API clients
  hooks/             # Custom React hooks
  types/             # Shared TypeScript type definitions
  styles/            # Global styles and theme configuration
prisma/              # Database schema and migrations
tests/
  integration/       # API endpoint tests
  e2e/               # End-to-end browser tests
public/              # Static assets
```

## Coding Conventions

### General

- Use TypeScript strict mode — no `any`, no `@ts-ignore`
- Prefer `const` over `let` — never use `var`
- Use early returns to reduce nesting
- Maximum function length: 40 lines — extract helpers if longer
- Maximum file length: 300 lines — split into modules if longer

### Naming

- **Files**: `kebab-case.ts` for utilities, `PascalCase.tsx` for components
- **Functions**: `camelCase` — verb prefix: `getUser`, `createOrder`, `isValid`
- **Types/Interfaces**: `PascalCase` — noun: `User`, `OrderItem`, `ApiResponse`
- **Constants**: `UPPER_SNAKE_CASE` — `MAX_RETRIES`, `API_BASE_URL`
- **Boolean variables**: `is`/`has`/`should` prefix: `isLoading`, `hasPermission`

### React

- Functional components only — no class components
- Named exports for components — default exports only for pages
- Props interface above the component: `interface ComponentNameProps { ... }`
- Colocate component, test, and styles in the same directory
- Use React Server Components by default — add `"use client"` only when needed

### API

- RESTful endpoints under `/api/v1/`
- Use `snake_case` for JSON request/response keys
- Always validate request bodies with Zod schemas
- Return consistent error format: `{ error: { code, message, details } }`
- All endpoints require authentication unless explicitly public

### Database

- Use the ORM for all database access — no raw SQL in application code
- Name migrations descriptively: `add_avatar_url_to_users`
- Always include `created_at` and `updated_at` timestamps
- Use soft deletes (`deleted_at`) for user-facing data

### Testing

- Test file location: next to the source file (`user.service.test.ts`)
- Use AAA pattern: Arrange, Act, Assert
- Minimum 80% line coverage — 100% for critical paths (auth, payments)
- Mock external services — never call real APIs in tests
- Use factories for test data — no hardcoded objects in tests

## Git Workflow

- **Branch naming**: `feat/PROJ-123-short-description`, `fix/PROJ-456-bug-name`
- **Commit format**: Conventional Commits — `feat(scope): description`
- **PR process**: Create PR -> CI passes -> 1 review required -> squash merge
- **Protected branches**: `main` requires PR + approval + passing CI
- **Release**: Tag `main` with `vX.Y.Z` after merge

## CI/CD Pipeline

The CI pipeline runs on every PR:

1. **Lint** — ESLint + Prettier check
2. **Type check** — `tsc --noEmit`
3. **Unit tests** — Vitest with coverage report
4. **Integration tests** — Against test database
5. **Build** — Production build must succeed

Deployment:
- `main` branch auto-deploys to **staging**
- Tagged releases (`v*`) deploy to **production**
- Preview deployments for every PR

## Environment Variables

Required environment variables (see `.env.example`):

- `DATABASE_URL` — PostgreSQL connection string
- `NEXTAUTH_SECRET` — Auth session encryption key
- `NEXTAUTH_URL` — Application URL
- `[SERVICE]_API_KEY` — External service API keys

Never commit `.env` files. Use `.env.example` as a template.

## Do NOT

- Use `any` type — use `unknown` and type guards
- Commit directly to `main` — always use a branch and PR
- Skip tests — every feature and bug fix needs tests
- Use `console.log` for error handling — use the logger service
- Store secrets in code — use environment variables
- Write raw SQL — use the ORM
- Import from barrel files (`index.ts`) in the same package — import directly
- Use `moment.js` — use `date-fns` instead
- Nest ternaries — use early returns or `if/else`

## Common Gotchas

- The ORM client is a singleton in `src/lib/db.ts` — import from there, don't create new instances
- Auth middleware runs before route handlers — `req.user` is always available in protected routes
- The test database is reset between test suites — don't depend on data from other tests
- Environment variables are validated at startup — missing vars crash immediately (this is intentional)
