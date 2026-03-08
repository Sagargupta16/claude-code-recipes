# MCP Configs

> Model Context Protocol server configurations that extend Claude Code with external tools and data sources.

MCP (Model Context Protocol) lets Claude Code connect to external services — GitHub, databases, file systems, and more. Each config defines an MCP server that exposes tools Claude can use during your session.

---

## How MCP Works

1. Claude Code reads MCP server configs from `.mcp.json` in your project root
2. On session start, it launches each configured server as a subprocess
3. The server exposes tools (functions) that Claude can call
4. Claude uses these tools naturally during conversation — querying databases, creating GitHub issues, etc.

---

## Available Configs

| Config | Service | Tools Provided | File |
|--------|---------|---------------|------|
| GitHub | GitHub API | Issues, PRs, repos, actions, code search | [github.json](github.json) |
| Filesystem | Local filesystem | Read, write, search, directory operations | [filesystem.json](filesystem.json) |
| PostgreSQL | PostgreSQL DB | Query, schema inspection, table info | [postgres.json](postgres.json) |
| Memory | Knowledge graph | Store, retrieve, search persistent memory | [memory.json](memory.json) |
| Context7 | Documentation | Library docs lookup, code examples | [context7.json](context7.json) |

---

## Installation

### 1. Create `.mcp.json` in your project root

```bash
touch .mcp.json
```

### 2. Add the server config

Each JSON file in this directory contains one server config. Copy the contents into your `.mcp.json` under the `mcpServers` key:

```json
{
  "mcpServers": {
    "github": {
      ...contents from github.json...
    }
  }
}
```

### 3. Combine multiple servers

Merge multiple configs into a single `.mcp.json`:

```json
{
  "mcpServers": {
    "github": { ... },
    "filesystem": { ... },
    "memory": { ... }
  }
}
```

### 4. Install dependencies

Most MCP servers are published as npm packages. Install them globally or use `npx`:

```bash
# npm-based servers run automatically via npx
# No pre-installation needed — Claude Code handles it

# For servers requiring local setup (like PostgreSQL), ensure the service is running
```

---

## Environment Variables

Some servers require API keys or connection strings. Set them in your environment:

```bash
# GitHub
export GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxxxxxxxxxxx

# PostgreSQL
export DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
```

Or use a `.env` file (make sure it's in `.gitignore`):

```
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxxxxxxxxxxx
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
```

---

## Project vs Global Config

| Location | Scope | Use Case |
|----------|-------|----------|
| `.mcp.json` (project root) | This project only | Project-specific servers |
| `~/.claude/settings.json` | All projects | Servers you use everywhere |

---

## Tips

- Start with GitHub and Memory — they're useful for every project
- Add PostgreSQL only if your project uses a database
- Context7 is valuable when working with unfamiliar libraries
- Keep API keys in environment variables, never in `.mcp.json`
- Each server runs as a subprocess — more servers means more memory usage
- Restart Claude Code after changing `.mcp.json`
