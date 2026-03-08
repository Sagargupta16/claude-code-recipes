# CLAUDE.md — Monorepo Template

> Copy this file to your project root as `CLAUDE.md` and customize. Create package-specific CLAUDE.md files as needed.

## Project

<!-- Brief description of the monorepo and its packages -->
[Project name] is a monorepo containing [description of packages — e.g., "a web app, a mobile app, and shared libraries"]. Managed with [Turborepo / Nx / pnpm workspaces / Lerna].

## Tech Stack

- **Monorepo tool**: [Turborepo / Nx / pnpm workspaces]
- **Package manager**: [pnpm / npm / yarn]
- **Language**: [TypeScript 5.x]
- **Shared config**: [ESLint, Prettier, tsconfig — in root]

## Packages

| Package | Path | Description | Port |
|---------|------|-------------|:----:|
| `@project/web` | `apps/web` | Next.js web application | 3000 |
| `@project/api` | `apps/api` | Express API server | 4000 |
| `@project/mobile` | `apps/mobile` | React Native mobile app | — |
| `@project/ui` | `packages/ui` | Shared component library | — |
| `@project/db` | `packages/db` | Database client and schema | — |
| `@project/config` | `packages/config` | Shared configuration | — |
| `@project/utils` | `packages/utils` | Shared utility functions | — |
| `@project/types` | `packages/types` | Shared TypeScript types | — |

## Commands

### Root-level (runs across all packages)

```bash
# Install all dependencies
pnpm install

# Run all dev servers
pnpm dev

# Build all packages (in dependency order)
pnpm build

# Run all tests
pnpm test

# Lint all packages
pnpm lint

# Type check all packages
pnpm typecheck

# Format all files
pnpm format
```

### Package-specific

```bash
# Run a command in a specific package
pnpm --filter @project/web dev
pnpm --filter @project/api test
pnpm --filter @project/ui build

# Run a command in all packages that match a pattern
pnpm --filter "@project/apps/*" build
pnpm --filter "@project/packages/*" test

# Add a dependency to a specific package
pnpm --filter @project/web add react-query

# Add a shared dependency to the root
pnpm add -w -D typescript
```

## Project Structure

```
project-root/
  CLAUDE.md                 # This file — root config
  turbo.json                # Turborepo pipeline configuration
  pnpm-workspace.yaml       # Workspace package definitions
  package.json              # Root scripts and shared devDependencies
  apps/
    web/
      CLAUDE.md             # Web app-specific conventions
      package.json
      src/
    api/
      CLAUDE.md             # API-specific conventions
      package.json
      src/
    mobile/
      package.json
      src/
  packages/
    ui/
      CLAUDE.md             # UI library conventions
      package.json
      src/
    db/
      package.json
      src/
    config/
      eslint/               # Shared ESLint config
      tsconfig/              # Shared TypeScript configs
      prettier/              # Shared Prettier config
    utils/
      package.json
      src/
    types/
      package.json
      src/
```

## Dependency Rules

### Internal dependencies

- Apps (`apps/*`) can depend on packages (`packages/*`)
- Packages can depend on other packages
- Apps must NOT depend on other apps
- Avoid circular dependencies between packages

```json
// apps/web/package.json
{
  "dependencies": {
    "@project/ui": "workspace:*",
    "@project/utils": "workspace:*",
    "@project/types": "workspace:*"
  }
}
```

### Import conventions

```typescript
// Good — import from the package
import { Button } from "@project/ui";
import { formatDate } from "@project/utils";
import type { User } from "@project/types";

// Bad — reach into another package's internals
import { Button } from "@project/ui/src/components/Button";
import { helper } from "../../packages/utils/src/helper";
```

## Conventions

### Shared across all packages

- TypeScript strict mode in every package
- Shared ESLint and Prettier configs (extend from `@project/config`)
- All packages export from `src/index.ts` — no deep imports
- Semantic versioning for published packages
- All inter-package deps use `workspace:*`

### Adding a new package

1. Create directory in `packages/` (library) or `apps/` (application)
2. Add `package.json` with `@project/` scope
3. Extend shared tsconfig: `"extends": "@project/config/tsconfig/base.json"`
4. Extend shared ESLint: `"extends": ["@project/config/eslint"]`
5. Add to `turbo.json` pipeline if it has custom build steps
6. Add a CLAUDE.md if it has specific conventions

### Build pipeline

Turborepo handles the build order based on the dependency graph:

```
packages/types    (no deps — builds first)
packages/utils    (depends on types)
packages/db       (depends on types)
packages/ui       (depends on types, utils)
apps/web          (depends on ui, utils, db, types)
apps/api          (depends on utils, db, types)
```

Never manually specify build order — let Turborepo resolve it.

## Testing

- Each package has its own test configuration
- Run all tests: `pnpm test` (from root)
- Run one package's tests: `pnpm --filter @project/web test`
- Shared test utilities in `packages/config/test-utils/`
- Integration tests that cross package boundaries go in `tests/integration/`

## CI/CD

The CI pipeline leverages Turborepo's caching:

1. `pnpm install` — install all dependencies
2. `turbo lint` — lint changed packages only
3. `turbo typecheck` — type check changed packages only
4. `turbo test` — test changed packages and their dependents
5. `turbo build` — build changed packages in dependency order

Turborepo's remote cache (`--remote-cache`) skips unchanged packages in CI.

## Do NOT

- Import from another package's `src/` directory — use the package export
- Add dependencies to the root `package.json` unless they are truly shared dev tools
- Create circular dependencies between packages
- Skip `workspace:*` for internal deps — never pin internal packages to a version
- Put application-specific code in shared packages
- Modify shared config without team discussion
