#!/usr/bin/env bash

set -euo pipefail

# Closes the calling pane's herdr workspace, refusing when it is a main checkout with worktrees
# still open.

if [[ -z "${HERDR_WORKSPACE_ID:-}" ]]; then
  echo "Error: close-workspace.sh must run inside herdr, but \$HERDR_WORKSPACE_ID is not set." >&2
  exit 1
fi

workspace_json=$(herdr workspace get "$HERDR_WORKSPACE_ID")

if jq --exit-status '.result.workspace.worktree.is_linked_worktree == true' <<< "$workspace_json" > /dev/null; then
  herdr worktree remove --workspace "$HERDR_WORKSPACE_ID"
  exit 0
fi

repo_root=$(jq --raw-output '.result.workspace.worktree.repo_root // empty' <<< "$workspace_json")

worktrees=$(herdr workspace list | jq --raw-output --arg root "$repo_root" '
  .result.workspaces[]
  | select(.worktree.repo_root == $root and .worktree.is_linked_worktree == true)
  | "  \(.workspace_id) \(.label) \(.worktree.checkout_path)"
')

if [[ -n "$worktrees" ]]; then
  echo "Error: The workspace $HERDR_WORKSPACE_ID is the main checkout of $repo_root, whose worktrees are still open:" >&2
  echo "$worktrees" >&2
  echo "Closing it closes their tabs too. Have each worktree's own agent close it first." >&2
  exit 1
fi

herdr workspace close "$HERDR_WORKSPACE_ID"
