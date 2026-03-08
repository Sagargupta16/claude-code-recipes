#!/usr/bin/env bash
# ============================================================================
# Task Completion Notification Hook
# Sends a desktop notification when Claude finishes a task.
# Supports macOS (osascript), Linux (notify-send), and Windows (PowerShell).
#
# Install: Copy to .claude/hooks/ and add to .claude/settings.json
# ============================================================================
set -euo pipefail

# --------------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------------
TITLE="Claude Code"
MESSAGE="Task completed."

# Try to read a message from stdin payload
PAYLOAD=$(cat 2>/dev/null || true)
if [[ -n "$PAYLOAD" ]]; then
  TASK_MSG=$(echo "$PAYLOAD" | jq -r '.message // .title // empty' 2>/dev/null || true)
  if [[ -n "$TASK_MSG" ]]; then
    MESSAGE="$TASK_MSG"
  fi
fi

# --------------------------------------------------------------------------
# Detect OS and send notification
# --------------------------------------------------------------------------
send_notification() {
  local title="$1"
  local message="$2"

  case "$(uname -s)" in
    # ------------------------------------------------------------------
    # macOS
    # ------------------------------------------------------------------
    Darwin)
      if command -v osascript &>/dev/null; then
        osascript -e "display notification \"$message\" with title \"$title\" sound name \"Glass\""
        echo "[notify] macOS notification sent."
        return 0
      fi

      # Fallback: terminal-notifier (brew install terminal-notifier)
      if command -v terminal-notifier &>/dev/null; then
        terminal-notifier -title "$title" -message "$message" -sound default
        echo "[notify] terminal-notifier notification sent."
        return 0
      fi
      ;;

    # ------------------------------------------------------------------
    # Linux
    # ------------------------------------------------------------------
    Linux)
      # notify-send (most Linux desktops)
      if command -v notify-send &>/dev/null; then
        notify-send "$title" "$message" --urgency=normal --expire-time=5000
        echo "[notify] Linux notification sent."
        return 0
      fi

      # kdialog (KDE)
      if command -v kdialog &>/dev/null; then
        kdialog --passivepopup "$message" 5 --title "$title"
        echo "[notify] KDE notification sent."
        return 0
      fi

      # zenity (GNOME fallback)
      if command -v zenity &>/dev/null; then
        zenity --notification --text="$title: $message" 2>/dev/null &
        echo "[notify] Zenity notification sent."
        return 0
      fi
      ;;

    # ------------------------------------------------------------------
    # Windows (Git Bash / WSL / MSYS2)
    # ------------------------------------------------------------------
    MINGW*|MSYS*|CYGWIN*)
      if command -v powershell.exe &>/dev/null; then
        powershell.exe -NoProfile -Command "
          [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null;
          \$notify = New-Object System.Windows.Forms.NotifyIcon;
          \$notify.Icon = [System.Drawing.SystemIcons]::Information;
          \$notify.Visible = \$true;
          \$notify.ShowBalloonTip(5000, '$title', '$message', 'Info');
          Start-Sleep -Seconds 6;
          \$notify.Dispose();
        " &>/dev/null &
        echo "[notify] Windows notification sent."
        return 0
      fi
      ;;
  esac

  # ------------------------------------------------------------------
  # Fallback: check for WSL
  # ------------------------------------------------------------------
  if [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
    if command -v powershell.exe &>/dev/null; then
      powershell.exe -NoProfile -Command "
        [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null;
        \$notify = New-Object System.Windows.Forms.NotifyIcon;
        \$notify.Icon = [System.Drawing.SystemIcons]::Information;
        \$notify.Visible = \$true;
        \$notify.ShowBalloonTip(5000, '$title', '$message', 'Info');
        Start-Sleep -Seconds 6;
        \$notify.Dispose();
      " &>/dev/null &
      echo "[notify] WSL notification sent."
      return 0
    fi
  fi

  # ------------------------------------------------------------------
  # Last resort: print to console
  # ------------------------------------------------------------------
  echo "[notify] $title: $message"
  echo "[notify] No notification system found. Message printed to console."
  return 0
}

# --------------------------------------------------------------------------
# Also play a terminal bell as a universal fallback
# --------------------------------------------------------------------------
printf '\a'

# --------------------------------------------------------------------------
# Send the notification
# --------------------------------------------------------------------------
send_notification "$TITLE" "$MESSAGE"

exit 0
