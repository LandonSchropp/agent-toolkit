#!/usr/bin/env bash

set -euo pipefail

# Waits, in a session running the orchestrate skill, for an unchecked task to appear in today's daily
# note or for a workspace the session started to close, then exits 2 with it, which wakes the agent.
# Exits 0 in any other session, and when this session already has a listener. A task is reported
# once the note has gone two minutes without changing, so a burst of edits arrives as one batch.

session="$(jq --raw-output '.session_id')"

# Only sessions running the orchestrate skill have this directory.
state="${XDG_STATE_HOME:-$HOME/.local/state}/agent-toolkit/ls-agent/orchestrate/$session"
[[ -d "$state" ]] || exit 0

# A hook claims the listener by creating its directory, which fails when another hook holds it.
# ponytail: a listener killed with SIGKILL leaves the directory behind and silences the session. Store
# the listener's PID in it and check that it's alive if that happens.
mkdir "$state/listener" 2>/dev/null || exit 0
trap 'exit 143' TERM INT HUP
trap 'rmdir "$state/listener"' EXIT

function list_unchecked_tasks() {
  local note
  note="$HOME/Notes/Daily Notes/$(date +%Y/%Y-%m/%Y-%m-%d) - Daily Note.md"

  if [[ -f "$note" ]]; then
    sed -n 's/^- \[ \] //p' "$note" | sort --unique
  fi
}

# The unchecked tasks already reported for today.
function tasks_file() {
  echo "$state/tasks-$(date +%Y-%m-%d)"
}

function list_reported_tasks() {
  cat "$(tasks_file)" 2>/dev/null || true
}

# Each line of the workspaces file is "<workspace ID> <label>".
touch "$state/workspaces"
last_seen_tasks="$(list_reported_tasks)"
last_change="$SECONDS"

while true; do
  sleep 5

  # An empty list means herdr isn't answering, not that every workspace closed.
  open_workspaces="$(herdr-group list --json | jq --raw-output '.[].workspace_id')" || true

  if [[ -n "$open_workspaces" ]]; then
    : >"$state/workspaces.new"
    closed_workspaces="$(awk -v open_file="$state/workspaces.new" \
      'NR == FNR { open[$1]; next } $1 in open { print > open_file; next } 1' \
      <(echo "$open_workspaces") "$state/workspaces")"

    if [[ -n "$closed_workspaces" ]]; then
      mv "$state/workspaces.new" "$state/workspaces"

      echo "Workspaces this session started have closed:" >&2
      cut -d ' ' -f 2- <<<"$closed_workspaces" | sed 's/^/- /' >&2
      exit 2
    fi
  fi

  polled_tasks="$(list_unchecked_tasks)"

  if [[ "$polled_tasks" != "$last_seen_tasks" ]]; then
    last_seen_tasks="$polled_tasks"
    last_change="$SECONDS"
  elif [[ "$polled_tasks" != "$(list_reported_tasks)" ]] && ((SECONDS - last_change >= 120)); then
    added_tasks="$(comm -13 <(list_reported_tasks) <(echo "$polled_tasks") | sed -n '/./s/^/- /p')"
    echo "$polled_tasks" >"$(tasks_file)"

    if [[ -n "$added_tasks" ]]; then
      echo "New unchecked tasks in today's daily note:" >&2
      echo "$added_tasks" >&2
      exit 2
    fi
  fi
done
