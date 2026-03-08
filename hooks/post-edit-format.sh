#!/usr/bin/env bash
# ============================================================================
# Post-edit Format Hook
# Auto-formats files after Claude edits them.
# Detects the appropriate formatter based on file type and available tools.
#
# Supported formatters:
#   JavaScript/TypeScript: prettier, biome, eslint --fix
#   Python: black, ruff format, autopep8
#   Go: gofmt, goimports
#   Rust: rustfmt
#   C/C++: clang-format
#   General: prettier
#
# Install: Copy to .claude/hooks/ and add to .claude/settings.json
# ============================================================================
set -euo pipefail

# --------------------------------------------------------------------------
# Read the edited file path from stdin payload or environment
# --------------------------------------------------------------------------
PAYLOAD=$(cat 2>/dev/null || true)
FILE_PATH="${CLAUDE_FILE_PATH:-}"

# Try to extract file path from JSON payload if not set
if [[ -z "$FILE_PATH" && -n "$PAYLOAD" ]]; then
  FILE_PATH=$(echo "$PAYLOAD" | jq -r '.file_path // .input.file_path // empty' 2>/dev/null || true)
fi

if [[ -z "$FILE_PATH" ]]; then
  echo "[format-hook] No file path provided. Skipping."
  exit 0
fi

if [[ ! -f "$FILE_PATH" ]]; then
  echo "[format-hook] File not found: $FILE_PATH. Skipping."
  exit 0
fi

# --------------------------------------------------------------------------
# Helper: check if a command exists
# --------------------------------------------------------------------------
has_cmd() {
  command -v "$1" &>/dev/null
}

# --------------------------------------------------------------------------
# Detect file extension
# --------------------------------------------------------------------------
EXT="${FILE_PATH##*.}"
EXT_LOWER=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')
FORMATTED=false

# --------------------------------------------------------------------------
# JavaScript / TypeScript / CSS / HTML / JSON / Markdown / YAML
# --------------------------------------------------------------------------
case "$EXT_LOWER" in
  js|jsx|ts|tsx|mjs|cjs|css|scss|less|json|md|mdx|yaml|yml|html|vue|svelte|graphql)
    if has_cmd prettier; then
      echo "[format-hook] Formatting with Prettier: $FILE_PATH"
      prettier --write "$FILE_PATH" 2>/dev/null && FORMATTED=true
    elif [[ -f node_modules/.bin/prettier ]]; then
      echo "[format-hook] Formatting with local Prettier: $FILE_PATH"
      node_modules/.bin/prettier --write "$FILE_PATH" 2>/dev/null && FORMATTED=true
    elif has_cmd biome; then
      echo "[format-hook] Formatting with Biome: $FILE_PATH"
      biome format --write "$FILE_PATH" 2>/dev/null && FORMATTED=true
    fi
    ;;
esac

# --------------------------------------------------------------------------
# Python
# --------------------------------------------------------------------------
case "$EXT_LOWER" in
  py|pyi)
    if has_cmd black; then
      echo "[format-hook] Formatting with Black: $FILE_PATH"
      black --quiet "$FILE_PATH" 2>/dev/null && FORMATTED=true
    elif has_cmd ruff; then
      echo "[format-hook] Formatting with Ruff: $FILE_PATH"
      ruff format "$FILE_PATH" 2>/dev/null && FORMATTED=true
    elif has_cmd autopep8; then
      echo "[format-hook] Formatting with autopep8: $FILE_PATH"
      autopep8 --in-place "$FILE_PATH" 2>/dev/null && FORMATTED=true
    fi

    # Also run import sorting if available
    if has_cmd ruff; then
      ruff check --select I --fix "$FILE_PATH" 2>/dev/null || true
    elif has_cmd isort; then
      isort "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

# --------------------------------------------------------------------------
# Go
# --------------------------------------------------------------------------
case "$EXT_LOWER" in
  go)
    if has_cmd goimports; then
      echo "[format-hook] Formatting with goimports: $FILE_PATH"
      goimports -w "$FILE_PATH" 2>/dev/null && FORMATTED=true
    elif has_cmd gofmt; then
      echo "[format-hook] Formatting with gofmt: $FILE_PATH"
      gofmt -w "$FILE_PATH" 2>/dev/null && FORMATTED=true
    fi
    ;;
esac

# --------------------------------------------------------------------------
# Rust
# --------------------------------------------------------------------------
case "$EXT_LOWER" in
  rs)
    if has_cmd rustfmt; then
      echo "[format-hook] Formatting with rustfmt: $FILE_PATH"
      rustfmt "$FILE_PATH" 2>/dev/null && FORMATTED=true
    fi
    ;;
esac

# --------------------------------------------------------------------------
# C / C++
# --------------------------------------------------------------------------
case "$EXT_LOWER" in
  c|h|cpp|hpp|cc|cxx|hxx)
    if has_cmd clang-format; then
      echo "[format-hook] Formatting with clang-format: $FILE_PATH"
      clang-format -i "$FILE_PATH" 2>/dev/null && FORMATTED=true
    fi
    ;;
esac

# --------------------------------------------------------------------------
# Java / Kotlin
# --------------------------------------------------------------------------
case "$EXT_LOWER" in
  java)
    if has_cmd google-java-format; then
      echo "[format-hook] Formatting with google-java-format: $FILE_PATH"
      google-java-format --replace "$FILE_PATH" 2>/dev/null && FORMATTED=true
    fi
    ;;
  kt|kts)
    if has_cmd ktlint; then
      echo "[format-hook] Formatting with ktlint: $FILE_PATH"
      ktlint -F "$FILE_PATH" 2>/dev/null && FORMATTED=true
    fi
    ;;
esac

# --------------------------------------------------------------------------
# Result
# --------------------------------------------------------------------------
if [[ "$FORMATTED" == "true" ]]; then
  echo "[format-hook] Done."
else
  echo "[format-hook] No formatter found for .$EXT_LOWER files. Skipping."
fi

exit 0
