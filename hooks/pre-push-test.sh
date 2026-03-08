#!/usr/bin/env bash
# ============================================================================
# Pre-push Test Hook
# Runs the project test suite before git push.
# Exits 1 to block the push if any tests fail.
#
# Supported test runners:
#   JavaScript/TypeScript: vitest, jest, mocha, npm test
#   Python: pytest, unittest
#   Go: go test
#   Rust: cargo test
#   Ruby: rspec, rake test
#   Elixir: mix test
#   PHP: phpunit
#
# Install: Copy to .claude/hooks/ and add to .claude/settings.json
# ============================================================================
set -euo pipefail

echo "[test-hook] Running test suite before push..."

# --------------------------------------------------------------------------
# Helper: check if a command exists
# --------------------------------------------------------------------------
has_cmd() {
  command -v "$1" &>/dev/null
}

# --------------------------------------------------------------------------
# Helper: check if a file exists in the project
# --------------------------------------------------------------------------
has_file() {
  [[ -f "$1" ]]
}

TESTS_RAN=false
ERRORS=0

# --------------------------------------------------------------------------
# JavaScript / TypeScript
# --------------------------------------------------------------------------
if has_file "package.json"; then
  # Check for test script in package.json
  TEST_SCRIPT=$(jq -r '.scripts.test // empty' package.json 2>/dev/null || true)

  if has_file "vitest.config.ts" || has_file "vitest.config.js" || has_file "vitest.config.mts"; then
    echo "[test-hook] Detected Vitest. Running tests..."
    if has_cmd vitest; then
      vitest run || ERRORS=1
    elif [[ -f node_modules/.bin/vitest ]]; then
      node_modules/.bin/vitest run || ERRORS=1
    else
      npx vitest run || ERRORS=1
    fi
    TESTS_RAN=true

  elif has_file "jest.config.ts" || has_file "jest.config.js" || has_file "jest.config.mjs" || \
       (has_file "package.json" && jq -e '.jest' package.json &>/dev/null); then
    echo "[test-hook] Detected Jest. Running tests..."
    if has_cmd jest; then
      jest --ci || ERRORS=1
    elif [[ -f node_modules/.bin/jest ]]; then
      node_modules/.bin/jest --ci || ERRORS=1
    else
      npx jest --ci || ERRORS=1
    fi
    TESTS_RAN=true

  elif [[ -n "$TEST_SCRIPT" && "$TEST_SCRIPT" != "echo \"Error: no test specified\" && exit 1" ]]; then
    echo "[test-hook] Running npm test..."
    npm test || ERRORS=1
    TESTS_RAN=true
  fi
fi

# --------------------------------------------------------------------------
# Python
# --------------------------------------------------------------------------
if has_file "pyproject.toml" || has_file "setup.py" || has_file "setup.cfg" || \
   has_file "pytest.ini" || has_file "tox.ini" || has_file "conftest.py"; then

  if has_cmd pytest; then
    echo "[test-hook] Detected pytest. Running tests..."
    pytest --tb=short -q || ERRORS=1
    TESTS_RAN=true
  elif has_cmd python && python -m pytest --version &>/dev/null; then
    echo "[test-hook] Running python -m pytest..."
    python -m pytest --tb=short -q || ERRORS=1
    TESTS_RAN=true
  elif has_cmd python && [[ -d "tests" ]]; then
    echo "[test-hook] Running python -m unittest..."
    python -m unittest discover -s tests -q || ERRORS=1
    TESTS_RAN=true
  fi
fi

# --------------------------------------------------------------------------
# Go
# --------------------------------------------------------------------------
if has_file "go.mod"; then
  echo "[test-hook] Detected Go module. Running tests..."
  go test ./... -count=1 -timeout 120s || ERRORS=1
  TESTS_RAN=true
fi

# --------------------------------------------------------------------------
# Rust
# --------------------------------------------------------------------------
if has_file "Cargo.toml"; then
  echo "[test-hook] Detected Rust project. Running tests..."
  cargo test 2>/dev/null || ERRORS=1
  TESTS_RAN=true
fi

# --------------------------------------------------------------------------
# Ruby
# --------------------------------------------------------------------------
if has_file "Gemfile"; then
  if has_file ".rspec" || [[ -d "spec" ]]; then
    echo "[test-hook] Detected RSpec. Running tests..."
    if has_cmd bundle; then
      bundle exec rspec || ERRORS=1
    elif has_cmd rspec; then
      rspec || ERRORS=1
    fi
    TESTS_RAN=true
  elif has_file "Rakefile" && has_cmd rake; then
    echo "[test-hook] Running rake test..."
    rake test || ERRORS=1
    TESTS_RAN=true
  fi
fi

# --------------------------------------------------------------------------
# Elixir
# --------------------------------------------------------------------------
if has_file "mix.exs"; then
  echo "[test-hook] Detected Elixir project. Running tests..."
  mix test || ERRORS=1
  TESTS_RAN=true
fi

# --------------------------------------------------------------------------
# PHP
# --------------------------------------------------------------------------
if has_file "phpunit.xml" || has_file "phpunit.xml.dist"; then
  echo "[test-hook] Detected PHPUnit. Running tests..."
  if has_file "vendor/bin/phpunit"; then
    vendor/bin/phpunit || ERRORS=1
  elif has_cmd phpunit; then
    phpunit || ERRORS=1
  fi
  TESTS_RAN=true
fi

# --------------------------------------------------------------------------
# Result
# --------------------------------------------------------------------------
if [[ "$TESTS_RAN" == "false" ]]; then
  echo "[test-hook] No test runner detected. Skipping."
  exit 0
fi

if [[ $ERRORS -ne 0 ]]; then
  echo ""
  echo "[test-hook] Tests failed. Push blocked."
  echo "[test-hook] Fix the failing tests and try again."
  exit 1
fi

echo "[test-hook] All tests passed."
exit 0
