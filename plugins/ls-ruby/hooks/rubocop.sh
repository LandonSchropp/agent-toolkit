#!/usr/bin/env bash

set -euo pipefail

# Autocorrects an edited Ruby file with RuboCop.

file_path=$(jq -r '.tool_input.file_path')

if [[ "$file_path" =~ \.rb$ ]] && which rubocop >/dev/null; then
  bundle exec rubocop --autocorrect "$(readlink -f "$file_path")" || true
fi
