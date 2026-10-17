#!/usr/bin/env bash

set -euo pipefail

# Polls herdr and prints a line for each workspace that opens or closes, such as
# "herdr-workspace-closed:<label>". It reports only once the workspaces have gone two minutes
# without changing, so a burst of changes arrives as one batch. Runs until it is killed.

function list_workspaces() {
  herdr workspace list | jq --raw-output '.result.workspaces[] | "\(.workspace_id) \(.label)"' | sort --key=1,1
}

function print_missing_workspaces() {
  local workspaces="$1"
  local other_workspaces="$2"
  local event="$3"

  join -v 1 <(echo "$workspaces") <(echo "$other_workspaces" | cut -d ' ' -f 1) |
    cut -d ' ' -f 2- |
    sed -n "/./s/^/$event:/p"
}

reported_workspaces="$(list_workspaces)"
last_seen_workspaces="$reported_workspaces"
last_change="$SECONDS"

while true; do
  sleep 5

  polled_workspaces="$(list_workspaces)" || continue

  if [[ "$polled_workspaces" != "$last_seen_workspaces" ]]; then
    last_seen_workspaces="$polled_workspaces"
    last_change="$SECONDS"
  elif [[ "$last_seen_workspaces" != "$reported_workspaces" ]] && ((SECONDS - last_change >= 120)); then
    print_missing_workspaces "$reported_workspaces" "$last_seen_workspaces" herdr-workspace-closed
    print_missing_workspaces "$last_seen_workspaces" "$reported_workspaces" herdr-workspace-opened

    reported_workspaces="$last_seen_workspaces"
  fi
done
