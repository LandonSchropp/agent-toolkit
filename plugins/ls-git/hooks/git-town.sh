#!/usr/bin/env bash

set -euo pipefail

# Prepends TERM=dumb to git town commands so they run without an interactive terminal.

input=$(cat)
command=$(jq -r '.tool_input.command' <<<"$input")

if [[ "$command" == *"git town"* ]] && [[ "$command" != "TERM=dumb"* ]]; then
  jq -c --arg command "TERM=dumb $command" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", updatedInput: (.tool_input | .command = $command)}}' \
    <<<"$input"
fi
