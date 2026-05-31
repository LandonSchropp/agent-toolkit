#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: push-feature-branch.sh"
  echo
  echo "Rebase the current worktree's branch onto the latest default branch and push it, ready"
  echo "for a pull request. The branch, default branch, and remote are detected automatically."
  echo
  echo "Pushes with --force-with-lease so a re-push after rebasing is safe — it refuses if the"
  echo "remote branch advanced unexpectedly. The working tree must be clean — commit first."
  echo
  echo "Options:"
  echo
  echo "  --help   Show this help message and exit."
}

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

remote="origin"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: Not inside a Git repository." >&2
  exit 1
fi

# Refuse to run with uncommitted changes — the work must already be committed.
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: The working tree has uncommitted changes. Commit your work first." >&2
  exit 1
fi

# A feature-branch push needs somewhere to push to.
if ! git remote get-url "$remote" >/dev/null 2>&1; then
  echo "Error: No '$remote' remote found. A feature-branch push requires a remote." >&2
  exit 1
fi

branch=$(git rev-parse --abbrev-ref HEAD)

# Detect the default branch: prefer the remote's HEAD, falling back to the branch checked out
# in the main worktree (always the first entry in the worktree list).
if remote_head=$(git rev-parse --abbrev-ref "$remote/HEAD" 2>/dev/null); then
  default_branch="${remote_head#"$remote"/}"
else
  default_branch=$(git worktree list --porcelain | awk '
    /^worktree / { count++ }
    count == 1 && /^branch / { sub(/^branch refs\/heads\//, ""); print; exit }
  ')
fi

if [[ -z "$default_branch" ]]; then
  echo "Error: Could not determine the default branch." >&2
  exit 1
fi

if [[ "$branch" == "$default_branch" ]]; then
  echo "Error: The current branch ('$branch') is the default branch; nothing to push." >&2
  exit 1
fi

# Bring the remote's view of the default branch up to date and rebase onto it.
echo "Fetching $remote/$default_branch..." >&2
git fetch "$remote" "$default_branch"

echo "Rebasing $branch onto $remote/$default_branch..." >&2
if ! git rebase "$remote/$default_branch" "$branch"; then
  echo "Error: The rebase hit conflicts. Resolve them, finish the rebase, then re-run." >&2
  exit 1
fi

# Push the branch for a pull request. --force-with-lease keeps a post-rebase re-push safe.
echo "Pushing $branch to $remote..." >&2
git push --force-with-lease --set-upstream "$remote" "$branch"
