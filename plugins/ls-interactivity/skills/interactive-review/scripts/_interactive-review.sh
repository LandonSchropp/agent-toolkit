#!/usr/bin/env bash

set -euo pipefail

# SQLite database of reviewed commits. The commit hook allows a commit when the current HEAD is
# recorded here, marking the pending work on top of it as reviewed. This script is the only one
# that creates the schema; everything else assumes it exists once a review has been recorded.
DATABASE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-toolkit/reviews.db"

function print_help() {
  echo "Usage: _interactive-review.sh <mode> [<sha>] --output <file>"
  echo
  echo "Opens revdiff to review changes and writes annotations to <file>."
  echo
  echo "Modes:"
  echo
  echo "  working          Review uncommitted changes, including untracked files."
  echo "  staged           Review staged changes only."
  echo "  commit <sha>     Review a single commit's diff (its parent to itself)."
  echo
  echo "Options:"
  echo
  echo "  --output <file>  File revdiff writes annotations to (required)."
  echo "  --help           Show this help message and exit."
}

# Record the current HEAD as reviewed so the commit hook allows a commit built on
# it. Skip when HEAD is unborn, since the first commit has nothing above it.
function record_review() {
  local head

  if ! head="$(git rev-parse --verify --quiet HEAD)"; then
    return 0
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
}

# The disable-review skill suspends the review requirement for a herdr workspace by recording its
# disable time. Treat the requirement as disabled while that time is within the last hour.
function is_review_disabled() {
  [[ -f "$DATABASE" ]] || return 1
  [[ -n "${HERDR_WORKSPACE_ID:-}" ]] || return 1

  [[ -n "$(sqlite3 "$DATABASE" \
    "SELECT 1 FROM overrides
     WHERE workspace = '$HERDR_WORKSPACE_ID'
       AND disabled_at > strftime('%s', 'now') - 3600
     LIMIT 1;" 2>/dev/null)" ]]
}

function review_working() {
  revdiff --untracked --output "$output"
}

function review_staged() {
  revdiff --staged --output "$output"
}

# Diff a single commit against its parent, falling back to the empty tree for a root commit.
function review_commit() {
  local sha base
  sha="${positionals[1]}"

  if ! git rev-parse --verify --quiet "$sha^{commit}" >/dev/null 2>&1; then
    echo "Error: The sha $sha is not a valid commit." >&2
    exit 1
  fi

  if git rev-parse --verify --quiet "$sha^" >/dev/null 2>&1; then
    base="$sha^"
  else
    base="$(git hash-object -t tree /dev/null)"
  fi

  revdiff "$base" "$sha" --output "$output"
}

output=""
positionals=()

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --output)
    output="$2"
    shift 2
    ;;
  -*)
    echo "Error: The option $1 is invalid." >&2
    echo >&2
    print_help >&2
    exit 1
    ;;
  *)
    positionals+=("$1")
    shift
    ;;
  esac
done

if [[ -z "$output" ]]; then
  echo "Error: The --output flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

mode="${positionals[0]:-}"

if [[ -z "$mode" ]]; then
  echo "Error: A mode is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

case "$mode" in
working | staged)
  if [[ "${#positionals[@]}" -gt 1 ]]; then
    echo "Error: The $mode mode does not take a sha." >&2
    echo >&2
    print_help >&2
    exit 1
  fi
  ;;
commit)
  if [[ "${#positionals[@]}" -lt 2 ]]; then
    echo "Error: The commit mode requires a sha." >&2
    echo >&2
    print_help >&2
    exit 1
  fi
  if [[ "${#positionals[@]}" -gt 2 ]]; then
    echo "Error: The commit mode takes a single sha." >&2
    echo >&2
    print_help >&2
    exit 1
  fi
  ;;
*)
  echo "Error: The mode $mode is invalid." >&2
  echo >&2
  print_help >&2
  exit 1
  ;;
esac

# When review is disabled for this session the commit hook already allows commits, so there is
# nothing to review or record.
if is_review_disabled; then
  echo "Review is disabled for this session; skipping the review." >&2
  exit 0
fi

case "$mode" in
working)
  review_working
  record_review
  ;;
staged)
  review_staged
  record_review
  ;;
commit)
  review_commit
  ;;
esac
