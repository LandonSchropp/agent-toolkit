#!/usr/bin/env bash

set -euo pipefail

# Closes the calling pane's herdr workspace, removing its worktree first when the
# workspace owns one. Never passes --force, so a dirty working tree stops it.

if [[ -z "${HERDR_WORKSPACE_ID:-}" ]]; then
  echo "Error: close-workspace.sh must run inside herdr, but \$HERDR_WORKSPACE_ID is not set." >&2
  exit 1
fi

# A herdr-managed worktree is removed with its workspace; a plain workspace owns
# no checkout to remove. Either way, expect this to terminate the workspace,
# taking this script's pane with it.
if herdr workspace get "$HERDR_WORKSPACE_ID" | jq -e '.result.workspace.worktree.is_linked_worktree == true' >/dev/null; then
  herdr worktree remove --workspace "$HERDR_WORKSPACE_ID"
else
  herdr workspace close "$HERDR_WORKSPACE_ID"
fi
