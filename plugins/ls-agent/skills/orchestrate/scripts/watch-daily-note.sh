#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: watch-daily-note.sh --session <id>"
  echo
  echo "Adds today's daily note to what the plugin's dispatch-events hook watches for a session. The"
  echo "hook then wakes it when an unchecked task that isn't in today's note yet appears there, and"
  echo "for every task in a new day's note. Run the dispatch skill's start-listening.sh for the"
  echo "session first."
  echo
  echo "Options:"
  echo
  echo "  --session <id>  The Claude Code session to wake."
  echo "  --help          Show this help message and exit."
}

session=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --session)
    session="$2"
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

if [[ -z "$session" ]]; then
  echo "Error: The --session flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

state="${XDG_STATE_HOME:-$HOME/.local/state}/agent-toolkit/ls-agent/dispatch/$session"
note="$HOME/Notes/Daily Notes/$(date +%Y/%Y-%m/%Y-%m-%d) - Daily Note.md"

if [[ ! -d "$state" ]]; then
  echo "Error: The session isn't listening. Run the dispatch skill's start-listening.sh first." >&2
  exit 1
fi

# The hook reports only the tasks that aren't in this list.
if [[ -f "$note" ]]; then
  sed -n 's/^- \[ \] //p' "$note" | sort --unique
fi >"$state/tasks-$(date +%Y-%m-%d)"

touch "$state/watch-daily-note"
