#!/usr/bin/env bash

set -euo pipefail

DATABASE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-toolkit/reviews.db"

# _interactive-review.sh is the only script that creates the database, so there's nothing to
# disable until a review has run at least once.
if [[ ! -f "$DATABASE" ]]; then
  echo "Error: No review database yet." >&2
  exit 1
fi

if [[ -z "${HERDR_WORKSPACE_ID:-}" ]]; then
  echo "Error: Not inside a herdr workspace." >&2
  exit 1
fi

sqlite3 "$DATABASE" <<SQL
INSERT INTO overrides (workspace, disabled_at)
VALUES ('$HERDR_WORKSPACE_ID', strftime('%s', 'now'))
ON CONFLICT (workspace) DO UPDATE SET disabled_at = excluded.disabled_at;
SQL
