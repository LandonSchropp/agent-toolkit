#!/usr/bin/env bash

# Used as GIT_SEQUENCE_EDITOR by non-interactive-git-rebase.sh.
# Copies the rebase plan from $GIT_REBASE_PLAN_FILE to the todo file git passes as $1.
set -euo pipefail

cp "$GIT_REBASE_PLAN_FILE" "$1"
