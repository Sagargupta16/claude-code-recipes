#!/usr/bin/env bash
# ============================================================================
# Pre-commit Lint Hook
# Runs the project linter on staged files before git commit.
# Exits 1 to block the commit if linting errors are found.
#
# Supported linters:
#   JavaScript/TypeScript: eslint, biome
#   Python: ruff, flake8, black --check
#   Go: golangci-lint
#   Rust: cargo clippy
#   General: prettier --check
#
# Install: Copy to .claude/hooks/ and add to .claude/settings.json
# ============================================================================
set -euo pipefail

# --------------------------------------------------------------------------
# Detect staged files
# --------------------------------------------------------------------------
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)

if [[ -z "$STAGED_FILES" ]]; then
  echo "[lint-hook] No staged files to lint."
  exit 0
fi

# --------------------------------------------------------------------------
# Helper: check if a command exists
# --------------------------------------------------------------------------
has_cmd() {
  command -v "$1" &>/dev/null
}

# --------------------------------------------------------------------------
# Helper: filter files by extension
# --------------------------------------------------------------------------
files_matching() {
  local pattern="$1"
  echo "$STAGED_FILES" | grep -E "$pattern" || true
}

ERRORS=0

# --------------------------------------------------------------------------
# JavaScript / TypeScript
# --------------------------------------------------------------------------
JS_FILES=$(files_matching '\.(js|jsx|ts|tsx|mjs|cjs)$')

if [[ -n "$JS_FILES" ]]; then
  if has_cmd eslint; then
    echo "[lint-hook] Running ESLint on staged JS/TS files..."
    echo "$JS_FILES" | xargs eslint --no-warn-ignored --max-warnings=0 || ERRORS=1
  elif has_cmd biome; then
    echo "[lint-hook] Running Biome on staged JS/TS files..."
    echo "$JS_FILES" | xargs biome check --no-errors-on-unmatched || ERRORS=1
  elif [[ -f node_modules/.bin/eslint ]]; then
    echo "[lint-hook] Running local ESLint on staged JS/TS files..."
    echo "$JS_FILES" | xargs node_modules/.bin/eslint --no-warn-ignored --max-warnings=0 || ERRORS=1
  fi
fi

# --------------------------------------------------------------------------
# Prettier (any file type)
# --------------------------------------------------------------------------
if has_cmd prettier || [[ -f node_modules/.bin/prettier ]]; then
  PRETTIER_CMD="prettier"
  if ! has_cmd prettier; then
    PRETTIER_CMD="node_modules/.bin/prettier"
  fi
  PRETTIER_FILES=$(files_matching '\.(js|jsx|ts|tsx|css|scss|json|md|yaml|yml|html|vue|svelte)$')
  if [[ -n "$PRETTIER_FILES" ]]; then
    echo "[lint-hook] Running Prettier check on staged files..."
    echo "$PRETTIER_FILES" | xargs "$PRETTIER_CMD" --check 2>/dev/null || ERRORS=1
  fi
fi

# --------------------------------------------------------------------------
# Python
# --------------------------------------------------------------------------
PY_FILES=$(files_matching '\.py$')

if [[ -n "$PY_FILES" ]]; then
  if has_cmd ruff; then
    echo "[lint-hook] Running Ruff on staged Python files..."
    echo "$PY_FILES" | xargs ruff check || ERRORS=1
  elif has_cmd flake8; then
    echo "[lint-hook] Running Flake8 on staged Python files..."
    echo "$PY_FILES" | xargs flake8 || ERRORS=1
  fi

  if has_cmd black; then
    echo "[lint-hook] Running Black format check on staged Python files..."
    echo "$PY_FILES" | xargs black --check --quiet || ERRORS=1
  fi
fi

# --------------------------------------------------------------------------
# Go
# --------------------------------------------------------------------------
GO_FILES=$(files_matching '\.go$')

if [[ -n "$GO_FILES" ]]; then
  if has_cmd golangci-lint; then
    echo "[lint-hook] Running golangci-lint..."
    golangci-lint run --new-from-rev=HEAD || ERRORS=1
  elif has_cmd go; then
    echo "[lint-hook] Running go vet..."
    go vet ./... || ERRORS=1
  fi
fi

# --------------------------------------------------------------------------
# Rust
# --------------------------------------------------------------------------
RS_FILES=$(files_matching '\.rs$')

if [[ -n "$RS_FILES" ]]; then
  if has_cmd cargo; then
    echo "[lint-hook] Running cargo clippy..."
    cargo clippy --all-targets --all-features -- -D warnings 2>/dev/null || ERRORS=1
  fi
fi

# --------------------------------------------------------------------------
# Result
# --------------------------------------------------------------------------
if [[ $ERRORS -ne 0 ]]; then
  echo ""
  echo "[lint-hook] Linting errors found. Commit blocked."
  echo "[lint-hook] Fix the issues above and try again."
  exit 1
fi

echo "[lint-hook] All checks passed."
exit 0
