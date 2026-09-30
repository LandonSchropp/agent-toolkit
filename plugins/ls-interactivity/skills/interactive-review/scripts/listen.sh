#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: listen.sh --directory <path>"
  echo
  echo "Prints each decision the user makes in the Hunk review of <path>, one line at a time, the way"
  echo "'hunk review listen' does. On an approval made while the user is still on the review tab, it"
  echo "also switches them back to the calling agent's tab, leaving the review open."
  echo
  echo "Options:"
  echo
  echo "  --directory <path>     The repository interactive-review.sh printed."
  echo "  --help                 Show this help message and exit."
}

# Parse arguments
directory=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --directory)
    directory="$2"
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
if [[ -z "$directory" ]]; then
  echo "Error: The --directory flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

# Switches to the agent's tab, but only while the user is looking at the review tab. Focusing a tab
# also brings its workspace on screen, so a user who has moved on is left alone.
function return_to_agent_tab() {
  local review_focused

  review_focused="$(
    herdr tab list --workspace "$HERDR_WORKSPACE_ID" |
      jq --raw-output '.result.tabs[] | select(.label == "review") | .focused'
  )"

  [[ "$review_focused" == "true" ]] || return 0

  herdr tab focus "$HERDR_TAB_ID" >/dev/null
}

hunk review listen --repo "$directory" | while IFS= read -r line; do
  echo "$line"

  if [[ "$line" == "review-approved" ]]; then
    return_to_agent_tab </dev/null
  fi
done
