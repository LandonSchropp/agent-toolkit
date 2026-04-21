#!/usr/bin/env bash

set -euo pipefail

poll_interval=20

function print_help() {
	echo "Usage: wait-for-pull-request-to-be-ready.sh [options]"
	echo
	echo "Poll a pull request until it is ready to merge."
	echo
	echo "Calls is-pull-request-ready.sh every ${poll_interval}s."
	echo "Exits immediately on permanent blockers (draft, conflicts, changes requested,"
	echo "CI failure). Retries while CI checks are pending."
	echo "Exits 0 when ready, 1 on argument error, 2 on permanent blocker."
	echo
	echo "Options:"
	echo
	echo "  --pull-request-url <url>   URL or number of the pull request."
	echo "  --help                     Show this help message and exit."
}

for arg in "$@"; do
	if [[ "$arg" == "--help" ]]; then
		print_help
		exit 0
	fi
done

script_directory=$(dirname "$0")

while true; do
	"${script_directory}/is-pull-request-ready.sh" "$@" && exit 0 || exit_code=$?

	# Exit codes 1 and 2 are not retryable — argument error or permanent blocker.
	if [[ "$exit_code" -le 2 ]]; then
		exit "$exit_code"
	fi

	# Exit code 3 means CI is still pending. Keep waiting.
	echo "Retrying in ${poll_interval}s..." >&2
	sleep "$poll_interval"
done
