#!/usr/bin/env python3
"""Assert that a settings JSON file uses the real Claude Code hook schema.

The schema is three levels deep:

    {"hooks": {"<Event>": [{"matcher": "Bash",
                            "hooks": [{"type": "command", "command": "..."}]}]}}

The failure this guards against is the flat ``{"matcher", "command"}`` shape,
which parses as valid JSON and then never fires. It also rejects matcher values
that cannot match a tool name, because on tool events the matcher is compared
against the tool name (``Bash``, ``Edit|Write``, ``mcp__.*``), not against a git
subcommand.

Usage: python scripts/check_hook_schema.py <file.json> [<file.json> ...]
"""

from __future__ import annotations

import json
import pathlib
import re
import sys

TOOL_EVENTS = {
    "PreToolUse",
    "PostToolUse",
    "PostToolUseFailure",
    "PermissionRequest",
    "PermissionDenied",
}

VALID_HANDLER_TYPES = {"command", "http", "mcp_tool", "prompt", "agent"}

# A matcher made only of these characters is compared as an exact string (or a
# list of exact strings). Anything else is treated as a regular expression.
EXACT_MATCHER = re.compile(r"^[A-Za-z0-9_\-, |]+$")

# Shape of a tool name, rather than a list of them: built-in tools are
# PascalCase with no separators (``Bash``, ``Edit``, ``NotebookEdit``) and MCP
# tools are ``mcp__<server>__<tool>``. Checking the shape catches the mistake
# this guards against (``git_commit``, ``file_edit``, lowercase ``bash``)
# without an allowlist that goes stale every time a tool is added.
TOOL_NAME = re.compile(r"^(?:[A-Z][A-Za-z0-9]*|mcp__[A-Za-z0-9_]+)$")


def check_matcher(event: str, matcher: str, where: str, errors: list[str]) -> None:
    if event not in TOOL_EVENTS:
        return
    if matcher in ("", "*"):
        return
    if not EXACT_MATCHER.match(matcher):
        # Regex path: nothing to verify beyond it compiling.
        try:
            re.compile(matcher)
        except re.error as exc:
            errors.append(f"{where}: matcher {matcher!r} is not a valid regex ({exc})")
        return
    names = [n.strip() for n in re.split(r"[|,]", matcher) if n.strip()]
    for name in names:
        if not TOOL_NAME.match(name):
            errors.append(
                f"{where}: matcher {matcher!r} names {name!r}, which is not shaped like "
                "a tool name. On tool events the matcher matches the tool name (Bash, "
                "Edit|Write, mcp__.*). Use the per-handler 'if' field for command "
                "filtering."
            )


def resolve_in_repo(candidate: str) -> pathlib.Path:
    """Resolve a CLI argument to a file inside this repository.

    The script only ever inspects files that are checked in here, so anything
    resolving outside the repository root is rejected rather than opened.
    """
    repo_root = pathlib.Path(__file__).resolve().parent.parent
    resolved = pathlib.Path(candidate).resolve()
    if not resolved.is_relative_to(repo_root):
        raise ValueError(f"{candidate}: refusing to read a path outside {repo_root}")
    if not resolved.is_file():
        raise ValueError(f"{candidate}: not a file")
    return resolved


def check_file(path: str) -> list[str]:
    errors: list[str] = []
    target = resolve_in_repo(path)
    with target.open(encoding="utf-8") as handle:
        data = json.load(handle)

    hooks = data.get("hooks")
    if hooks is None:
        return [f"{path}: no top-level 'hooks' key"]
    if not isinstance(hooks, dict):
        return [f"{path}: 'hooks' must be an object keyed by event name"]

    for event, groups in hooks.items():
        if not isinstance(groups, list):
            errors.append(f"{path}: hooks.{event} must be an array of matcher groups")
            continue
        for index, group in enumerate(groups):
            where = f"{path}: hooks.{event}[{index}]"
            if not isinstance(group, dict):
                errors.append(f"{where} must be an object")
                continue
            if "command" in group:
                errors.append(
                    f"{where} puts 'command' on the matcher group. Commands belong in a "
                    "nested 'hooks' array of handlers."
                )
            handlers = group.get("hooks")
            if not isinstance(handlers, list) or not handlers:
                errors.append(f"{where} has no non-empty 'hooks' handler array")
                continue
            matcher = group.get("matcher")
            if isinstance(matcher, str):
                check_matcher(event, matcher, where, errors)
            for handler_index, handler in enumerate(handlers):
                handler_where = f"{where}.hooks[{handler_index}]"
                if not isinstance(handler, dict):
                    errors.append(f"{handler_where} must be an object")
                    continue
                handler_type = handler.get("type")
                if handler_type not in VALID_HANDLER_TYPES:
                    errors.append(
                        f"{handler_where} has type {handler_type!r}; expected one of "
                        + ", ".join(sorted(VALID_HANDLER_TYPES))
                    )
                if handler_type == "command" and not handler.get("command"):
                    errors.append(
                        f"{handler_where} is a command handler with no 'command'"
                    )
                if "if" in handler and event not in TOOL_EVENTS:
                    errors.append(
                        f"{handler_where} sets 'if' on {event}, which is not a tool event. "
                        "A handler with 'if' never runs on a non-tool event."
                    )
    return errors


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print(__doc__, file=sys.stderr)
        return 2
    errors: list[str] = []
    for path in argv[1:]:
        try:
            errors.extend(check_file(path))
        except (ValueError, OSError, json.JSONDecodeError) as exc:
            errors.append(str(exc))
    for error in errors:
        print(error, file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
