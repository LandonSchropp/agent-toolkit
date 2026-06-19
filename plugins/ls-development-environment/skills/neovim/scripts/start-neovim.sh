#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: start-neovim.sh [options]"
  echo
  echo "Starts Neovim in the tmux window named vim, nvim, or neovim whose working"
  echo "directory is the git repository root (or the current directory when not in"
  echo "a repo), unless Neovim is already running there (its socket exists)."
  echo
  echo "Options:"
  echo
  echo "  --help   Show this help message and exit."
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  *)
    echo "Error: Unknown option: $1" >&2
    echo >&2
    print_help >&2
    exit 1
    ;;
  esac
done

git_root="$(git rev-parse --show-toplevel 2>/dev/null)" || true
root="$(realpath "${git_root:-$PWD}")"
socket="$root/.agents/neovim.sock"

# Neovim is already running if the socket exists; nothing to do.
if [[ -S "$socket" ]]; then
  exit 0
fi

pane_id=""

# Find this project's editor window: a pane whose window is named vim, nvim, or
# neovim and whose working directory is the project root. Matching the root
# avoids targeting another project's editor in a different tmux session.
while IFS=$'\t' read -r window_name pane_path id; do
  case "$window_name" in
  vim | nvim | neovim) ;;
  *) continue ;;
  esac

  if [[ "$(realpath "$pane_path" 2>/dev/null)" == "$root" ]]; then
    pane_id="$id"
    break
  fi
done < <(tmux list-panes -a -F '#{window_name}'$'\t''#{pane_current_path}'$'\t''#{pane_id}' 2>/dev/null)

if [[ -z "$pane_id" ]]; then
  echo "Error: No tmux window named vim, nvim, or neovim found for $root." >&2
  exit 1
fi

tmux send-keys -t "$pane_id" "nvim" Enter

# Wait for Neovim to come up and create the socket.
timeout=$((SECONDS + 15))

while ((SECONDS < timeout)); do
  if [[ -S "$socket" ]]; then
    exit 0
  fi

  sleep 0.25
done

echo "Error: Timed out waiting for the Neovim socket at $socket." >&2
exit 1
