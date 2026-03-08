# Skills

> Reusable knowledge modules that teach Claude your team's conventions and best practices.

Skills are `SKILL.md` files placed in `.claude/skills/` directories. When Claude detects a relevant skill, it reads the file and follows the conventions defined within. Think of skills as persistent context that shapes how Claude writes code for your project.

---

## How Skills Work

1. You place a `SKILL.md` file in a subdirectory of `.claude/skills/`
2. Claude discovers the skill when working on related tasks
3. The skill content is loaded as additional context
4. Claude follows the conventions and patterns defined in the skill

Skills are passive — they provide knowledge, not commands. They answer questions like:
- "How should I structure React components in this project?"
- "What git commit format does this team use?"
- "What testing patterns should I follow?"

---

## Available Skills

| Skill | Domain | What It Covers |
|-------|--------|---------------|
| [React Patterns](react-patterns/) | Frontend | Components, hooks, state management, performance, a11y |
| [API Design](api-design/) | Backend | REST conventions, status codes, pagination, error handling |
| [Git Workflow](git-workflow/) | Process | Branch naming, commits, PRs, merge strategy |
| [Testing Strategy](testing-strategy/) | Quality | Test types, structure, mocking, coverage targets |
| [TypeScript Strict](typescript-strict/) | Language | Strict config, type patterns, error handling |

---

## Installation

### Single skill

```bash
# Copy one skill to your project
mkdir -p .claude/skills
cp -r claude-code-recipes/skills/react-patterns .claude/skills/
```

### All skills

```bash
# Copy all skills to your project
mkdir -p .claude/skills
cp -r claude-code-recipes/skills/* .claude/skills/
```

---

## Directory Structure

```
.claude/
  skills/
    react-patterns/
      SKILL.md          # The skill definition
    api-design/
      SKILL.md
    git-workflow/
      SKILL.md
    testing-strategy/
      SKILL.md
    typescript-strict/
      SKILL.md
```

---

## Writing Custom Skills

Create a new skill by adding a `SKILL.md` file in a subdirectory:

```
.claude/skills/your-skill-name/SKILL.md
```

### Guidelines

1. **Be specific**: Concrete rules work better than vague principles
2. **Include examples**: Show the right way and the wrong way
3. **Keep it focused**: One domain per skill (don't mix frontend and database conventions)
4. **Use imperative mood**: "Use functional components" not "Functional components are preferred"
5. **Add rationale**: Explain *why* a convention exists, not just *what* it is
6. **Stay under 200 lines**: Longer skills get diluted — split them up instead

### Template

```markdown
# Skill Name

> One-line description of what this skill covers.

## Rules

1. First convention — with brief rationale
2. Second convention — with brief rationale

## Patterns

### Pattern Name

Description of when to use this pattern.

```language
// Good
code example

// Bad
code example
```

## Anti-patterns

- Thing to avoid — why it's problematic
```

---

## Tips

- Skills stack: you can have multiple skills active at once
- Project-specific skills override general ones if they conflict
- Review skills periodically — update them as your conventions evolve
- Skills work best when they match the technology you actually use
