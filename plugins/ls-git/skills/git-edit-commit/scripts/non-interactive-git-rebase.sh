#!/usr/bin/env bash

set -euo pipefail

script_directory="$(cd "$(dirname "$0")" && pwd)"

# When --autosquash is present, git generates the plan automatically.
# Use a no-op sequence editor so the auto-generated plan is not overridden.
for arg in "$@"; do
  if [[ "$arg" == "--autosquash" ]]; then
    GIT_SEQUENCE_EDITOR=true git rebase -i "$@"
    exit 0
  fi
done

plan_file=$(mktemp /tmp/git-rebase-plan.XXXXXX)
cleanup() { rm -f "$plan_file"; }
trap cleanup EXIT

cat >"$plan_file"

GIT_REBASE_PLAN_FILE="$plan_file" GIT_SEQUENCE_EDITOR="$script_directory/sequence-editor.sh" git rebase -i "$@"
