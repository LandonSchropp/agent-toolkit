#!/usr/bin/env bash

set -euo pipefail

DATABASE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-toolkit/reviews.db"

# No database means nothing was ever disabled, so review is already required.
if [[ ! -f "$DATABASE" ]]; then
  echo "Commit review is already enabled for this workspace."
  exit 0
fi

if [[ -z "${HERDR_WORKSPACE_ID:-}" ]]; then
  echo "Error: Not inside a herdr workspace." >&2
  exit 1
fi

sqlite3 "$DATABASE" <<SQL
DELETE FROM overrides
WHERE workspace = '$HERDR_WORKSPACE_ID';
SQL
