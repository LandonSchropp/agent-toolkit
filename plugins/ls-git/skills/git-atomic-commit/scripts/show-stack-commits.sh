#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: show-stack-commits.sh [options]"
  echo
  echo "Walks up the git-town parent chain from the current branch and prints"
  echo "commits unique to each branch in the stack. Useful for atomic-commit"
  echo "planning when an edit may target a commit on a parent branch."
  echo
  echo "Falls back to the repository's default branch if git-town is not"
  echo "configured or returns no parent."
  echo
  echo "Options:"
  echo
  echo "  --help    Show this help message and exit."
}

function get_parent_branch() {
  local branch="$1"
  local parent

  parent=$(git town config get-parent "$branch" 2>/dev/null || true)

  if [[ -n "$parent" ]]; then
    echo "$parent"
    return 0
  fi

  git default-branch 2>/dev/null
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

default_branch=$(git default-branch 2>/dev/null || echo main)
current_branch=$(git branch --show-current)

if [[ -z "$current_branch" ]]; then
  echo "Error: Not on a branch (detached HEAD state)." >&2
  exit 1
fi

if [[ "$current_branch" == "$default_branch" ]]; then
  echo "On default branch ($default_branch) — no stack to walk."
  exit 0
fi

branch="$current_branch"

while [[ -n "$branch" && "$branch" != "$default_branch" ]]; do
  parent=$(get_parent_branch "$branch")

  if [[ -z "$parent" ]]; then
    echo "Error: Could not determine parent of $branch." >&2
    exit 1
  fi

  echo "=== $branch (parent: $parent) ==="
  git log --oneline "$parent..$branch"
  echo

  branch="$parent"
done
