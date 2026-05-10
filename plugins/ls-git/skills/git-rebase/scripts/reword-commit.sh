#!/usr/bin/env bash

set -euo pipefail

sha=""
message=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --sha)
    sha="$2"
    shift 2
    ;;
  --message)
    message="$2"
    shift 2
    ;;
  *)
    echo "Error: The option $1 is invalid." >&2
    exit 1
    ;;
  esac
done

if [[ -z "$sha" ]]; then
  echo "Error: The --sha flag is required." >&2
  exit 1
fi

if [[ -z "$message" ]]; then
  echo "Error: The --message flag is required." >&2
  exit 1
fi

script_directory="$(cd "$(dirname "$0")" && pwd)"

plan=$(
  git log --oneline --reverse "$sha^..HEAD" |
    awk -v sha="$sha" '{print ($1 == sha ? "reword" : "pick"), $0}'
)

message_file=$(mktemp /tmp/git-reword-message.XXXXXX)
cleanup() { rm -f "$message_file"; }
trap cleanup EXIT

printf '%s\n' "$message" >"$message_file"

GIT_REBASE_MESSAGE_FILE="$message_file" \
  GIT_EDITOR="$script_directory/commit-message-editor.sh" \
  "$script_directory/non-interactive-git-rebase.sh" "$sha^" \
  <<<"$plan"
