---
model: sonnet
description: Audit all your GitHub repos for CI health, hygiene, security alerts, and staleness
allowed-tools:
  - Bash(gh *)
---

Audit every repository I own for health, hygiene, and security problems.

Scope: my own non-fork repositories. Include private repos only if `$ARGUMENTS` says so; otherwise stick to public ones.

## Step 1 -- List the Repos

```bash
gh repo list --no-archived --source --limit 200 \
  --json name,visibility,pushedAt,isFork,licenseInfo,description
```

## Step 2 -- Check Each Repo

For every repo, collect these four signals. Skip a check rather than guessing when the API returns 403 or 404, and say which checks were skipped.

**CI status** -- latest workflow run conclusion:

```bash
gh run list --repo {owner}/{repo} --limit 1 --json conclusion,name,createdAt
```

A repo with no workflows is "none", not "failing".

**Security** -- open Dependabot alerts by severity:

```bash
gh api repos/{owner}/{repo}/dependabot/alerts --jq '[.[] | select(.state=="open") | .security_advisory.severity] | group_by(.) | map({severity: .[0], count: length})'
```

**Hygiene** -- which of `README.md`, `LICENSE`, `.gitignore` are missing:

```bash
gh api repos/{owner}/{repo}/contents --jq '[.[].name]'
```

**Staleness** -- last push date from step 1, plus open bot PRs:

```bash
gh pr list --repo {owner}/{repo} --author "app/dependabot" --json number,title
gh pr list --repo {owner}/{repo} --author "app/renovate" --json number,title
```

## Step 3 -- Report

Output one table sorted worst-first:

```
| Repo | Last Push | CI | Security | Missing Files | Open Bot PRs |
```

Then a **Critical** section listing, with the repo name and the exact next command to run:

- Failing CI on the default branch
- Any open high or critical severity alert
- A public repo with no LICENSE

Then a **Warnings** section for missing README or `.gitignore`, and repos with no push in over 6 months.

Read only. Do not open PRs, change settings, or dismiss alerts.
