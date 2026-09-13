#!/usr/bin/env bash

set -euo pipefail

# Formats an edited file with Prettier, run from the project that owns the file.

file_path=$(jq -r '.tool_input.file_path')

if [[ ! "$file_path" =~ \.(js|ts|jsx|tsx|css|scss|json|md|html|vue|yaml|yml)$ ]]; then
  exit 0
fi

# Skip Markdown files that opt out with `prettier: false` in their frontmatter.
if [[ "$file_path" == *.md ]] &&
  rg --multiline --pcre2 --quiet '\A---\n(?:(?!---$).*\n)*prettier: false$' "$file_path"; then
  exit 0
fi

resolved=$(readlink -f "$file_path")

# Prints the given directory or its nearest ancestor that contains the given path.
find_ancestor() {
  local directory="$1"

  while [[ "$directory" != "/" ]]; do
    if [[ -e "$directory/$2" ]]; then
      echo "$directory"
      return
    fi

    directory=$(dirname "$directory")
  done

  return 1
}

file_directory=$(dirname "$resolved")

if directory=$(find_ancestor "$file_directory" node_modules/.bin/prettier); then
  "$directory/node_modules/.bin/prettier" --write "$resolved"
elif directory=$(find_ancestor "$file_directory" bun.lock) ||
  directory=$(find_ancestor "$file_directory" bun.lockb); then
  cd "$directory" && bun x prettier --write "$resolved"
elif directory=$(find_ancestor "$file_directory" package-lock.json); then
  cd "$directory" && npx prettier --write "$resolved"
elif directory=$(find_ancestor "$file_directory" pnpm-lock.yaml); then
  cd "$directory" && pnpm exec prettier --write "$resolved"
else
  directory=$(git -C "$file_directory" rev-parse --show-toplevel 2>/dev/null || echo "$file_directory")
  cd "$directory" && pnpm dlx prettier --write "$resolved"
fi
