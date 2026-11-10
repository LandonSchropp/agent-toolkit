#!/usr/bin/env bash

set -euo pipefail

# Tells the agent to babysit each pull request `gh pr create` opens.

input=$(cat)
command=$(jq --raw-output '.tool_input.command' <<<"$input")

[[ -n "${HERDR_WORKSPACE_ID:-}" ]] || exit 0
[[ "$command" == *"gh pr create"* ]] || exit 0

urls=$(jq --raw-output '[.tool_response.stdout // "" | scan("https://github\\.com/[^/\\s]+/[^/\\s]+/pull/[0-9]+")] | unique | join(" ")' <<<"$input")
[[ -n "$urls" ]] || exit 0

jq --null-input --compact-output --arg urls "$urls" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: "REQUIRED: Invoke the `ls-git:babysit` skill on \($urls) now, before replying to the user."
  }
}'
