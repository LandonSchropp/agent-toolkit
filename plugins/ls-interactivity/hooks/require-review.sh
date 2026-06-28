#!/usr/bin/env bash

set -euo pipefail

DATABASE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-toolkit/reviews.db"

# The disable-review skill suspends the review requirement for an orc session by recording its
# disable time. Treat the requirement as disabled while that time is within the last hour.
function is_review_disabled() {
  local caller project session

  [[ -f "$DATABASE" ]] || return 1
  caller="$(orc caller-session 2>/dev/null)" || return 1

  project="${caller%%$'\t'*}"
  session="${caller#*$'\t'}"

  [[ -n "$(sqlite3 "$DATABASE" \
    "SELECT 1 FROM overrides
     WHERE project = '${project//\'/\'\'}'
       AND session = '${session//\'/\'\'}'
       AND disabled_at > strftime('%s', 'now') - 3600
     LIMIT 1;" 2>/dev/null)" ]]
}

command="$(jq -r '.tool_input.command // ""')"

# Only gate commands that create a commit; ignore everything else.
if ! grep -qE '(^|[^[:alnum:]])git[[:space:]]+commit([[:space:]]|$)' <<<"$command"; then
  exit 0
fi

# Amends edit existing history rather than adding new work, so leave them alone.
if [[ "$command" == *"--amend"* ]]; then
  exit 0
fi

# The user has temporarily disabled the review requirement for this session, so allow the commit.
if is_review_disabled; then
  exit 0
fi

# The commit builds on the current HEAD. Before the first commit there is no HEAD
# to build on, so there's nothing to review.
if ! head="$(git rev-parse --verify --quiet HEAD 2>/dev/null)"; then
  exit 0
fi

# Allow the commit when the pending work on this base has already been reviewed. Guard on the
# database file so a fresh machine (no reviews recorded yet) doesn't create an empty one here.
if [[ -f "$DATABASE" ]] &&
  [[ -n "$(sqlite3 "$DATABASE" "SELECT 1 FROM reviews WHERE head = '$head' LIMIT 1;" 2>/dev/null)" ]]; then
  exit 0
fi

reason="The user has not reviewed these changes. Invoke the interactive-review skill, present the changes to the user, and only commit once the user signs off."

jq -cn --arg reason "$reason" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
