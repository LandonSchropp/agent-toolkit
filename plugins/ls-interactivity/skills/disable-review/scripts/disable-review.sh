#!/usr/bin/env bash

set -euo pipefail

DATABASE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-toolkit/reviews.db"

# review.sh is the only script that creates the database, so there's nothing to disable until a
# review has run at least once.
if [[ ! -f "$DATABASE" ]]; then
  echo "Error: No review database yet." >&2
  exit 1
fi

caller="$(orc caller-session)"
project="${caller%%$'\t'*}"
session="${caller#*$'\t'}"

# Escape single quotes for the SQL string literals.
project="${project//\'/\'\'}"
session="${session//\'/\'\'}"

sqlite3 "$DATABASE" <<SQL
INSERT INTO overrides (project, session, disabled_at)
VALUES ('$project', '$session', strftime('%s', 'now'))
ON CONFLICT (project, session) DO UPDATE SET disabled_at = excluded.disabled_at;
SQL
