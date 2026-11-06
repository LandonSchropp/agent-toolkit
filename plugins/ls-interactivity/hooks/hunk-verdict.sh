#!/usr/bin/env bash

set -euo pipefail

# Waits, while a Hunk review is open in this herdr workspace, for the user's next decision, then
# exits 2 with it, which wakes the agent. Exits 0 right away when no review is open or another
# copy of this hook in this session is already listening. On an approval, a comment or a denial
# made while the user is on the review's tab, it focuses the agent's tab.

session="$(jq --raw-output '.session_id')"

[[ -n "${HERDR_WORKSPACE_ID:-}" ]] || exit 0

# The session ID and tab of the Hunk review running in one of this workspace's panes, if any.
function find_review() {
  local sessions

  sessions="$(hunk session list --json | jq --compact-output '[.sessions[] | {sessionId, pid}]')"
  [[ "$sessions" != "[]" ]] || return 0

  herdr pane list --workspace "$HERDR_WORKSPACE_ID" |
    jq --raw-output '.result.panes[] | "\(.pane_id) \(.tab_id)"' |
    while read -r pane tab; do
      herdr pane process-info --pane "$pane" </dev/null |
        jq --raw-output --argjson sessions "$sessions" --arg tab "$tab" \
          '.result.process_info.foreground_processes[].pid as $pid
            | $sessions[] | select(.pid == $pid) | "\(.sessionId) \($tab)"'
    done |
    head -n 1
}

read -r review tab < <(find_review) || exit 0

# One listener per session.
directory="${TMPDIR:-/tmp}/agent-toolkit/hunk-verdict"
lock="$directory/$session.pid"
fifo="$directory/$session.$$.fifo"
mkdir -p "$directory"

if ! (set -o noclobber && echo "$$" >"$lock") 2>/dev/null; then
  kill -0 "$(cat "$lock")" 2>/dev/null && exit 0
  echo "$$" >"$lock"
fi

listener=""
trap 'exit 143' TERM INT HUP
trap '[[ -z "$listener" ]] || kill "$listener" 2>/dev/null; rm -f "$lock" "$fifo"' EXIT

mkfifo "$fifo"
hunk verdict listen --session "$review" >"$fifo" &
listener=$!
read -r decision <"$fifo" || exit 0

if [[ "$decision" =~ ^review-(approved|commented|denied)$ ]] &&
  [[ "$(herdr tab get "$tab" | jq --raw-output '.result.tab.focused')" == "true" ]]; then
  herdr tab focus "$HERDR_TAB_ID" >/dev/null
fi

echo "Hunk review decision: $decision" >&2
exit 2
