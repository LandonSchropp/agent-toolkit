#!/usr/bin/env bash

set -euo pipefail

function print_help() {
	echo "Usage: is-pull-request-ready.sh [options]"
	echo
	echo "Check whether a pull request is ready to merge right now."
	echo
	echo "Exit codes:"
	echo "  0  Ready to merge."
	echo "  1  Argument error."
	echo "  2  Permanent blocker — requires user action (draft, conflicts,"
	echo "     changes requested, missing review, CI failed)."
	echo "  3  Transient — CI checks are still pending. Retry later."
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

pull_request_json=$(gh pr view "$pull_request_url" \
	--json state,isDraft,mergeable,reviewDecision,statusCheckRollup)

# The pull request must be open. This catches MERGED and CLOSED states.
if [[ "$(echo "$pull_request_json" | jq -r '.state')" != "OPEN" ]]; then
	echo "Error: Pull request is not open (state: $(echo "$pull_request_json" | jq -r '.state')). Only open pull requests can be merged." >&2
	exit 2
fi

# The pull request must not be a draft.
if [[ "$(echo "$pull_request_json" | jq -r '.isDraft')" == "true" ]]; then
	echo "Error: Pull request is a draft. Mark it as ready for review first." >&2
	exit 2
fi

# The pull request must have no merge conflicts.
if [[ "$(echo "$pull_request_json" | jq -r '.mergeable')" == "CONFLICTING" ]]; then
	echo "Error: Pull request has merge conflicts. Resolve them before merging." >&2
	exit 2
fi

# The pull request must have no blocking review decisions.
case "$(echo "$pull_request_json" | jq -r '.reviewDecision // ""')" in
CHANGES_REQUESTED)
	echo "Error: Pull request has CHANGES_REQUESTED. Address review feedback first." >&2
	exit 2
	;;
REVIEW_REQUIRED)
	echo "Error: Pull request requires review approval before merging." >&2
	exit 2
	;;
esac

# All CI checks must have passed. Any failure is a permanent blocker.
failed=$(echo "$pull_request_json" | jq -r '
  .statusCheckRollup | [
    .[] | select(
      (.__typename == "CheckRun" and (
        .conclusion == "FAILURE" or
        .conclusion == "CANCELLED" or
        .conclusion == "TIMED_OUT" or
        .conclusion == "ACTION_REQUIRED"
      )) or
      (.__typename == "StatusContext" and (
        .state == "FAILURE" or
        .state == "ERROR"
      ))
    ) | (.name // .context)
  ] | join(", ")
')

if [[ -n "$failed" ]]; then
	echo "Error: CI check(s) failed: ${failed}" >&2
	exit 2
fi

# Pending CI checks are transient. Signal the caller to retry rather than failing permanently.
pending=$(echo "$pull_request_json" | jq '
  .statusCheckRollup | [
    .[] | select(
      (.__typename == "CheckRun" and (
        .status == "QUEUED" or
        .status == "IN_PROGRESS" or
        .status == "PENDING" or
        .status == "WAITING"
      )) or
      (.__typename == "StatusContext" and .state == "PENDING")
    )
  ] | length
')

if [[ "$pending" -gt 0 ]]; then
	echo "CI checks pending: ${pending} check(s) still running." >&2
	exit 3
fi

echo "Pull request is ready to merge." >&2
