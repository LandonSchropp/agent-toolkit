#!/usr/bin/env bash

set -euo pipefail

function print_help() {
	echo "Usage: socket.sh [options]"
	echo
	echo "Prints the path to the Neovim socket file. Searches for .agents/neovim.sock"
	echo "relative to the git repository root, falling back to the current directory."
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

if [[ -n "$git_root" ]]; then
	socket="$git_root/.agents/neovim.sock"
else
	socket=".agents/neovim.sock"
fi

if [[ ! -S "$socket" ]]; then
	echo "Error: Neovim socket not found at $socket" >&2
	exit 1
fi

echo "$socket"
