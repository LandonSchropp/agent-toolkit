#!/usr/bin/env bash

set -euo pipefail

function print_help() {
	echo "Usage: merge-pull-request.sh [options]"
	echo
	echo "Merge a pull request using the repository's preferred merge method."
	echo
	echo "If the target branch has a merge queue rule, the pull request is added to"
	echo "the queue without specifying a strategy (the queue's configured strategy is"
	echo "used). Otherwise, detects allowed merge methods from repository settings and"
	echo "picks one in order of preference: squash > merge commit > rebase."
	echo
	echo "Deletes the head branch after merging. Does not run pre-flight checks or"
	echo "wait for CI. Run wait-for-pull-request-to-be-ready.sh first."
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

# Fetch the repository owner, name, and base branch needed for API calls below.
pull_request_json=$(gh pr view "$pull_request_url" --json headRepositoryOwner,headRepository,baseRefName)
owner=$(echo "$pull_request_json" | jq -r '.headRepositoryOwner.login')
repository_name=$(echo "$pull_request_json" | jq -r '.headRepository.name')
base_branch=$(echo "$pull_request_json" | jq -r '.baseRefName')

# If the target branch requires a merge queue, add the pull request to the queue
# without a strategy flag and let the queue use its configured strategy.
if [[ "$(gh api "repos/${owner}/${repository_name}/rules/branches/${base_branch}" \
	--jq '[.[] | select(.type == "merge_queue")] | length > 0' 2>/dev/null || echo "false")" == "true" ]]; then
	echo "Merge queue detected for '${base_branch}'. Adding to queue..." >&2
	gh pr merge "$pull_request_url" --delete-branch
	exit 0
fi

# Fetch the repository's merge settings
repository_settings=$(gh api "repos/${owner}/${repository_name}" --jq '{allow_merge_commit, allow_squash_merge, allow_rebase_merge}')

# Detect the repository's allowed merge methods and pick one.
if [[ "$(echo "$repository_settings" | jq -r '.allow_squash_merge')" == "true" ]]; then
	method_flag="--squash"
	method_name="squash"
elif [[ "$(echo "$repository_settings" | jq -r '.allow_merge_commit')" == "true" ]]; then
	method_flag="--merge"
	method_name="merge commit"
elif [[ "$(echo "$repository_settings" | jq -r '.allow_rebase_merge')" == "true" ]]; then
	method_flag="--rebase"
	method_name="rebase"
else
	echo "Error: Repository does not allow any merge method." >&2
	exit 1
fi

echo "Merging with ${method_name} strategy..." >&2
gh pr merge "$pull_request_url" "$method_flag" --delete-branch
