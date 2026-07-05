#!/usr/bin/env bash

set -euo pipefail

DATABASE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-toolkit/reviews.db"

# No database means nothing was ever disabled, so review is already required.
if [[ ! -f "$DATABASE" ]]; then
  echo "Commit review is already enabled for this session."
  exit 0
fi

if [[ -z "${ORC_PROJECT:-}" || -z "${ORC_SESSION:-}" ]]; then
  echo "Error: Not inside an Orc session." >&2
  exit 1
fi

sqlite3 "$DATABASE" <<SQL
DELETE FROM overrides
WHERE project = '$ORC_PROJECT' AND session = '$ORC_SESSION';
SQL
