#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: archive-issue.sh [options]"
  echo
  echo "Archives a Multica issue's inbox notifications, so the issue leaves the"
  echo "user's inbox. Runs inside a Multica task, which provides the server URL,"
  echo "workspace and task token."
  echo
  echo "Options:"
  echo
  echo "  --issue <issue>    The issue's identifier or UUID."
  echo "  --help             Show this help message and exit."
}

# Parse arguments
issue=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --issue)
    issue="$2"
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
if [[ -z "$issue" ]]; then
  echo "Error: The --issue flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

for variable in MULTICA_TOKEN MULTICA_WORKSPACE_ID MULTICA_SERVER_URL; do
  if [[ -z "${!variable:-}" ]]; then
    echo "Error: The $variable environment variable is not set. Run this inside a Multica task." >&2
    exit 1
  fi
done

# The CLI has no inbox commands, but the task token acts as the user against the API.
function api() {
  curl --silent --show-error --fail \
    --header "Authorization: Bearer $MULTICA_TOKEN" \
    --header "X-Workspace-ID: $MULTICA_WORKSPACE_ID" \
    "$@"
}

# Inbox notifications carry the issue's UUID, not its identifier.
issue_id=$(multica issue get "$issue" | jq --exit-status --raw-output .id)

item_id=$(
  api "$MULTICA_SERVER_URL/api/inbox" |
    jq --raw-output --arg issue_id "$issue_id" 'first(.[] | select(.issue_id == $issue_id)) | .id'
)

if [[ -z "$item_id" ]]; then
  echo "The issue has no inbox notifications to archive."
  exit 0
fi

# Archiving one notification archives every notification for the same issue.
api --request POST "$MULTICA_SERVER_URL/api/inbox/$item_id/archive" >/dev/null
echo "Archived the issue's inbox notifications."
