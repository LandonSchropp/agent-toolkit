#!/usr/bin/env bash

set -euo pipefail

function print_help() {
	echo "Usage: retarget-pull-request-to-default-branch.sh [options]"
	echo
	echo "Retarget a pull request's base to the repository's default branch."
	echo
	echo "Required before merging the previous pull request in a stack. GitHub's"
	echo "auto-retarget is unreliable — retargeting manually prevents the pull"
	echo "request from being auto-closed when its base branch is deleted."
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

default_branch=$(git default-branch)
echo "Retargeting pull request to '${default_branch}'..." >&2
gh pr edit "$pull_request_url" --base "$default_branch"
