#!/usr/bin/env bash

set -euo pipefail

# Formats an edited shell script with shfmt.

file_path=$(jq -r '.tool_input.file_path')

is_bash_file() {
  file=$1

  if [[ "$file" =~ \.sh$ ]]; then
    return 0
  fi

  first_line=$(read -r first_line <"$(readlink -f "$file")" 2>/dev/null)
  [[ "$first_line" =~ ^#!.*(bash|sh)($|[[:space:]]) ]]
}

is_spec_file() {
  [[ "$1" =~ _spec\.sh$ ]]
}

if is_bash_file "$file_path" && ! is_spec_file "$file_path" && which shfmt >/dev/null; then
  shfmt -w -i 2 "$(readlink -f "$file_path")"
fi
