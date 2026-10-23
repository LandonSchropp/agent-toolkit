#!/usr/bin/env bash

set -euo pipefail

poll_interval=10
max_attempts=18

function print_help() {
  echo "Usage: read-review-channels.sh [options]"
  echo
  echo "Wait for a pull request's \"PR Review Channels\" bot comment, then print"
  echo "the pull request's title, URL, additions, deletions and review channels"
  echo "as JSON. The bot only comments on pull requests that aren't drafts."
  echo
  echo "Exits 1 if no comment appears within three minutes."
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
    echo "Error: The option $1 is invalid." >&2
    echo >&2
    print_help >&2
    exit 1
    ;;
  esac
done

if [[ -z "$pull_request_url" ]]; then
  echo "Error: The --pull-request-url flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

# Channels live in `<!-- pr-review-channels:v1 {"channels":[...]} -->`.
# shellcheck disable=SC2016
query='
  (.comments | map(select(.body | contains("pr-review-channels:v1"))) | last) as $comment
  | if $comment == null then empty else {
      title,
      url,
      additions,
      deletions,
      channels: ($comment.body | capture("pr-review-channels:v1\\s*(?<json>\\{.*\\})").json | fromjson | .channels)
    } end
'

for ((attempt = 1; attempt <= max_attempts; attempt++)); do
  output=$(gh pr view "$pull_request_url" --json title,url,additions,deletions,comments --jq "$query")

  if [[ -n "$output" ]]; then
    echo "$output"
    exit 0
  fi

  echo "Waiting for the PR Review Channels comment..." >&2
  sleep "$poll_interval"
done

echo "Error: No PR Review Channels comment appeared on the pull request." >&2
exit 1
