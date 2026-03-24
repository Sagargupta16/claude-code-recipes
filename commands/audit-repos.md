# /audit-repos

Audit all repos for health, hygiene, and security issues.

## Command File

Save as `.claude/commands/audit-repos.md`:

```markdown
Audit all my GitHub repos for health issues.

For each repo (use gh repo list):
1. Check CI status: latest workflow run pass/fail
2. Check security: Dependabot/security alerts
3. Check hygiene: README exists, LICENSE exists, .gitignore exists
4. Check staleness: last commit date, any open Renovate/Dependabot PRs

Report a summary table with:
- Repo name | Last Commit | CI Status | Security Alerts | Missing Files

Flag critical issues: failing CI, high-severity alerts, missing LICENSE.
```

## Usage

```
/audit-repos
```

## Notes

- Scans all public repos by default
- Can take 1-2 minutes for 50+ repos
- Use `--model haiku` for the subagents to save costs
