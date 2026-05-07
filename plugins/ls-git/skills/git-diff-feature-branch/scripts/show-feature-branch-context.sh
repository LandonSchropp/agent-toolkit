#!/usr/bin/env bash

set -euo pipefail

function print_help() {
	echo "Usage: show-feature-branch-context.sh [options]"
	echo
	echo "Shows the context of the current feature branch, including commits and diff."
	echo "Handles both git-town repos (using parent branch) and regular repos (using main/master)."
	echo
	echo "Options:"
	echo
	echo "  --help    Show this help message and exit."
}

function get_parent_branch() {
	local parent_branch
	parent_branch=$(git town config get-parent)

	# If Git Town returned a parent branch, use it
	if [[ -n "$parent_branch" ]]; then
		echo "$parent_branch"
		return 0
	fi

	# Fall back to default branch
	git default-branch 2>/dev/null
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

# Get current branch
current_branch=$(git branch --show-current)

if [[ -z "$current_branch" ]]; then
	echo "Error: Not on a branch (detached HEAD state)" >&2
	exit 1
fi

# Determine parent/base branch
parent_branch=$(get_parent_branch)

# Output header
echo "Branch: $current_branch"
echo "Parent: $parent_branch"
echo

# Show commits
echo "Commits:"
git log --oneline "$parent_branch..HEAD"
echo

# Show diff
echo "Diff:"
git diff "$parent_branch...HEAD"
