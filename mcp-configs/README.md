# MCP Configs

> Model Context Protocol server configurations that extend Claude Code with external tools and data sources.

MCP (Model Context Protocol) lets Claude Code connect to external services -- GitHub, databases, file systems, and more. Each config defines an MCP server that exposes tools Claude can use during your session.

---

## How MCP Works

1. Claude Code reads MCP server configs from `.mcp.json` in your project root
2. On session start, it launches each configured server as a subprocess
3. The server exposes tools (functions) that Claude can call
4. Claude uses these tools naturally during conversation -- querying databases, creating GitHub issues, etc.

---

## Available Configs

| Config | Service | Transport | Tools Provided | File |
|--------|---------|-----------|---------------|------|
| GitHub | GitHub API | Remote (`http`) | Issues, PRs, repos, actions, code search | [github.json](github.json) |
| Filesystem | Local filesystem | Local (`npx`) | Read, write, search, directory operations | [filesystem.json](filesystem.json) |
| PostgreSQL | PostgreSQL DB | Local (`npx`) | Query, schema inspection, table info | [postgres.json](postgres.json) |
| Memory | Knowledge graph | Local (`npx`) | Store, retrieve, search persistent memory | [memory.json](memory.json) |
| Context7 | Documentation | Local (`npx`) | Library docs lookup, code examples | [context7.json](context7.json) |

> **PostgreSQL is upstream-deprecated.** As of 2026-09-06 npm marks `@modelcontextprotocol/server-postgres` as no longer supported and the source now lives in the archived servers repository. The recipe still works, but it is a starting point rather than a maintained integration. See the `_comment` block in [postgres.json](postgres.json).

An entry with a `url` **must** also carry a `type` (`http`, `sse`, or `ws`). Claude Code reads a `url` entry with no `type` as a stdio server, skips it, and reports `has a "url" but no "type"`.

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

Remote servers (`"type": "http"`) need nothing installed. Local servers are published as npm packages and run through `npx`:

```bash
# npm-based servers run automatically via npx
# No pre-installation needed -- Claude Code handles it

# For servers requiring local setup (like PostgreSQL), ensure the service is running
```

### 5. Verify

```bash
claude mcp list
```

Then run `/mcp` inside Claude Code and confirm each server shows `connected`. A server whose `${VAR}` is unset still loads, with a missing-variable warning and an unexpanded `${VAR}` value, so it fails at connect time rather than at load time.

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

## Config Scopes

There are three scopes, and only one of them is a file you hand-edit.

| Scope | Stored in | Loads in | Shared with the team |
|-------|-----------|----------|----------------------|
| Local | `~/.claude.json`, nested under the project path | This project only | No |
| Project | `.mcp.json` in the project root | This project only | Yes, via version control |
| User | `~/.claude.json`, at the top level | All your projects | No |

Server definitions never go in a settings file. `~/.claude/settings.json` and `.claude/settings.json` hold MCP *controls* only -- `enabledMcpjsonServers`, `disabledMcpjsonServers`, `enableAllProjectMcpServers`. A definition belongs in one of the three files above.

For anything other than the committed project scope, let the CLI write the file:

```bash
# Available to you in every project
claude mcp add --transport http github --scope user https://api.githubcopilot.com/mcp/

# Committed to this repo for the whole team
claude mcp add --transport http github --scope project https://api.githubcopilot.com/mcp/
```

When the same server name is defined in more than one place, Claude Code uses one definition and does not merge fields across scopes. Precedence, highest first:

1. Local
2. Project
3. User
4. Plugin-provided servers
5. claude.ai connectors

---

## Tips

- Start with GitHub and Memory -- they're useful for every project
- Add PostgreSQL only if your project uses a database
- Context7 is valuable when working with unfamiliar libraries
- Keep API keys in environment variables, never in `.mcp.json`
- Each local server runs as a subprocess -- more servers means more memory usage. Remote (`http`) servers cost you nothing locally
- Restart Claude Code after changing `.mcp.json`
