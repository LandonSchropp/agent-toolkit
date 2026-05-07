#!/usr/bin/env bash

set -euo pipefail

poll_interval=10

function print_help() {
	echo "Usage: wait-for-pull-request-to-be-merged.sh [options]"
	echo
	echo "Poll a pull request until its state becomes MERGED."
	echo
	echo "Useful after triggering a merge queue, where the merge completes"
	echo "asynchronously. Exits 0 when merged. Exits 1 if the pull request"
	echo "is closed without merging."
	echo
	echo "Options:"
	echo
	echo "  --pull-request-url <url>   URL or number of the pull request."
	echo "  --help                     Show this help message and exit."
}

pull_request_url=""

while [[ $# -gt 0 ]]; do
	case "$1" in
	--help)
		print_help
		exit 0
		;;
	--pull-request-url)
		pull_request_url="$2"
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

if [[ -z "$pull_request_url" ]]; then
	echo "Error: --pull-request-url is required." >&2
	echo >&2
	print_help >&2
	exit 1
fi

while true; do
	state=$(gh pr view "$pull_request_url" --json state --jq '.state')

	if [[ "$state" == "MERGED" ]]; then
		echo "Pull request merged." >&2
		exit 0
	fi

	if [[ "$state" == "CLOSED" ]]; then
		echo "Error: Pull request was closed without merging." >&2
		exit 1
	fi

	echo "Waiting for merge (state: ${state})..." >&2
	sleep "$poll_interval"
done
