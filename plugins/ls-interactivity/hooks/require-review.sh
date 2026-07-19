#!/usr/bin/env bash

set -euo pipefail

DATABASE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-toolkit/reviews.db"

# The disable-review skill suspends the review requirement for a herdr workspace by recording its
# disable time. Treat the requirement as disabled while that time is within the last hour.
function is_review_disabled() {
  [[ -f "$DATABASE" ]] || return 1
  [[ -n "${HERDR_WORKSPACE_ID:-}" ]] || return 1

  [[ -n "$(sqlite3 "$DATABASE" \
    "SELECT 1 FROM overrides
     WHERE workspace = '$HERDR_WORKSPACE_ID'
       AND disabled_at > strftime('%s', 'now') - 3600
     LIMIT 1;" 2>/dev/null)" ]]
}

input="$(cat)"
command="$(jq -r '.tool_input.command // ""' <<<"$input")"
working_directory="$(jq -r '.cwd // "."' <<<"$input")"

# Only gate commands that create a commit; ignore everything else. Match `commit` as the git
# subcommand after any global options (e.g. `git -C <dir> commit`), not as a substring in a flag
# value or branch name.
if ! grep -qE '(^|[^[:alnum:]])git[[:space:]]+([^[:space:]]+[[:space:]]+)*commit([[:space:]]|$)' <<<"$command"; then
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

# The hook runs in the session's primary repo, but the commit may target another one by passing
# `git -C <dir>`. Use that directory when present. An in-command `cd` isn't visible here, so commits
# in another repo must go through `git -C`.
if [[ "$command" =~ [[:space:]]-C[[:space:]]+([^[:space:]]+) ]]; then
  working_directory="${BASH_REMATCH[1]}"
fi

# The commit builds on the target repo's HEAD. Before the first commit there is no HEAD to build on,
# so there's nothing to review.
head="$(git -C "$working_directory" rev-parse --verify --quiet HEAD 2>/dev/null)" || exit 0

# Allow the commit when the pending work on this base has already been reviewed. Guard on the
# database file so a fresh machine (no reviews recorded yet) doesn't create an empty one here.
if [[ -f "$DATABASE" ]] &&
  [[ -n "$(sqlite3 "$DATABASE" "SELECT 1 FROM reviews WHERE head = '$head' LIMIT 1;" 2>/dev/null)" ]]; then
  exit 0
fi

reason="The user has not reviewed these changes. Invoke the interactive-review skill, present the changes to the user, and only commit once the user signs off."

jq -cn --arg reason "$reason" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
