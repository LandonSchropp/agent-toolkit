#!/usr/bin/env bash

set -euo pipefail

readonly TIMEOUT_SECONDS=30
readonly SETTLE_SECONDS=8

function print_help() {
  echo "Usage: open-workspace.sh --project <name> --worktree <branch>"
  echo
  echo "Opens a project's Git worktree as a herdr workspace, waits for its agent to become"
  echo "ready, and prints the workspace id."
  echo
  echo "Options:"
  echo
  echo "  --project <name>     Project to open, as named by 'herdr-project list'."
  echo "  --worktree <branch>  Branch to create the worktree on."
  echo "  --help               Show this help message and exit."
}

# Prints "<workspace id> <pane id>" for the project's worktree on the branch, if its agent is running.
function find_agent() {
  local workspace_id checkout_path

  while read -r workspace_id checkout_path; do
    if [[ "$(git -C "$checkout_path" rev-parse --abbrev-ref HEAD 2>/dev/null || true)" != "$worktree" ]]; then
      continue
    fi

    herdr agent list | jq --raw-output --arg id "$workspace_id" \
      'first(.result.agents[] | select(.workspace_id == $id) | "\($id) \(.pane_id)") // empty'

    return 0
  done < <(herdr workspace list | jq --raw-output --arg root "$repo_root" '
    .result.workspaces[]
    | select(.worktree.repo_root == $root and .worktree.is_linked_worktree == true)
    | "\(.workspace_id) \(.worktree.checkout_path)"
  ')
}

# Parse arguments
project=""
worktree=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --project)
    project="$2"
    shift 2
    ;;
  --worktree)
    worktree="$2"
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
if [[ -z "$project" ]]; then
  echo "Error: The --project flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

if [[ -z "$worktree" ]]; then
  echo "Error: The --worktree flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

repo_root=$(herdr-project list --json | jq --raw-output --arg name "$project" \
  'first(.[] | select(.name == $name) | .path) // empty')

if [[ -z "$repo_root" ]]; then
  echo "Error: The project $project is not configured. Run 'herdr-project list' to see the projects." >&2
  exit 1
fi

herdr-project open "$project" --worktree "$worktree"

agent=""

for ((second = 0; second < TIMEOUT_SECONDS; second++)); do
  agent=$(find_agent)

  if [[ -n "$agent" ]]; then
    break
  fi

  sleep 1
done

if [[ -z "$agent" ]]; then
  echo "Error: No agent started for $worktree in $project within ${TIMEOUT_SECONDS}s." >&2
  exit 1
fi

read -r workspace_id pane_id <<< "$agent"

# A new agent reports `unknown` until its TUI settles.
if ! herdr agent wait "$pane_id" --until idle --timeout "$((TIMEOUT_SECONDS * 1000))" > /dev/null; then
  echo "Error: The agent in pane $pane_id was not ready within ${TIMEOUT_SECONDS}s." >&2
  exit 1
fi

# herdr reports idle before the agent can accept a prompt (herdrdev/herdr#3132).
sleep "$SETTLE_SECONDS"

echo "$workspace_id"
