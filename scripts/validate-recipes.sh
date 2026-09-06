#!/usr/bin/env bash
# ============================================================================
# Recipe Validator
# Asserts that every recipe in this repo is actually installable, and that the
# counts advertised in the READMEs match the files on disk.
#
# Checks:
#   1. Command files open with YAML frontmatter on line 1 and set a description
#      and a model, which CONTRIBUTING.md requires so the index tables can list it
#   2. Command files are prompts, not wrapper docs ("Save as .claude/commands/")
#   3. Subagent files set name + description, and never allowed-tools. `tools` is
#      optional, as subagents/README.md and the Claude Code docs both say
#   4. Subagent tools/disallowedTools are comma-separated strings, not YAML lists
#   5. Skill files open with frontmatter on line 1 and set a description
#   6. Hook JSON uses the nested event -> matcher -> hooks schema with a type
#   7. Every JSON file parses
#   8. No em dash (U+2014) or en dash (U+2013) anywhere
#   9. Recipe counts and headline total in README.md match the real file counts
#  10. Every recipe file is linked from the README.md catalog
#  11. Every link to a file in this repo points at a file that exists, including
#      the links in YAML that the CI link check does not glob
#
# Usage: bash scripts/validate-recipes.sh
# Exits 1 if any check fails.
# ============================================================================
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

FAILURES=0

# python3 on Linux and macOS, python on Git Bash for Windows
if command -v python3 >/dev/null 2>&1; then
  PYTHON=python3
elif command -v python >/dev/null 2>&1; then
  PYTHON=python
else
  echo "FAIL  no python3 or python on PATH" >&2
  exit 1
fi

fail() {
  echo "FAIL  $*" >&2
  FAILURES=$((FAILURES + 1))
}

pass() {
  echo "ok    $*"
}

frontmatter() {
  # Print the YAML frontmatter of a file, or nothing if line 1 is not "---"
  awk 'NR==1 && $0 !~ /^---[[:space:]]*$/ { exit } NR==1 { next } /^---[[:space:]]*$/ { exit } { print }' "$1"
}

# --------------------------------------------------------------------------
# 1 + 2. Commands
# --------------------------------------------------------------------------
echo "== commands"
for f in commands/*.md; do
  [[ "$(basename "$f")" == "README.md" ]] && continue

  fm=$(frontmatter "$f")
  if [[ -z "$fm" ]]; then
    fail "$f: no YAML frontmatter opening on line 1"
    continue
  fi
  if ! grep -qE '^description:[[:space:]]*[^[:space:]]' <<<"$fm"; then
    fail "$f: frontmatter has no description"
    continue
  fi
  if ! grep -qE '^model:[[:space:]]*(haiku|sonnet|opus)[[:space:]]*$' <<<"$fm"; then
    fail "$f: frontmatter has no model (haiku, sonnet or opus)"
    continue
  fi
  if grep -q 'Save as `.claude/commands/' "$f"; then
    fail "$f: wrapper doc, not an installable command file"
    continue
  fi
  pass "$f"
done

# --------------------------------------------------------------------------
# 3 + 4. Subagents
# --------------------------------------------------------------------------
echo "== subagents"
for f in subagents/*.md; do
  [[ "$(basename "$f")" == "README.md" ]] && continue

  fm=$(frontmatter "$f")
  if [[ -z "$fm" ]]; then
    fail "$f: no YAML frontmatter opening on line 1"
    continue
  fi

  # Only name and description are required. `tools` is optional: omit it and the
  # agent inherits every tool available to subagents.
  bad=0
  for key in name description; do
    grep -qE "^${key}:[[:space:]]*[^[:space:]]" <<<"$fm" || { fail "$f: frontmatter has no $key"; bad=1; }
  done

  if grep -qE '^allowed-tools:' <<<"$fm"; then
    fail "$f: uses allowed-tools, which is not a subagent field (use tools)"
    bad=1
  fi
  if grep -qE '^(tools|disallowedTools):[[:space:]]*$' <<<"$fm"; then
    fail "$f: tools/disallowedTools must be a comma-separated string, not a YAML list"
    bad=1
  fi

  [[ $bad -eq 0 ]] && pass "$f"
done

# --------------------------------------------------------------------------
# 5. Skills
# --------------------------------------------------------------------------
echo "== skills"
for f in skills/*/SKILL.md; do
  fm=$(frontmatter "$f")
  if [[ -z "$fm" ]]; then
    fail "$f: no YAML frontmatter opening on line 1"
    continue
  fi
  if ! grep -qE '^description:[[:space:]]*[^[:space:]]' <<<"$fm"; then
    fail "$f: frontmatter has no description"
    continue
  fi
  pass "$f"
done

