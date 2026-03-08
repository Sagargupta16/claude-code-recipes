# Claude Code Subagent Recipes

Subagents are specialized AI personas that live in `.claude/agents/` and can be delegated to from the main Claude Code context. Each subagent has a scoped set of tools, a focused persona, and a well-defined output format — making them predictable, safe, and efficient.

## What Are Subagents?

A subagent is a markdown file with YAML frontmatter that defines:

- **name** — Identifier used to invoke the agent
- **model** — Which Claude model to use (`haiku` for fast/cheap, `sonnet` for balanced, `opus` for complex reasoning)
- **description** — When the orchestrator should delegate to this agent
- **allowed-tools** — The *only* tools this agent can access (principle of least privilege)

The main Claude Code session acts as an orchestrator, routing tasks to the right subagent based on the description field.

## Installation

Copy any `.md` file from this directory into your project:

```bash
mkdir -p .claude/agents
cp subagents/researcher.md .claude/agents/
cp subagents/code-reviewer.md .claude/agents/
# ... or copy them all:
cp subagents/*.md .claude/agents/
```

Then remove the README so it does not get picked up as an agent:

```bash
rm .claude/agents/README.md
```

## Subagent Index

| File | Name | Model | Tools | Purpose |
|------|------|-------|-------|---------|
| `researcher.md` | researcher | haiku | Read, Glob, Grep | Explore codebase, find patterns, locate files |
| `test-runner.md` | test-runner | sonnet | Bash, Read, Edit | Run tests, analyze failures, fix broken tests |
| `code-reviewer.md` | code-reviewer | sonnet | Read, Glob, Grep | Deep code review with severity ratings |
| `frontend-dev.md` | frontend-dev | sonnet | Read, Edit, Write, Glob, Bash | React/Vue/CSS component specialist |
| `backend-dev.md` | backend-dev | sonnet | Read, Edit, Write, Glob, Bash | API, database, auth specialist |
| `devops-engineer.md` | devops-engineer | sonnet | Read, Edit, Write, Glob, Bash | CI/CD, Docker, Terraform, cloud infra |
| `security-analyst.md` | security-analyst | sonnet | Read, Glob, Grep | Security review, OWASP, secrets detection |
| `tech-writer.md` | tech-writer | haiku | Read, Write, Glob | Documentation, READMEs, API docs, changelogs |
| `database-architect.md` | database-architect | sonnet | Read, Edit, Write, Glob, Bash | Schema design, migrations, query optimization |

## Design Principles

1. **Least privilege** — Each agent only gets the tools it needs. Read-only agents cannot edit files.
2. **Right-sized models** — Use `haiku` for fast retrieval tasks, `sonnet` for coding and analysis, `opus` for complex architectural reasoning.
3. **Structured output** — Every agent returns a predictable format so the orchestrator can parse and act on results.
4. **Single responsibility** — Each agent does one category of work well rather than being a generalist.

## Customization

These are starting points. Adapt them to your stack:

- Change tool lists to match your project (e.g., add `WebFetch` for agents that need external docs)
- Adjust the model tier based on your cost/quality tradeoffs
- Add project-specific instructions (e.g., "We use Tailwind CSS" in the frontend-dev agent)
- Create new agents for your domain (e.g., `ml-engineer.md`, `mobile-dev.md`)
