#!/usr/bin/env bash

set -euo pipefail

function print_help() {
	echo "Usage: edit.sh [options]"
	echo
	echo "Opens a file in the Neovim instance connected to <git-root>/.agents/neovim.sock."
	echo
	echo "Options:"
	echo
	echo "  --file <path>   Path to the file to open."
	echo "  --help          Show this help message and exit."
}

file=""

while [[ $# -gt 0 ]]; do
	case "$1" in
	--help)
		print_help
		exit 0
		;;
	--file)
		file="$2"
		shift 2
		;;
	*)
		echo "Error: Unknown option: $1" >&2
		echo >&2
		print_help >&2
		exit 1
		;;
	esac
done

if [[ -z "$file" ]]; then
	echo "Error: --file is required" >&2
	echo >&2
	print_help >&2
	exit 1
fi

socket="$("$(dirname "$0")/socket.sh")"
absolute_file="$(realpath "$file")"

nvim --server "$socket" --remote "$absolute_file"
