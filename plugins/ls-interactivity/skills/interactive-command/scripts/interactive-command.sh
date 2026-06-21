#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: interactive-command.sh --command '<command>' --name <name>"
  echo
  echo "Opens '<command>' in a new tmux window named <name>, next to the calling"
  echo "pane's window and in its session, then blocks until the window closes. The"
  echo "command runs with no shell, so the window closes as soon as it exits, and"
  echo "the command persists its own result. The window is foregrounded only if"
  echo "the user is currently looking at the calling pane. Must run inside tmux."
  echo
  echo "Options:"
  echo
  echo "  --command '<command>'   Command to run, given as a single string."
  echo "  --name <name>           Name for the new window's tab."
  echo "  --help                  Show this help message and exit."
}

command=""
name=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --command)
    command="$2"
    shift 2
    ;;
  --name)
    name="$2"
    shift 2
    ;;
  *)
    echo "Error: The option $1 is invalid." >&2
    echo >&2
    print_help >&2
    exit 1
    ;;
  esac
done

if [[ -z "$command" ]]; then
  echo "Error: The --command flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

if [[ -z "$name" ]]; then
  echo "Error: The --name flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

if [[ -z "${TMUX_PANE:-}" ]]; then
  echo "Error: interactive-command.sh must run inside tmux, but \$TMUX_PANE is not set." >&2
  exit 1
fi

# Anchor the new window to the caller's window so it lands right after it, in the
# caller's session.
target_window="$(tmux display-message -p -t "$TMUX_PANE" '#{window_id}')"

# Note whether the user is currently looking at the calling pane, before opening
# anything, so we only pull them to the new window if they're actually watching.
read -r caller_pane_active caller_window_active caller_session_attached < <(
  tmux display-message -p -t "$TMUX_PANE" '#{pane_active} #{window_active} #{session_attached}'
)

# Open the command in a background window (-d). Capture the window id (to watch)
# and pane id (to configure).
read -r window pane < <(
  tmux new-window -d -a -t "$target_window" -P -F '#{window_id} #{pane_id}' -n "$name" "$command"
)

# Force the pane to close when the command exits, regardless of the user's
# remain-on-exit setting, so the window's disappearance is an unambiguous signal.
tmux set-option -p -t "$pane" remain-on-exit off 2>/dev/null || true

# Bring the new window to the foreground only if the user is currently looking at
# the calling pane; otherwise leave it in the background so we don't pull them
# away from whatever they're doing.
if [[ "$caller_pane_active" == "1" && "$caller_window_active" == "1" && "$caller_session_attached" -ge 1 ]]; then
  tmux select-window -t "$window"
fi

# Block until the window is gone (the command finished or the user closed it).
while tmux list-windows -a -F '#{window_id}' 2>/dev/null | grep -Fxq "$window"; do
  sleep 0.3
done
