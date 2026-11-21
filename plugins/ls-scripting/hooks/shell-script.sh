#!/usr/bin/env bash

set -euo pipefail

# Formats an edited shell script with shfmt, then lints it with ShellCheck. Exit 2 sends a parse error or
# ShellCheck's findings back to the agent to fix.

file_path=$(jq -r '.tool_input.file_path')

is_bash_file() {
  file=$1

  if [[ "$file" =~ \.sh$ ]]; then
    return 0
  fi

  local first_line=""
  read -r first_line 2>/dev/null <"$file" || true
  [[ "$first_line" =~ ^#!.*(bash|sh)($|[[:space:]]) ]]
}

is_spec_file() {
  [[ "$1" =~ _spec\.sh$ ]]
}

if ! is_bash_file "$file_path" || is_spec_file "$file_path"; then
  exit 0
fi

file_path=$(readlink -f "$file_path")

if which shfmt >/dev/null && ! output=$(shfmt -w -i 2 "$file_path" 2>&1); then
  echo "$output" >&2
  exit 2
fi

if which shellcheck >/dev/null && ! output=$(cd "$(dirname "$file_path")" && shellcheck --external-sources "$file_path" 2>&1); then
  echo "$output" >&2
  exit 2
fi
