#!/usr/bin/env bash

set -euo pipefail

# Autocorrects an edited Ruby file with Standard when its repository uses it, or with RuboCop otherwise.

file_path=$(jq -r '.tool_input.file_path')

if [[ ! "$file_path" =~ \.rb$ ]] || ! which rubocop >/dev/null; then
  exit 0
fi

file_path=$(readlink -f "$file_path")
file_directory=$(dirname "$file_path")
repository_root=$(git -C "$file_directory" rev-parse --show-toplevel 2>/dev/null || echo "$file_directory")

cd "$repository_root"

if [[ -f .standard.yml ]]; then
  command=(bundle exec standardrb --fix "$file_path")
else
  command=(bundle exec rubocop --autocorrect "$file_path")
fi

# RuboCop exits 1 when offenses remain after autocorrecting. Exit 2 sends them back to the agent to fix.
status=0
output=$("${command[@]}" 2>&1) || status=$?

if [[ $status -eq 1 ]]; then
  echo "$output" >&2
  exit 2
fi
