#!/usr/bin/env bash
# ============================================================================
# Secret Scan Hook
# Blocks an Edit or Write that would put a live credential into a file:
# cloud keys, API tokens and private keys. Runs before the tool, so the
# secret never reaches the disk, and a later commit cannot leak it.
#
# Detects:
#   AWS access key IDs, GitHub tokens (classic and fine-grained), Slack
#   tokens, Stripe live secret keys, Google API keys, Anthropic and OpenAI
#   API keys, and PEM private key blocks.
#
# The block message names the rule and the file, never the matched value:
# stderr goes back into the conversation, and echoing the secret there would
# leak it into the transcript instead.
#
# Exits 2 to block, which is the only code a PreToolUse hook can block with.
# Exit 0 lets the edit through.
#
# Event: PreToolUse, matcher "Edit|Write|NotebookEdit"
# Install: Copy to .claude/hooks/ and add to .claude/settings.json
# Requires: jq
# ============================================================================
set -euo pipefail

# Without jq the edit cannot be read, and the scan would pass everything in
# silence. Exit 1 is a non-blocking error: the edit still goes through, but
# the transcript shows this line, so the gap is visible.
if ! command -v jq >/dev/null 2>&1; then
  echo "[secret-scan] jq is not installed, so edits are NOT being scanned for secrets. Install jq." >&2
  exit 1
fi

PAYLOAD=$(cat 2>/dev/null || true)
[[ -n "$PAYLOAD" ]] || exit 0

# The text a tool is about to write lives in a different field per tool:
#   Write        .tool_input.content
#   Edit         .tool_input.new_string
#   NotebookEdit .tool_input.new_source
# .edits[] covers a multi-edit payload, which batches several new_strings.
CONTENT=$(printf '%s' "$PAYLOAD" | jq -r '
  [ .tool_input.content,
    .tool_input.new_string,
    .tool_input.new_source,
    (.tool_input.edits[]?.new_string) ]
  | map(select(type == "string")) | join("\n")
' 2>/dev/null || true)
FILE_PATH=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.file_path // .tool_input.notebook_path // "the file"' 2>/dev/null || true)

[[ -n "$CONTENT" ]] || exit 0

# Placeholders that documentation uses on purpose. AWS publishes this key ID
# as its example value, so it is safe to write.
CONTENT=${CONTENT//AKIAIOSFODNN7EXAMPLE/}

# rule name | extended regex
RULES='AWS access key ID|(A3T[A-Z0-9]|AKIA|ASIA|ABIA|ACCA)[A-Z0-9]{16}
GitHub token|gh[pousr]_[A-Za-z0-9]{36,}
GitHub fine-grained token|github_pat_[A-Za-z0-9_]{60,}
Slack token|xox[abposr]-[0-9A-Za-z-]{10,}
Stripe live secret key|[rs]k_live_[0-9A-Za-z]{20,}
Google API key|AIza[0-9A-Za-z_-]{35}
Anthropic API key|sk-ant-[A-Za-z0-9_-]{32,}
OpenAI API key|sk-(proj|svcacct|admin)-[A-Za-z0-9_-]{32,}
Private key|-----BEGIN ([A-Z0-9]+ )?PRIVATE KEY( BLOCK)?-----'

FOUND=""
while IFS='|' read -r name regex; do
  [[ -n "$name" ]] || continue
  if printf '%s' "$CONTENT" | grep -qE -- "$regex"; then
    FOUND="${FOUND}  - ${name}"$'\n'
  fi
done <<<"$RULES"

if [[ -n "$FOUND" ]]; then
  {
    echo "[secret-scan] Blocked: the edit to $FILE_PATH contains what looks like a secret:"
    printf '%s' "$FOUND"
    echo "[secret-scan] Read it from an environment variable or a secrets manager instead."
    echo "[secret-scan] If it is a test fixture, build the value at runtime so no real-looking key sits in the file."
  } >&2
  exit 2
fi

exit 0
