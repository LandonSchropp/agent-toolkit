#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: merge-into-main.sh"
  echo
  echo "Rebase the current worktree's branch onto the latest default branch, fast-forward the"
  echo "default branch to it, and push it (when a remote exists)."
  echo
  echo "Run this from inside the linked worktree whose branch you want to land. The default"
  echo "branch must be checked out in another worktree — Git refuses to update a branch that is"
  echo "checked out elsewhere, so the fast-forward runs from that worktree's directory."
  echo
  echo "The branch, default branch, and remote are detected automatically. The working tree"
  echo "must be clean — commit your work before running."
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

# The branch to land is the current branch.
branch=$(git rev-parse --abbrev-ref HEAD)

# A local-only repository (no remote) merges into the default branch without pushing.
if git remote get-url "$remote" >/dev/null 2>&1; then
  remote_exists=true
else
  remote_exists=false
fi

# Detect the default branch: prefer the remote's HEAD, falling back to the branch checked out
# in the main worktree (always the first entry in the worktree list).
if [[ "$remote_exists" == true ]] && remote_head=$(git rev-parse --abbrev-ref "$remote/HEAD" 2>/dev/null); then
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
  echo "Error: The current branch ('$branch') is the default branch; nothing to land." >&2
  exit 1
fi

# Locate the worktree that has the default branch checked out.
main_worktree=$(git worktree list --porcelain | awk -v target="branch refs/heads/$default_branch" '
  /^worktree / { path = substr($0, 10) }
  $0 == target { print path; exit }
')

if [[ -z "$main_worktree" ]]; then
  echo "Error: No worktree has '$default_branch' checked out." >&2
  exit 1
fi

# When a remote exists, bring its view of the default branch up to date (the object store is
# shared across all worktrees) and rebase onto it. Otherwise rebase onto the local branch.
if [[ "$remote_exists" == true ]]; then
  rebase_target="$remote/$default_branch"
  echo "Fetching $remote/$default_branch..." >&2
  git fetch "$remote" "$default_branch"
else
  rebase_target="$default_branch"
fi

# Rebase the branch onto the latest default branch.
echo "Rebasing $branch onto $rebase_target..." >&2
if ! git rebase "$rebase_target" "$branch"; then
  echo "Error: The rebase hit conflicts. Resolve them, finish the rebase, then re-run." >&2
  exit 1
fi

# Fast-forward the default branch to the rebased branch from its own worktree.
echo "Fast-forwarding $default_branch to $branch..." >&2
if ! git -C "$main_worktree" merge --ff-only "$branch"; then
  echo "Error: '$default_branch' could not be fast-forwarded. It has diverging commits." >&2
  exit 1
fi

# Push the updated default branch unless this is a local-only repository.
if [[ "$remote_exists" == true ]]; then
  echo "Pushing $default_branch to $remote..." >&2
  git -C "$main_worktree" push "$remote" "$default_branch"
else
  echo "No '$remote' remote found; skipping push. The merge is local only." >&2
fi
