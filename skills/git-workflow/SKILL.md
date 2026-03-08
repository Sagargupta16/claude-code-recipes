# Git Workflow

> Git conventions: branch naming, conventional commits, PR format, squash strategy, and protected branches.

## Branch Naming

Use the format: `<type>/<ticket>-<short-description>`

| Type | Purpose | Example |
|------|---------|---------|
| `feat/` | New feature | `feat/PROJ-123-user-avatars` |
| `fix/` | Bug fix | `fix/PROJ-456-login-redirect` |
| `chore/` | Maintenance, deps, config | `chore/upgrade-react-19` |
| `docs/` | Documentation only | `docs/api-authentication-guide` |
| `refactor/` | Code restructuring | `refactor/extract-auth-module` |
| `test/` | Adding or fixing tests | `test/order-service-coverage` |
| `hotfix/` | Urgent production fix | `hotfix/payment-timeout` |

### Rules

1. **Always branch from `main`** (or `develop` if using Git Flow)
2. **Use lowercase and hyphens** — no underscores, no camelCase
3. **Include the ticket number** when a tracker exists
4. **Keep descriptions under 5 words**
5. **Delete branches after merging**

## Conventional Commits

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature visible to users |
| `fix` | Bug fix |
| `docs` | Documentation changes only |
| `style` | Formatting, whitespace (no logic changes) |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Build system or dependencies |
| `ci` | CI/CD pipeline changes |
| `chore` | Other changes that don't modify src or test files |
| `revert` | Reverts a previous commit |

### Rules

1. **Subject line under 72 characters**
2. **Use imperative mood** — "add feature" not "added feature" or "adds feature"
3. **No period at the end of the subject**
4. **Scope is optional but encouraged** — use the module or component name
5. **Body explains *why*, not *what*** — the diff shows what changed
6. **Footer for breaking changes and issue references**

### Examples

```
feat(auth): add OAuth2 login with Google

Adds Google OAuth2 as a login option alongside email/password.
Users can link their Google account in settings.

Closes #234

---

fix(cart): prevent duplicate items on rapid clicks

Added debounce to the "Add to Cart" button and server-side
idempotency check using the request ID header.

Fixes #567

---

feat(api)!: change pagination from offset to cursor-based

BREAKING CHANGE: The `page` and `per_page` query parameters are
replaced by `cursor` and `limit`. See migration guide in docs.
```

## Pull Request Format

### Title

Use the same format as conventional commits:

```
feat(auth): add OAuth2 login with Google
```

### Description Template

```markdown
## Summary
Brief description of what changed and why.

## Changes
- First change
- Second change
- Third change

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots
(if UI changes)

## Related
Closes #123
```

### PR Rules

1. **One concern per PR** — don't mix features with refactoring
2. **Keep PRs under 400 lines** — split larger changes into a stack
3. **Self-review before requesting review** — check the diff yourself first
4. **Respond to all review comments** — resolve or explain why not
5. **Update the PR description if scope changes**
6. **Add reviewers based on CODEOWNERS** — or at least one domain expert

## Merge Strategy

### Squash and Merge (default)

Use squash merge for feature branches:

1. All commits in the branch become one commit on `main`
2. The squash commit message uses the PR title
3. The PR description becomes the commit body
4. Individual commit history is preserved in the PR

### When to Use Regular Merge

- **Release branches** — preserve the full history
- **Long-lived branches** — when commit history tells a story
- **Merge commits from `main` into a feature branch** — to stay up to date

### When to Rebase

- **Before opening a PR** — rebase on `main` to get a clean diff
- **To clean up local commits** — squash fixups before pushing

## Protected Branches

### `main` branch rules

1. **No direct pushes** — all changes go through PRs
2. **Require at least 1 approval** (2 for critical paths)
3. **Require passing CI checks** — tests, lint, build
4. **Require up-to-date branch** — must be rebased on latest `main`
5. **Require signed commits** (optional but recommended)
6. **No force pushes**

### `develop` branch rules (if using Git Flow)

1. **Require passing CI checks**
2. **Allow direct pushes from release managers** (optional)

## Tagging and Releases

1. **Use semantic versioning** — `v1.2.3`
2. **Tag releases on `main`** — after the merge
3. **Write release notes** — summarize changes since the last release
4. **Automate with CI** — use GitHub Actions or equivalent to create releases on tag push

```bash
# Create a release tag
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3
```

## Workflow Summary

```
1. Create branch    git checkout -b feat/PROJ-123-user-avatars main
2. Make commits     git commit -m "feat(users): add avatar upload"
3. Push branch      git push -u origin feat/PROJ-123-user-avatars
4. Open PR          gh pr create --title "feat(users): add avatar upload"
5. Review cycle     Address feedback, push fixes
6. Squash merge     Merge via GitHub UI
7. Delete branch    git branch -d feat/PROJ-123-user-avatars
8. Pull main        git checkout main && git pull
```

## Anti-patterns

- **Committing to `main` directly** — always use a branch and PR
- **Giant PRs (1000+ lines)** — split into smaller, reviewable chunks
- **Vague commit messages** — "fix stuff", "updates", "wip"
- **Long-lived feature branches** — merge frequently or use feature flags
- **Force pushing shared branches** — only force push your own branches
- **Merge commits in feature branches** — rebase instead to keep history clean
