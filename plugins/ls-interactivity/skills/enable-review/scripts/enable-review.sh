#!/usr/bin/env bash

set -euo pipefail

DATABASE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-toolkit/reviews.db"

# No database means nothing was ever disabled, so review is already required.
if [[ ! -f "$DATABASE" ]]; then
  echo "Commit review is already enabled for this session."
  exit 0
fi

caller="$(orc caller-session)"
project="${caller%%$'\t'*}"
session="${caller#*$'\t'}"

# Escape single quotes for the SQL string literals.
project="${project//\'/\'\'}"
session="${session//\'/\'\'}"

sqlite3 "$DATABASE" <<SQL
DELETE FROM overrides
WHERE project = '$project' AND session = '$session';
SQL
