#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: start-listening.sh --session <id>"
  echo
  echo "Turns on the plugin's dispatch-events hook for a Claude Code session. From the session's"
  echo "next stop on, the hook wakes it when a workspace registered with track-workspace.sh closes."
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

mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/agent-toolkit/ls-agent/dispatch/$session"
