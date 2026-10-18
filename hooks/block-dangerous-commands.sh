#!/usr/bin/env bash
# ============================================================================
# Dangerous Command Guard
# Blocks Bash commands that destroy data or hand the machine to a remote
# script, before Claude runs them:
#
#   - rm -r on /, ~, $HOME, a top-level system directory or a drive root,
#     and any rm with --no-preserve-root
#   - mkfs, dd onto a block device, and Windows `format X:`
#   - the classic fork bomb
#   - chmod / chown -R on /
#   - git push --force without --force-with-lease, and git push --delete
#     of main or master
#   - DROP DATABASE / SCHEMA / TABLE and TRUNCATE sent through a SQL client
#     (psql, mysql, sqlite3, ...)
#   - curl or wget piped into a shell
#
# Exits 2 to block, which is the only code a PreToolUse hook can block with.
# The reason goes to stderr, which is what Claude sees. Exit 0 lets the
# command through.
#
# This is a seatbelt against a model mistake, not a sandbox: a determined
# command can always be written in a shape no pattern list anticipates. Pair
# it with permission rules (`permissions.deny`) for anything that must never
# run.
#
# Event: PreToolUse, matcher "Bash"
# Install: Copy to .claude/hooks/ and add to .claude/settings.json
# Requires: jq
# ============================================================================
set -euo pipefail

# Without jq the command cannot be read, and the guard would wave everything
# through in silence. Exit 1 is a non-blocking error: the command still runs,
# but the transcript shows this line, so the gap is visible.
if ! command -v jq >/dev/null 2>&1; then
  echo "[guard] jq is not installed, so dangerous commands are NOT being checked. Install jq." >&2
  exit 1
fi

PAYLOAD=$(cat 2>/dev/null || true)
COMMAND=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
# Native Windows jq prints CRLF, and $( ) strips only the last newline, so
# every line but the last would end in \r and `rm -rf /\r` would slip past.
COMMAND=${COMMAND//$'\r'/}

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

block() {
  echo "[guard] Blocked: $1" >&2
  echo "[guard] If you really mean it, run the command yourself outside Claude Code." >&2
  exit 2
}

# Case-insensitive matching for the SQL and Windows rules.
LOWER=$(printf '%s' "$COMMAND" | tr '[:upper:]' '[:lower:]')

# --------------------------------------------------------------------------
# Whole-command rules: patterns that span a pipe or a brace group
# --------------------------------------------------------------------------
# :(){ :|:& };:  with or without the spaces
if [[ "$COMMAND" =~ :[[:space:]]*\(\)[[:space:]]*\{[[:space:]]*:[[:space:]]*\|[[:space:]]*:[[:space:]]*\& ]]; then
  block "fork bomb"
fi

# curl https://x | sh, wget -qO- https://x | sudo bash, ... | zsh
if [[ "$LOWER" =~ (curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z|da|k)?sh([[:space:]]|$) ]]; then
  block "piping a downloaded script straight into a shell. Download it, read it, then run it"
fi

# Only when a SQL client is on the line, so a commit message that mentions
# DROP TABLE is not mistaken for running one
SQL_CLIENT='(^|[^a-z])(psql|mysql|mariadb|sqlite3|sqlcmd|duckdb|clickhouse-client|cockroach)([^a-z]|$)'
SQL_DESTRUCTIVE='(drop[[:space:]]+(database|schema|table)|truncate[[:space:]]+(table[[:space:]]+)?[a-z_])'
if [[ "$LOWER" =~ $SQL_CLIENT ]] && [[ "$LOWER" =~ $SQL_DESTRUCTIVE ]]; then
  block "destructive SQL (${BASH_REMATCH[1]}). Run schema changes through a reviewed migration"
fi

# --------------------------------------------------------------------------
# Per-segment rules: split on ; && || | and newlines so that
# `rm -rf build && ls /` is judged as two commands, not one
# --------------------------------------------------------------------------
SEGMENTS=$COMMAND
SEGMENTS=${SEGMENTS//&&/$'\n'}
SEGMENTS=${SEGMENTS//||/$'\n'}
SEGMENTS=${SEGMENTS//;/$'\n'}
SEGMENTS=${SEGMENTS//|/$'\n'}

# A target that would take out the system, the home directory or a drive.
# Quotes are stripped before the comparison.
is_dangerous_target() {
  case "$1" in
    / | /\* | /. | /..) return 0 ;;
    \~ | \~/ | \~/\* | \$HOME | \$HOME/ | \$HOME/\* | \$\{HOME\} | \$\{HOME\}/ | \$\{HOME\}/\*) return 0 ;;
    /bin | /boot | /dev | /etc | /home | /lib | /lib64 | /opt | /root | /sbin | /srv | /sys | /usr | /var) return 0 ;;
    /bin/ | /boot/ | /dev/ | /etc/ | /home/ | /lib/ | /lib64/ | /opt/ | /root/ | /sbin/ | /srv/ | /sys/ | /usr/ | /var/) return 0 ;;
    /Users | /Users/ | /System | /System/ | /Applications | /Applications/) return 0 ;;
    [A-Za-z]: | [A-Za-z]:/ | [A-Za-z]:\\ | [A-Za-z]:/\* | /[a-z] | /[a-z]/ | /[a-z]/\*) return 0 ;;
    *) ;;
  esac
  return 1
}

