#!/usr/bin/env bash

set -euo pipefail

readonly TIMEOUT_SECONDS=30
readonly SETTLE_SECONDS=8
readonly MAX_LABEL_LENGTH=16

function print_help() {
  echo "Usage: open-workspace.sh --project <name> --branch <branch> --label <label>"
  echo
  echo "Opens a project's Git worktree as a herdr workspace, labels the workspace, waits for"
  echo "its agent to become ready, and prints the workspace id."
  echo
  echo "Options:"
  echo
  echo "  --project <name>   Project to open, as named by 'herdr-project list'."
  echo "  --branch <branch>  Branch to create the worktree on."
  echo "  --label <label>    Workspace label, at most $MAX_LABEL_LENGTH characters."
  echo "  --help             Show this help message and exit."
}

# Prints the workspace id for the project's worktree on the branch, if one is open.
function find_workspace() {
  herdr worktree list --cwd "$repo_root" | jq --raw-output --arg branch "$branch" \
    'first(.result.worktrees[] | select(.branch == $branch) | .open_workspace_id // empty) // empty'
}

# Prints the pane id of the agent running in the given workspace, if any.
function find_agent() {
  local workspace_id="$1"

  herdr agent list | jq --raw-output --arg id "$workspace_id" \
    'first(.result.agents[] | select(.workspace_id == $id) | .pane_id) // empty'
}

# Parse arguments
project=""
branch=""
label=""

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
  --branch)
    branch="$2"
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

# Validate required arguments
if [[ -z "$project" ]]; then
  echo "Error: The --project flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

if [[ -z "$branch" ]]; then
  echo "Error: The --branch flag is required." >&2
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

if [[ "${#label}" -gt "$MAX_LABEL_LENGTH" ]]; then
  echo "Error: The label $label is longer than $MAX_LABEL_LENGTH characters." >&2
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

herdr-project open --project "$project" --worktree "$branch" --no-focus

workspace_id=""
pane_id=""

for ((second = 0; second < TIMEOUT_SECONDS; second++)); do
  workspace_id=$(find_workspace)

  if [[ -n "$workspace_id" ]]; then
    pane_id=$(find_agent "$workspace_id")

    if [[ -n "$pane_id" ]]; then
      break
    fi
  fi

  sleep 1
done

if [[ -z "$workspace_id" ]]; then
  echo "Error: No workspace opened for $branch in $project within ${TIMEOUT_SECONDS}s." >&2
  exit 1
fi

if [[ -z "$pane_id" ]]; then
  echo "Error: Workspace $workspace_id opened, but no agent started for $branch in $project within ${TIMEOUT_SECONDS}s." >&2
  exit 1
fi

herdr workspace rename "$workspace_id" "$label" >/dev/null

# A new agent reports `unknown` until its TUI settles.
if ! herdr agent wait "$pane_id" --until idle --timeout "$((TIMEOUT_SECONDS * 1000))" >/dev/null; then
  echo "Error: The agent in pane $pane_id was not ready within ${TIMEOUT_SECONDS}s." >&2
  exit 1
fi

# herdr reports idle before the agent can accept a prompt (herdrdev/herdr#3132).
sleep "$SETTLE_SECONDS"

echo "$workspace_id"
