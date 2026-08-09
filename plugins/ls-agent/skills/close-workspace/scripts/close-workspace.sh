#!/usr/bin/env bash

set -euo pipefail

# Closes the calling pane's herdr workspace.

if [[ -z "${HERDR_WORKSPACE_ID:-}" ]]; then
  echo "Error: close-workspace.sh must run inside herdr, but \$HERDR_WORKSPACE_ID is not set." >&2
  exit 1
fi

if herdr workspace get "$HERDR_WORKSPACE_ID" | jq -e '.result.workspace.worktree.is_linked_worktree == true' >/dev/null; then
  herdr worktree remove --workspace "$HERDR_WORKSPACE_ID"
else
  herdr workspace close "$HERDR_WORKSPACE_ID"
fi
