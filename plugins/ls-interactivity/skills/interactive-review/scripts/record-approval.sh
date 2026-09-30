#!/usr/bin/env bash

set -euo pipefail

# SQLite database of reviewed commits.
DATABASE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-toolkit/reviews.db"

function print_help() {
  echo "Usage: record-approval.sh --directory <path>"
  echo
  echo "Records that the user approved the pending changes in a repository, so the"
  echo "commit hook allows a commit built on its current HEAD. Does nothing before"
  echo "the first commit, or for the temporary repository of a 'diff' review."
  echo
  echo "Options:"
  echo
  echo "  --directory <path>  The repository the user approved."
  echo "  --help              Show this help message and exit."
}

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

if [[ -z "$directory" ]]; then
  echo "Error: The --directory flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

cd "$directory"

if ! head="$(git rev-parse --verify --quiet HEAD)"; then
  exit 0
fi

if [[ "$(git config --get --local review.ephemeral)" == "true" ]]; then
  exit 0
fi

mkdir -p "$(dirname "$DATABASE")"

sqlite3 "$DATABASE" "
  CREATE TABLE IF NOT EXISTS reviews (head TEXT PRIMARY KEY NOT NULL);

  CREATE TABLE IF NOT EXISTS overrides (
    workspace   TEXT PRIMARY KEY NOT NULL,
    disabled_at INTEGER NOT NULL
  );

  INSERT OR IGNORE INTO reviews (head) VALUES ('$head');
"
