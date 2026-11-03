#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: find-pull-request-session.sh [options]"
  echo
  echo "Find the Claude Code session that created a pull request: the one whose 'gh pr create'"
  echo "output contains the pull request's URL. Prints one JSON object per match, with the"
  echo "session ID, the directory and branch the session started in, the herdr workspace open on"
  echo "that directory and the pane running the session. The workspace and pane are null when"
  echo "they aren't open. Prints nothing when no session created it."
  echo
  echo "Options:"
  echo
  echo "  --pull-request-url <url>   The pull request's URL."
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
    echo "Error: The option $1 is invalid." >&2
    echo >&2
    print_help >&2
    exit 1
    ;;
  esac
done

if [[ -z "$pull_request_url" ]]; then
  echo "Error: The --pull-request-url flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

{ rg --files-with-matches --fixed-strings --glob '*.jsonl' "$pull_request_url" "$HOME/.claude/projects" || true; } |
  while read -r session_file; do
    jq --slurp --compact-output --arg url "$pull_request_url" '
      ($url | gsub("[.]"; "\\.") + "(?![0-9])") as $pattern
      | [.[] | .message.content? | arrays | .[]] as $blocks
      | [$blocks[] | select(.type == "tool_use" and ((.input.command? // "") | test("gh pr create"))) | .id] as $ids
      | select(any($blocks[];
          .type == "tool_result" and (.tool_use_id as $id | $ids | index($id)) and (.content | tostring | test($pattern))))
      | first(.[] | select(.cwd)) | {session: .sessionId, directory: .cwd, branch: .gitBranch}
    ' "$session_file"
  done |
  while read -r match; do
    session=$(jq --raw-output .session <<<"$match")
    directory=$(jq --raw-output .directory <<<"$match")

    pane=$(herdr agent list |
      jq --raw-output --arg session "$session" \
        'first(.result.agents[] | select(.agent_session.value == $session) | .pane_id) // empty')

    if [[ -n "$pane" ]]; then
      workspace="${pane%%:*}"
    else
      workspace=$({ herdr worktree list --cwd "$directory" 2>/dev/null || true; } |
        jq --raw-output --arg directory "$directory" \
          'first(.result.worktrees[]? | select(.path == $directory) | .open_workspace_id) // empty')
    fi

    jq --compact-output --arg workspace "$workspace" --arg pane "$pane" \
      '. + {workspace: ($workspace | if . == "" then null end), pane: ($pane | if . == "" then null end)}' <<<"$match"
  done
