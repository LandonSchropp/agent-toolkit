#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: show-stack-commits.sh [options]"
  echo
  echo "Prints commits unique to the current branch compared with the default"
  echo "branch. Useful for atomic-commit planning."
  echo
  echo "Options:"
  echo
  echo "  --help    Show this help message and exit."
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

default_branch=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || echo main)
current_branch=$(git branch --show-current)

if [[ -z "$current_branch" ]]; then
  echo "Error: Not on a branch (detached HEAD state)." >&2
  exit 1
fi

if [[ "$current_branch" == "$default_branch" ]]; then
  echo "On default branch ($default_branch) — no stack to walk."
  exit 0
fi

echo "=== $current_branch (relative to: $default_branch) ==="
git log --oneline "$default_branch..$current_branch"
