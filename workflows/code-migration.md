# Workflow: Code Migration

> Migration cycle: audit, plan, migrate step by step, test, and validate.

Use this workflow when upgrading framework versions, switching libraries, migrating to a new language, or restructuring a codebase.

---

## Overview

| Phase | Mode | Recipes Used | Time |
|-------|------|-------------|------|
| 1. Audit | Plan | Researcher subagent | 10-20 min |
| 2. Plan | Plan | — | 10-15 min |
| 3. Prepare | Code | — | 5-15 min |
| 4. Migrate | Code | `/migrate`, subagents | 30-120 min |
| 5. Test | Code | test-runner subagent | 10-30 min |
| 6. Validate | Code | `/code-review`, `/security-audit` | 10-15 min |

---

## Step 1: Audit

**Mode**: Plan

Understand the current state before changing anything.

**Prompt**:
```
I need to migrate [what] from [old version/library] to [new version/library].

Audit the codebase and report:
1. All files that use [old library/pattern] (with line counts)
2. Which APIs/features we use from [old library]
3. Breaking changes between [old] and [new] that affect us
4. Dependencies that might also need updating
5. Areas of highest risk (most complex usage)
```

**For framework upgrades**:
```
Use the researcher subagent to audit our usage of [framework] v[old].
Find every import, API call, and pattern that changes in v[new].
Produce a report grouped by: breaking changes, deprecations, and new features we should adopt.
```

**Output**: A clear list of everything that needs to change, ordered by risk.

---

## Step 2: Plan

**Mode**: Plan

Create a step-by-step migration plan based on the audit.

**Prompt**:
```
Based on the audit, create a migration plan with these properties:
1. Each step is independently deployable (no half-migrated states)
2. Steps are ordered by dependency (migrate foundations first)
3. Each step includes a rollback strategy
4. Estimate the risk level (low/medium/high) for each step
5. Identify which steps can be done in parallel

Format as a numbered checklist I can track.
```

**Key principles**:
- **Incremental**: each step leaves the codebase in a working state
- **Testable**: each step can be verified before moving on
- **Reversible**: each step can be rolled back if needed
- **Smallest possible**: break large steps into smaller ones

---

## Step 3: Prepare

**Mode**: Code

Set up the migration environment before touching production code.

**Prompt**:
```
Before starting the migration:
1. Create a migration branch: feat/migrate-[library]-v[version]
2. Update package.json / requirements.txt with the new version
3. Install the new dependencies
4. Set up any compatibility shims or codemods the new version provides
5. Run the build to see initial errors (don't fix yet — just inventory them)
```

**For major version upgrades**:
```
Check if [library] provides an official codemod or migration tool.
If so, run it first to handle mechanical changes, then we'll review the output.
```

---

## Step 4: Migrate

**Mode**: Code

Execute the migration plan step by step. Do not try to migrate everything at once.

**Prompt for each step**:
```
/migrate
```

Or be more specific:
```
Execute migration step [N]: [description from the plan]

- Update [specific files/patterns]
- Verify the build passes after this step
- Run affected tests
- Note anything unexpected for review
```

**For large migrations**, delegate to subagents:
```
Use the frontend-dev subagent to migrate all React components from
[old pattern] to [new pattern]. Process one component at a time,
verifying each builds correctly before moving to the next.
```

**Tips**:
- Migrate one module at a time, not the entire codebase
- Commit after each successful step (easy rollback)
- If a step is harder than expected, stop and re-plan
- Keep a running list of unexpected issues

---

## Step 5: Test

**Mode**: Code

Run the full test suite and fix any failures introduced by the migration.

**Prompt**:
```
Run the complete test suite. For any failures:
1. Determine if the failure is due to the migration or a pre-existing issue
2. Fix migration-related failures
3. Update test utilities/helpers that depend on the old API
4. Flag pre-existing failures separately

Report: total tests, passed, failed (migration), failed (pre-existing).
```

**Recipes to use**:
- Test-runner subagent — run tests and fix failures
- `/test-gen` — generate tests for newly migrated code if coverage dropped

**Also test manually**:
```
List the 5 most critical user flows that could be affected by this migration.
I'll test them manually.
```

---

## Step 6: Validate

**Mode**: Code

Final validation before merging.

**Prompt**:
```
Run a final validation:
1. /code-review — review all migration changes
2. /security-audit — check for security regressions
3. Build the project in production mode
4. Check bundle size (if frontend) — compare before/after
5. Verify all deprecation warnings are resolved
6. Confirm no old library imports remain
```

**Cleanup check**:
```
Search the codebase for any remaining references to [old library/pattern]:
- Import statements
- Configuration files
- Documentation
- Comments mentioning the old version
- Package.json / lock file entries
```

---

## Migration Types Reference

### Framework Version Upgrade
```
React 18 -> 19, Next.js 14 -> 15, Django 4 -> 5
Focus: Breaking API changes, new features, deprecation removal
```

### Library Swap
```
Moment.js -> date-fns, Express -> Fastify, REST -> GraphQL
Focus: API mapping, feature parity, missing functionality
```

### Language Migration
```
JavaScript -> TypeScript, Python 2 -> 3, CommonJS -> ESM
Focus: Type definitions, syntax changes, build config
```

### Architecture Change
```
Monolith -> microservices, MVC -> CQRS, REST -> event-driven
Focus: Data flow, service boundaries, deployment
```

---

## Checklist

Before merging the migration:

- [ ] All migration steps completed
- [ ] Build passes in production mode
- [ ] All tests pass (or pre-existing failures documented)
- [ ] No references to old library/pattern remain
- [ ] Bundle size / performance is acceptable
- [ ] Security audit passed
- [ ] Documentation updated
- [ ] Migration notes written for the PR description
- [ ] Rollback plan documented (just in case)