# --------------------------------------------------------------------------
# 6 + 7. JSON validity and hook schema
# --------------------------------------------------------------------------
echo "== json"
for f in mcp-configs/*.json hooks/*.json settings/*.json renovate.json; do
  [[ -e "$f" ]] || continue
  if "$PYTHON" -c "import json,sys; json.load(open(sys.argv[1], encoding='utf-8'))" "$f"; then
    pass "$f parses"
  else
    fail "$f: invalid JSON"
  fi
done

if [[ -f hooks/settings-hook-examples.json ]]; then
  if "$PYTHON" scripts/check_hook_schema.py hooks/settings-hook-examples.json; then
    pass "hooks/settings-hook-examples.json uses the nested hook schema"
  else
    fail "hooks/settings-hook-examples.json: hook schema is wrong"
  fi
fi

# --------------------------------------------------------------------------
# 8. Banned dashes
# --------------------------------------------------------------------------
echo "== dashes"
if "$PYTHON" scripts/check_dashes.py; then
  pass "no em dash or en dash in tracked files"
else
  fail "em dash (U+2014) or en dash (U+2013) found"
fi

# --------------------------------------------------------------------------
# 9. Advertised recipe counts match reality
# --------------------------------------------------------------------------
echo "== counts"
count_files() {
  find "$1" -maxdepth 1 -name '*.md' ! -name 'README.md' | wc -l | tr -d ' '
}

N_COMMANDS=$(count_files commands)
N_SUBAGENTS=$(count_files subagents)
N_WORKFLOWS=$(count_files workflows)
N_TEMPLATES=$(count_files claude-md)
N_SKILLS=$(find skills -name SKILL.md | wc -l | tr -d ' ')
N_MCP=$(find mcp-configs -maxdepth 1 -name '*.json' | wc -l | tr -d ' ')
N_HOOKS=$(find hooks -maxdepth 1 \( -name '*.sh' -o -name '*.json' \) | wc -l | tr -d ' ')

TOTAL=$((N_COMMANDS + N_SUBAGENTS + N_WORKFLOWS + N_TEMPLATES + N_SKILLS + N_MCP + N_HOOKS))
echo "      commands=$N_COMMANDS subagents=$N_SUBAGENTS hooks=$N_HOOKS skills=$N_SKILLS mcp=$N_MCP workflows=$N_WORKFLOWS templates=$N_TEMPLATES total=$TOTAL"

expect_heading() {
  local file="$1" label="$2" want="$3"
  if grep -qF "$label ($want recipes)" "$file"; then
    pass "$file: $label says $want"
  else
    fail "$file: $label heading does not say '$want recipes' (real count is $want)"
  fi
}

expect_heading README.md "### Commands" "$N_COMMANDS"
expect_heading README.md "### Subagents" "$N_SUBAGENTS"
expect_heading README.md "### Hooks" "$N_HOOKS"
expect_heading README.md "### Skills" "$N_SKILLS"
expect_heading README.md "### MCP Configs" "$N_MCP"
expect_heading README.md "### Workflows" "$N_WORKFLOWS"
expect_heading README.md "### CLAUDE.md Templates" "$N_TEMPLATES"

if grep -qF "**$TOTAL copy-paste recipes**" README.md; then
  pass "README.md headline says $TOTAL recipes"
else
  fail "README.md headline does not say '$TOTAL copy-paste recipes'"
fi

# Every recipe file must be listed in the root catalog
echo "== catalog coverage"
while IFS= read -r f; do
  if ! grep -qF "$f" README.md; then
    fail "$f is not linked from README.md"
  fi
done < <(
  find commands subagents workflows claude-md -maxdepth 1 -name '*.md' ! -name 'README.md'
  find hooks -maxdepth 1 \( -name '*.sh' -o -name '*.json' \)
  find mcp-configs -maxdepth 1 -name '*.json'
)

# --------------------------------------------------------------------------
# 11. Links back into this repo point at files that exist
# --------------------------------------------------------------------------
# The CI link check globs Markdown and JSON only, so the blob/main URLs in the
# GitHub issue forms are invisible to it. They are also unresolvable there until
# the branch merges. Check them against the working tree instead, which catches
# a rename in any file type and needs no network.
echo "== self links"
SELF_PREFIX="https://github.com/Sagargupta16/claude-code-recipes/blob/main/"
while IFS= read -r target; do
  if [[ -e "$target" ]]; then
    pass "blob/main/$target exists"
  else
    fail "$target is linked as ${SELF_PREFIX}$target but is not in the repo"
  fi
done < <(
  grep -rhoE "${SELF_PREFIX}[A-Za-z0-9._/-]+" . --exclude-dir=.git |
    sed "s|^${SELF_PREFIX}||" | sort -u
)

# --------------------------------------------------------------------------
echo ""
if [[ $FAILURES -eq 0 ]]; then
  echo "All recipe checks passed."
  exit 0
fi
echo "$FAILURES check(s) failed."
exit 1
