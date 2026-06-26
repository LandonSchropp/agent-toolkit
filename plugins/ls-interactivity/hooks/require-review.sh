#!/usr/bin/env bash

set -euo pipefail

REVIEWS_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-toolkit/reviews.txt"

command="$(jq -r '.tool_input.command // ""')"

# Only gate commands that create a commit; ignore everything else.
if ! grep -qE '(^|[^[:alnum:]])git[[:space:]]+commit([[:space:]]|$)' <<<"$command"; then
  exit 0
fi

# Amends edit existing history rather than adding new work, so leave them alone.
if [[ "$command" == *"--amend"* ]]; then
  exit 0
fi

# The commit builds on the current HEAD. Before the first commit there is no HEAD
# to build on, so there's nothing to review.
if ! head="$(git rev-parse --verify --quiet HEAD 2>/dev/null)"; then
  exit 0
fi

# Allow the commit when the pending work on this base has already been reviewed.
if [[ -f "$REVIEWS_FILE" ]] && grep -qxF "$head" "$REVIEWS_FILE"; then
  exit 0
fi

reason="The user has not reviewed these changes. Invoke the interactive-review skill, present the changes to the user, and only commit once the user signs off."

jq -cn --arg reason "$reason" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
