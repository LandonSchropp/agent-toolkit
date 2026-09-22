#!/usr/bin/env bash

set -euo pipefail

# Closes the calling pane's herdr workspace, removing its worktree first when it owns one.

if [[ -z "${HERDR_WORKSPACE_ID:-}" ]]; then
  echo "Error: close-workspace.sh must run inside herdr, but \$HERDR_WORKSPACE_ID is not set." >&2
  exit 1
fi

workspace_json=$(herdr workspace get "$HERDR_WORKSPACE_ID")

if jq --exit-status '.result.workspace.worktree.is_linked_worktree == true' <<<"$workspace_json" >/dev/null; then
  herdr worktree remove --workspace "$HERDR_WORKSPACE_ID"
  exit 0
fi

herdr workspace close "$HERDR_WORKSPACE_ID"
