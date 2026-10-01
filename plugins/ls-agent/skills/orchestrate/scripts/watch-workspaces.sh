#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: watch-workspaces.sh"
  echo
  echo "Polls herdr every few seconds and prints a line each time a workspace opens or closes,"
  echo "such as \"Closed: <label>\". Runs until it is killed."
  echo
  echo "Options:"
  echo
  echo "  --help              Show this help message and exit."
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  *)
    echo "Error: The option $1 is invalid." >&2
    echo >&2
    print_help >&2
    exit 1
    ;;
  esac
done

function list_workspaces() {
  herdr workspace list | jq --raw-output '.result.workspaces[] | "\(.workspace_id) \(.label)"' | sort --key=1,1
}

previous="$(list_workspaces)"

while true; do
  sleep 5

  current="$(list_workspaces)" || continue

  join -v 1 <(echo "$previous") <(echo "$current" | cut -d ' ' -f 1) |
    cut -d ' ' -f 2- |
    sed 's/^/Closed: /'

  join -v 1 <(echo "$current") <(echo "$previous" | cut -d ' ' -f 1) |
    cut -d ' ' -f 2- |
    sed 's/^/Opened: /'

  previous="$current"
done
