#!/usr/bin/env bash

set -euo pipefail

readonly SESSIONS_DIRECTORY="$HOME/.claude/sessions"

function print_help() {
  echo "Usage: session-name.sh --workspace <id>"
  echo
  echo "Prints the name that ListAgents and SendMessage use for the Claude Code session"
  echo "running in a herdr workspace."
  echo
  echo "Options:"
  echo
  echo "  --workspace <id>   Workspace whose Claude Code session to name."
  echo "  --help             Show this help message and exit."
  echo
  echo "Exits non-zero when the workspace has no Claude Code session, or more than one."
}

# Parse arguments
workspace=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --workspace)
    workspace="$2"
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

# Validate required arguments
if [[ -z "$workspace" ]]; then
  echo "Error: The --workspace flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

# Map the workspace's Claude Code pane to its registered session name.
session_ids=$(herdr agent list | jq --raw-output --arg id "$workspace" \
  '.result.agents[] | select(.workspace_id == $id and .agent == "claude") | .agent_session.value')

if [[ $(grep --count . <<<"$session_ids") -ne 1 ]]; then
  echo "Error: Workspace $workspace does not have exactly one Claude Code session." >&2
  exit 1
fi

name=$(jq --raw-output --arg id "$session_ids" \
  'select(.sessionId == $id and .name) | .name' "$SESSIONS_DIRECTORY"/*.json)

if [[ -z "$name" ]]; then
  echo "Error: Claude Code has not registered session $session_ids." >&2
  exit 1
fi

echo "$name"
