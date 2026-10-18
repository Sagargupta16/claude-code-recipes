#!/usr/bin/env python3
"""Generate .claude-plugin/marketplace.json from the recipe files on disk.

The repo doubles as a Claude Code plugin marketplace, so a user can run

    /plugin marketplace add Sagargupta16/claude-code-recipes
    /plugin install recipe-commands@claude-code-recipes

instead of copying files by hand.

Each plugin's source is one recipe directory (./commands, ./subagents,
./skills, ./hooks), and the entry lists that directory's files by name. Two
layouts were tried first and rejected, both checked against the
`claude --debug-file` load log on Claude Code 2.1.295:

  - "source": "./" for every plugin. The entry's own lists load, but the
    loader still scans the default skills/ folder at the repo root, so every
    plugin also pulled in all five skills.
  - Default folder scans (no lists). The recipe directories keep their
    copy-paste layout, with subagents/ rather than agents/ and a README.md in
    every directory, so a scan would load each README as a command.

Listing files explicitly means a directory's README.md is never loaded.

The file is generated so a new recipe cannot land in the catalog and be
forgotten here: scripts/validate-recipes.sh runs this with --check, which
fails when the committed file is out of date. The version is the newest one
in CHANGELOG.md, so a release bumps both.

Usage:
    python scripts/build_marketplace.py          # write the file
    python scripts/build_marketplace.py --check  # exit 1 if it is stale
"""

from __future__ import annotations

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / ".claude-plugin" / "marketplace.json"
REPO = "https://github.com/Sagargupta16/claude-code-recipes"
AUTHOR = {"name": "Sagar Gupta", "url": "https://github.com/Sagargupta16"}


def changelog_version() -> str:
    text = (ROOT / "CHANGELOG.md").read_text(encoding="utf-8")
    match = re.search(r"^## \[(\d+\.\d+\.\d+)\]", text, re.MULTILINE)
    if not match:
        raise SystemExit("CHANGELOG.md has no '## [x.y.z]' heading")
    return match.group(1)


def recipe_files(directory: str) -> list[str]:
    """Paths relative to the plugin root, which is the directory itself."""
    return [
        f"./{p.name}"
        for p in sorted((ROOT / directory).glob("*.md"))
        if p.name != "README.md"
    ]


def skill_dirs() -> list[str]:
    return [f"./{p.parent.name}" for p in sorted((ROOT / "skills").glob("*/SKILL.md"))]


def hook(script: str, **extra: str) -> dict:
    if not (ROOT / "hooks" / script).is_file():
        raise SystemExit(f"hooks/{script} does not exist")
    # Quoted so a plugin cache path with a space stays one argument
    handler = {
        "type": "command",
        "command": f'bash "${{CLAUDE_PLUGIN_ROOT}}/{script}"',
    }
    handler.update(extra)
    return handler


def build() -> dict:
    version = changelog_version()
    commands = recipe_files("commands")
    agents = recipe_files("subagents")
    skills = skill_dirs()

    common = {
        "version": version,
        "author": AUTHOR,
        "homepage": REPO,
        "repository": REPO,
        "license": "MIT",
    }

    plugins = [
        {
            "name": "recipe-commands",
            "source": "./commands",
            "description": (
                f"{len(commands)} slash commands: code review, commit and PR text, "
                "test and doc generation, debugging, migration, security and "
                "performance audits"
            ),
            "category": "development",
            "keywords": ["commands", "code-review", "testing", "git"],
            "commands": commands,
        },
        {
            "name": "recipe-agents",
            "source": "./subagents",
            "description": (
                f"{len(agents)} subagents with scoped tool lists: researcher, test "
                "runner, code reviewer, frontend, backend, DevOps, security, "
                "docs and database specialists"
            ),
            "category": "development",
            "keywords": ["subagents", "agents", "delegation"],
            "agents": agents,
        },
        {
            "name": "recipe-skills",
            "source": "./skills",
            "description": (
                f"{len(skills)} skills that load on demand: React patterns, API "
                "design, git workflow, testing strategy, strict TypeScript"
            ),
            "category": "development",
            "keywords": ["skills", "react", "typescript", "api-design"],
            "skills": skills,
        },
        {
            "name": "recipe-hooks",
            "source": "./hooks",
            "description": (
                "Lint before git commit and run tests before git push (both "
                "block with exit 2), format every file Claude edits, and a "
                "desktop notification when Claude is waiting on you. Needs jq"
            ),
            "category": "automation",
            "keywords": ["hooks", "lint", "format", "pre-commit", "notification"],
            "hooks": {
                "PreToolUse": [
                    {
                        "matcher": "Bash",
                        "hooks": [
                            hook(
                                "pre-commit-lint.sh",
                                **{
                                    "if": "Bash(git commit *)",
                                    "statusMessage": "Linting staged files before commit",
                                },
                            ),
                            hook(
                                "pre-push-test.sh",
                                **{
                                    "if": "Bash(git push *)",
                                    "statusMessage": "Running tests before push",
                                },
                            ),
                        ],
                    }
                ],
                "PostToolUse": [
                    {
                        "matcher": "Edit|Write",
                        "hooks": [
                            hook(
                                "post-edit-format.sh",
                                statusMessage="Formatting the edited file",
                            )
                        ],
                    }
                ],
                "Notification": [{"hooks": [hook("notification.sh")]}],
            },
        },
        {
            "name": "recipe-guards",
            "source": "./hooks",
            "description": (
                "Security hooks: block destructive shell commands (rm -rf /, "
                "force push, curl | sh, DROP TABLE) and block any edit that "
                "would write a cloud key, API token or private key to disk. "
                "Needs jq"
            ),
            "category": "security",
            "keywords": ["security", "hooks", "secrets", "guardrails"],
            "hooks": {
                "PreToolUse": [
                    {
                        "matcher": "Bash",
                        "hooks": [hook("block-dangerous-commands.sh")],
                    },
                    {
                        "matcher": "Edit|Write|NotebookEdit",
                        "hooks": [hook("secret-scan.sh")],
                    },
                ]
            },
        },
    ]

    entries = []
    for plugin in plugins:
        name = plugin.pop("name")
        source = plugin.pop("source")
        entries.append({"name": name, "source": source, **common, **plugin})

    return {
        "$schema": "https://json.schemastore.org/claude-code-marketplace.json",
        "name": "claude-code-recipes",
        "description": (
            "Copy-paste Claude Code recipes as installable plugins: commands, "
            "subagents, skills, workflow hooks and security guard hooks"
        ),
        "version": version,
        "owner": AUTHOR,
        "plugins": entries,
    }


def render() -> str:
    return json.dumps(build(), indent=2, ensure_ascii=False) + "\n"


def main() -> int:
    text = render()
    if "--check" in sys.argv[1:]:
        current = OUT.read_text(encoding="utf-8") if OUT.exists() else ""
        if current.replace("\r\n", "\n") != text:
            print(
                f"{OUT.relative_to(ROOT).as_posix()} is out of date. "
                "Run: python scripts/build_marketplace.py",
                file=sys.stderr,
            )
            return 1
        return 0
    OUT.parent.mkdir(exist_ok=True)
    OUT.write_bytes(text.encode("utf-8"))
    print(f"wrote {OUT.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
