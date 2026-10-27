#!/usr/bin/env bash

set -euo pipefail

poll_interval=10

function print_help() {
  echo "Usage: wait-for-pull-request-to-be-merged.sh [options]"
  echo
  echo "Poll a pull request until its state becomes MERGED."
  echo
  echo "Useful after triggering a merge queue, where the merge completes"
  echo "asynchronously. Exits 0 when merged. Exits 1 if the pull request"
  echo "is closed, or is open but not in the merge queue."
  echo
  echo "Options:"
  echo
  echo "  --pull-request-url <url>   URL or number of the pull request."
  echo "  --help                     Show this help message and exit."
}

pull_request_url=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --pull-request-url)
    pull_request_url="$2"
    shift 2
    ;;
  *)
    echo "Error: Unknown option: $1" >&2
    echo >&2
    print_help >&2
    exit 1
    ;;
  esac
done

if [[ -z "$pull_request_url" ]]; then
  echo "Error: --pull-request-url is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

pull_request_id=$(gh pr view "$pull_request_url" --json id --jq '.id')

# shellcheck disable=SC2016 # GraphQL variables, not shell expansions.
query='
  query($id: ID!) {
    node(id: $id) {
      ... on PullRequest {
        state
        mergeQueueEntry { state position }
        autoMergeRequest { enabledAt }
      }
    }
  }
'

previous_status=""

while true; do
  status=$(gh api graphql --raw-field query="$query" --raw-field id="$pull_request_id" \
    --jq '.data.node |
      if .state != "OPEN" then .state
      elif .mergeQueueEntry != null then "QUEUED \(.mergeQueueEntry.state) at position \(.mergeQueueEntry.position)"
      elif .autoMergeRequest != null then "WAITING_FOR_CHECKS"
      else "NOT_QUEUED"
      end')

  if [[ "$status" == "MERGED" ]]; then
    echo "Pull request merged." >&2
    exit 0
  fi

  if [[ "$status" == "CLOSED" ]]; then
    echo "Error: Pull request was closed without merging." >&2
    exit 1
  fi

  if [[ "$status" == "NOT_QUEUED" ]]; then
    echo "Error: Pull request is not in the merge queue." >&2
    exit 1
  fi

  if [[ "$status" != "$previous_status" ]]; then
    echo "Waiting for merge (${status})..." >&2
    previous_status="$status"
  fi

  sleep "$poll_interval"
done
