#!/usr/bin/env bash

# Used as GIT_EDITOR by reword-commit.sh.
# Copies the new message from $GIT_REBASE_MESSAGE_FILE to the file git passes as $1.
set -euo pipefail

cp "$GIT_REBASE_MESSAGE_FILE" "$1"
