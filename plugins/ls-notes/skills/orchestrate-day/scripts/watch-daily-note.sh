#!/usr/bin/env bash

set -euo pipefail

# Polls today's daily note and prints a line for each unchecked task that appears in it, such as
# "daily-note-task-added:<task>". It reports only once the note has gone two minutes without
# changing, so a burst of edits arrives as one batch. Runs until it is killed.

function list_unchecked_tasks() {
  local note
  note="$HOME/Notes/Daily Notes/$(date +%Y/%Y-%m/%Y-%m-%d) - Daily Note.md"

  if [[ -f "$note" ]]; then
    sed -n 's/^- \[ \] //p' "$note" | sort --unique
  fi
}

reported_tasks="$(list_unchecked_tasks)"
last_seen_tasks="$reported_tasks"
last_change="$SECONDS"

while true; do
  sleep 5

  polled_tasks="$(list_unchecked_tasks)"

  if [[ "$polled_tasks" != "$last_seen_tasks" ]]; then
    last_seen_tasks="$polled_tasks"
    last_change="$SECONDS"
  elif [[ "$last_seen_tasks" != "$reported_tasks" ]] && ((SECONDS - last_change >= 120)); then
    comm -13 <(echo "$reported_tasks") <(echo "$last_seen_tasks") |
      sed -n '/./s/^/daily-note-task-added:/p'

    reported_tasks="$last_seen_tasks"
  fi
done
