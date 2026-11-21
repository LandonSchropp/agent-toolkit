#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: track-workspace.sh --session <id> --workspace <id> --label <label>"
  echo
  echo "Registers a herdr workspace with the plugin's orchestrate-events hook, which wakes the"
  echo "session once when the workspace closes. Run start-listening.sh for the session first."
  echo
  echo "Options:"
  echo
  echo "  --session <id>    The Claude Code session that started the workspace."
  echo "  --workspace <id>  The workspace's ID, as open-workspace.sh prints it."
  echo "  --label <label>   The workspace's label, which the hook reports it by."
  echo "  --help            Show this help message and exit."
}

session=""
workspace=""
label=""

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
  --workspace)
    workspace="$2"
    shift 2
    ;;
  --label)
    label="$2"
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

if [[ -z "$workspace" ]]; then
  echo "Error: The --workspace flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

if [[ -z "$label" ]]; then
  echo "Error: The --label flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

state="${XDG_STATE_HOME:-$HOME/.local/state}/agent-toolkit/ls-agent/orchestrate/$session"

if [[ ! -d "$state" ]]; then
  echo "Error: The session isn't listening. Run start-listening.sh first." >&2
  exit 1
fi

echo "$workspace $label" >>"$state/workspaces"
