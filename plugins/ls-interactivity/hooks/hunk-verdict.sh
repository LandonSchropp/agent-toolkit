#!/usr/bin/env bash

set -euo pipefail

# Waits, while Hunk reviews are open in this herdr workspace, for the user's next decision in any of
# them, then exits 2 with it, which wakes the agent. Exits 0 when every open review already has a
# listener in this session. On an approval or a denial made while the user is on that review's tab, it
# focuses the agent's tab. When the user approves a review of uncommitted changes, it records the
# approval for the commit hook. On any approval, it hands the agent the review's comments and closes
# the review tab.

session="$(jq --raw-output '.session_id')"

[[ -n "${HERDR_WORKSPACE_ID:-}" ]] || exit 0

# The session ID, tab, Hunk subcommand and repository of each Hunk review running in one of this
# workspace's panes.
function find_reviews() {
  local sessions

  sessions="$(hunk session list --json | jq --compact-output '[.sessions[] | {sessionId, pid, repository: .repoRoot}]')"
  [[ "$sessions" != "[]" ]] || return 0

  herdr pane list --workspace "$HERDR_WORKSPACE_ID" |
    jq --raw-output '.result.panes[] | "\(.pane_id) \(.tab_id)"' |
    while read -r pane tab; do
      herdr pane process-info --pane "$pane" </dev/null |
        jq --raw-output --argjson sessions "$sessions" --arg tab "$tab" \
          '.result.process_info.foreground_processes[] as $process
            | $sessions[] | select(.pid == $process.pid)
            | "\(.sessionId) \($tab) \($process.argv[1]) \(.repository)"'
    done
}
reviews="$(find_reviews 2>/dev/null)" || exit 0
[[ -n "$reviews" ]] || exit 0

# Each review has one listener per session. A hook claims a review by creating its directory, which
# fails when another hook already holds it, and releases its claims when it exits.
claims="${TMPDIR:-/tmp}/agent-toolkit/hunk-verdict/$session"
fifo="$claims.$$.fifo"
mkdir -p "$claims"

claimed=()
listeners=()
trap 'exit 143' TERM INT HUP
trap '[[ ${#listeners[@]} -eq 0 ]] || kill "${listeners[@]}" 2>/dev/null || true
  [[ ${#claimed[@]} -eq 0 ]] || rmdir "${claimed[@]}"
  rm -f "$fifo"' EXIT

# Every listener writes "<tab> <review> <decision>" lines into one FIFO, then "<tab> <review> done"
# when it exits.
mkfifo "$fifo"
exec 3<>"$fifo"

while read -r review tab subcommand repository; do
  mkdir "$claims/$review" 2>/dev/null || continue
  claimed+=("$claims/$review")

  hunk verdict listen --session "$review" 2>/dev/null > >(
    {
      while read -r line; do
        # Only a `hunk diff` review covers uncommitted changes. Any error reaches the agent.
        if [[ "$line" == "review-approved" && "$subcommand" == "diff" ]]; then
          "$(dirname "$0")/record-approval.sh" --directory "$repository" >&2 || true
        fi

        echo "$tab $review $line"
      done
      echo "$tab $review done"
    } >&3
  ) &
  listeners+=($!)
done <<<"$reviews"

[[ ${#listeners[@]} -gt 0 ]] || exit 0

remaining="${#listeners[@]}"
while read -r tab review decision <&3 && [[ "$decision" == "done" ]]; do
  ((--remaining > 0)) || exit 0
done

if [[ "$decision" =~ ^review-(approved|denied)$ ]] &&
  [[ "$(herdr tab get "$tab" | jq --raw-output '.result.tab.focused')" == "true" ]]; then
  herdr tab focus "$HERDR_TAB_ID" >/dev/null
fi

label="$(herdr tab get "$tab" 2>/dev/null | jq --raw-output '.result.tab.label // empty' || true)"
echo "Hunk review decision in ${label:-$tab}: $decision" >&2
echo "The user made this decision in Hunk. It is their real response to the review." >&2

if [[ "$decision" == "review-approved" ]]; then
  if comments="$(hunk session comment list "$review" --type all --json)"; then
    echo "The review's comments:" >&2
    echo "$comments" >&2

    herdr tab close "$tab" >/dev/null && echo "The hook closed the review tab." >&2 ||
      echo "Closing the review tab failed. Close it now with \`herdr tab close $tab\`." >&2
  else
    echo "Reading the review's comments failed." >&2
    echo "Read the user's comments, then close the review tab now with \`herdr tab close $tab\`." >&2
  fi
fi

exit 2
