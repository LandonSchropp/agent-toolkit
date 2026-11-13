#!/usr/bin/env bash

set -euo pipefail

# Waits, while Hunk reviews are open in this herdr workspace, for the user's next decision in any of
# them, then exits 2 with it, which wakes the agent. Exits 0 when no review is open. Replaces the
# session's previous listener. On an approval, a comment or a denial made while the user is on that
# review's tab, it focuses the agent's tab.

session="$(jq --raw-output '.session_id')"

[[ -n "${HERDR_WORKSPACE_ID:-}" ]] || exit 0

# The session ID and tab of each Hunk review running in one of this workspace's panes.
function find_reviews() {
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
    done
}

reviews="$(find_reviews 2>/dev/null)" || exit 0
[[ -n "$reviews" ]] || exit 0

# One listener per session: take over the lock and stop the previous listener.
directory="${TMPDIR:-/tmp}/agent-toolkit/hunk-verdict"
lock="$directory/$session.pid"
fifo="$directory/$session.$$.fifo"
mkdir -p "$directory"

previous="$(cat "$lock" 2>/dev/null || true)"
echo "$$" >"$lock"
[[ -z "$previous" ]] || kill "$previous" 2>/dev/null || true

listeners=()
trap 'exit 143' TERM INT HUP
trap '[[ ${#listeners[@]} -eq 0 ]] || kill "${listeners[@]}" 2>/dev/null || true
  [[ "$(cat "$lock" 2>/dev/null)" != "$$" ]] || rm -f "$lock"
  rm -f "$fifo"' EXIT

# Every listener writes "<tab> <decision>" lines into one FIFO, then "<tab> done" when it exits.
mkfifo "$fifo"
exec 3<>"$fifo"

while read -r review tab; do
  hunk verdict listen --session "$review" 2>/dev/null > >(
    {
      while read -r line; do echo "$tab $line"; done
      echo "$tab done"
    } >&3
  ) &
  listeners+=($!)
done <<<"$reviews"

remaining="${#listeners[@]}"
while read -r tab decision <&3 && [[ "$decision" == "done" ]]; do
  ((--remaining > 0)) || exit 0
done

if [[ "$decision" =~ ^review-(approved|commented|denied)$ ]] &&
  [[ "$(herdr tab get "$tab" | jq --raw-output '.result.tab.focused')" == "true" ]]; then
  herdr tab focus "$HERDR_TAB_ID" >/dev/null
fi

label="$(herdr tab get "$tab" 2>/dev/null | jq --raw-output '.result.tab.label // empty' || true)"
echo "Hunk review decision in ${label:-$tab}: $decision" >&2
exit 2
