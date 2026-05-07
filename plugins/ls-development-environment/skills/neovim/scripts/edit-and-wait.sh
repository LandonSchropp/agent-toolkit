#!/usr/bin/env bash

set -euo pipefail

function print_help() {
	echo "Usage: edit-and-wait.sh [options]"
	echo
	echo "Opens a file in Neovim and waits for it to be saved, then exits. Exits"
	echo "non-zero if the file is not saved within 15 minutes."
	echo
	echo "Options:"
	echo
	echo "  --file <path>   Path to the file to open and wait on."
	echo "  --help          Show this help message and exit."
}

function get_mtime() {
	if [[ ! -f "$1" ]]; then
		echo "0"
		return
	fi

	if [[ "$(uname)" == "Darwin" ]]; then
		stat -f %m "$1"
	else
		stat -c %Y "$1"
	fi
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

max_wait=900
initial_mtime="$(get_mtime "$file")"

"$(dirname "$0")/edit.sh" --file "$file"

start_time=$SECONDS

while true; do
	sleep 10

	current_mtime="$(get_mtime "$file")"

	if [[ "$current_mtime" != "$initial_mtime" ]]; then
		break
	fi

	if ((SECONDS - start_time >= max_wait)); then
		echo "Error: Timed out waiting for $file to be saved" >&2
		exit 1
	fi
done
