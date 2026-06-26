#!/usr/bin/env bash

set -euo pipefail

# File of reviewed commits. The commit hook allows a commit when the current HEAD appears here,
# marking the pending work on top of it as reviewed.
REVIEWS_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-toolkit/reviews.txt"

function print_help() {
  echo "Usage: review.sh <mode> [<sha>] --output <file>"
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

  mkdir -p "$(dirname "$REVIEWS_FILE")"

  if [[ -f "$REVIEWS_FILE" ]] && grep -qxF "$head" "$REVIEWS_FILE"; then
    return 0
  fi

  echo "$head" >>"$REVIEWS_FILE"
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

case "$mode" in
working)
  revdiff --untracked --output "$output"
  record_review
  ;;
staged)
  revdiff --staged --output "$output"
  record_review
  ;;
commit)
  sha="${positionals[1]}"

  if ! git rev-parse --verify --quiet "$sha^{commit}" >/dev/null 2>&1; then
    echo "Error: The sha $sha is not a valid commit." >&2
    exit 1
  fi

  # Diff the commit against its parent. A root commit has no parent, so fall back to the empty tree.
  if git rev-parse --verify --quiet "$sha^" >/dev/null 2>&1; then
    base="$sha^"
  else
    base="$(git hash-object -t tree /dev/null)"
  fi

  revdiff "$base" "$sha" --output "$output"
  ;;
esac
