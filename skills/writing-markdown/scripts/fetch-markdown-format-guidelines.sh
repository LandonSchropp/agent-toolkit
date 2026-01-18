#!/usr/bin/env bash

set -euo pipefail

function print_help() {
	echo "Usage: fetch-markdown-format-guidelines.sh [options]"
	echo
	echo "Output the markdown format guidelines from WRITING_FORMAT environment variable."
	echo
	echo "Options:"
	echo
	echo "  --help    Show this help message and exit."
}

# Parse arguments
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

cat "$WRITING_FORMAT"
