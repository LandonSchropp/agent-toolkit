#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

# Repositories to prepare. Entries may be globs; each is expanded against the filesystem, so a
# pattern like obsidian-* prepares every matching repository.
repository_patterns=(
  "$HOME/Development/agent-toolkit"
  "$HOME/Development/orc"
  "$HOME/Development/strength-training"
  "$HOME/Development/homelab"
  "$HOME/Development/landonschropp.com"
  "$HOME/Development/obsidian-*"
  "$HOME/.dotfiles"
)

# Records the default branch as the parent of the checked-out branch when it's a feature branch with
# no parent, so git-town can sync it without prompting for lineage. The parent is written directly to
# config rather than with `git-town set-parent`, which would rebase the branch — that belongs to the
# sync, not here. Prints the repository's path for the caller to sync.
prepare_repository() {
  local repository="$1"
  local name
  name=$(basename "$repository")

  if [[ ! -d "$repository" ]]; then
    echo "$name not found at $repository, skipping..." >&2
    return 0
  fi

  cd "$repository"

  local default_branch current_branch parent
  default_branch=$(git default-branch)
  current_branch=$(git branch --show-current)
  parent=$(git-town config get-parent)

  if [[ "$current_branch" != "$default_branch" && -z "$parent" ]]; then
    echo "Recording $default_branch as the parent of $current_branch in $name..." >&2
    git config "git-town-branch.$current_branch.parent" "$default_branch"
  fi

  echo "$repository"
}

for pattern in "${repository_patterns[@]}"; do
  # shellcheck disable=SC2086
  for repository in $pattern; do
    prepare_repository "$repository"
  done
done