while IFS= read -r segment; do
  # set -f: a bare * in the command must stay a literal word, not glob the cwd
  set -f
  # shellcheck disable=SC2206
  words=($segment)
  set +f
  [[ ${#words[@]} -eq 0 ]] && continue

  # Skip a leading sudo, env assignments and the `command` / `exec` builtins
  i=0
  while [[ $i -lt ${#words[@]} ]]; do
    case "${words[$i]}" in
      sudo | command | exec | nohup | time) i=$((i + 1)) ;;
      *=*) i=$((i + 1)) ;;
      *) break ;;
    esac
  done
  [[ $i -ge ${#words[@]} ]] && continue
  cmd=${words[$i]##*/}
  rest=("${words[@]:$((i + 1))}")

  case "$cmd" in
    rm)
      recursive=false
      for w in ${rest[@]+"${rest[@]}"}; do
        case "$w" in
          --no-preserve-root) block "rm --no-preserve-root" ;;
          --recursive) recursive=true ;;
          --*) ;;
          -*[rR]*) recursive=true ;;
          *) ;;
        esac
      done
      if [[ "$recursive" == "true" ]]; then
        for w in ${rest[@]+"${rest[@]}"}; do
          target=${w//\"/}
          target=${target//\'/}
          if is_dangerous_target "$target"; then
            block "recursive rm on '$target'"
          fi
        done
      fi
      ;;

    mkfs | mkfs.*)
      block "$cmd formats a filesystem"
      ;;

    dd)
      for w in ${rest[@]+"${rest[@]}"}; do
        case "$w" in
          of=/dev/null | of=/dev/zero) ;;
          of=/dev/*) block "dd writing to a block device ($w)" ;;
          *) ;;
        esac
      done
      ;;

    format | format.com)
      if [[ ${#rest[@]} -gt 0 && "${rest[0]}" =~ ^[A-Za-z]:$ ]]; then
        block "format ${rest[0]}"
      fi
      ;;

    chmod | chown | chgrp)
      recursive=false
      for w in ${rest[@]+"${rest[@]}"}; do
        case "$w" in
          -R | --recursive | -*R*) recursive=true ;;
          *) ;;
        esac
      done
      if [[ "$recursive" == "true" ]]; then
        for w in ${rest[@]+"${rest[@]}"}; do
          if [[ "$w" == "/" || "$w" == "/*" ]]; then
            block "recursive $cmd on /"
          fi
        done
      fi
      ;;

    git)
      [[ ${#rest[@]} -gt 0 ]] || continue
      # Skip global options such as -C dir or -c key=value
      j=0
      while [[ $j -lt ${#rest[@]} ]]; do
        case "${rest[$j]}" in
          -C | -c | --git-dir | --work-tree) j=$((j + 2)) ;;
          -*) j=$((j + 1)) ;;
          *) break ;;
        esac
      done
      [[ $j -lt ${#rest[@]} && "${rest[$j]}" == "push" ]] || continue

      force=false
      lease=false
      delete=false
      for w in "${rest[@]:$((j + 1))}"; do
        case "$w" in
          --force-with-lease* | --force-if-includes) lease=true ;;
          --force | -f) force=true ;;
          --delete | -d) delete=true ;;
          -*) [[ "$w" =~ ^-[a-zA-Z]*f ]] && force=true ;;
          +*) force=true ;;
          :main | :master) block "git push deleting ${w#:}" ;;
          main | master) [[ "$delete" == "true" ]] && block "git push --delete $w" ;;
          *) ;;
        esac
      done
      if [[ "$force" == "true" && "$lease" == "false" ]]; then
        block "git push --force. Use --force-with-lease so you cannot overwrite commits you have not seen"
      fi
      ;;

    *) ;;
  esac
done <<<"$SEGMENTS"

exit 0
