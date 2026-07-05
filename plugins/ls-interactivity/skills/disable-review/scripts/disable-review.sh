#!/usr/bin/env bash

set -euo pipefail

DATABASE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-toolkit/reviews.db"

# review.sh is the only script that creates the database, so there's nothing to disable until a
# review has run at least once.
if [[ ! -f "$DATABASE" ]]; then
  echo "Error: No review database yet." >&2
  exit 1
fi

if [[ -z "${ORC_PROJECT:-}" || -z "${ORC_SESSION:-}" ]]; then
  echo "Error: Not inside an Orc session." >&2
  exit 1
fi

sqlite3 "$DATABASE" <<SQL
INSERT INTO overrides (project, session, disabled_at)
VALUES ('$ORC_PROJECT', '$ORC_SESSION', strftime('%s', 'now'))
ON CONFLICT (project, session) DO UPDATE SET disabled_at = excluded.disabled_at;
SQL
