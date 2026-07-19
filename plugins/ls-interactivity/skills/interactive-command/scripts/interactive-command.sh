#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: interactive-command.sh --command '<command>' --name <name>"
  echo
  echo "Opens '<command>' in a new herdr tab named <name>, in the calling pane's"
  echo "workspace, then blocks until the tab closes. The command runs as the tab's"
  echo "only process, so the tab closes as soon as it exits, and the command"
  echo "persists its own result. The tab is foregrounded only if the user is"
  echo "currently looking at the calling pane. Must run inside herdr."
  echo
  echo "Options:"
  echo
  echo "  --command '<command>'   Command to run, given as a single string."
  echo "  --name <name>           Name for the new tab's label."
  echo "  --help                  Show this help message and exit."
}

command=""
name=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --command)
    command="$2"
    shift 2
    ;;
  --name)
    name="$2"
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

if [[ -z "$command" ]]; then
  echo "Error: The --command flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

if [[ -z "$name" ]]; then
  echo "Error: The --name flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

# Convert the name to kebab case.
name=$(printf '%s' "$name" | tr '[:upper:] _' '[:lower:]-')

if [[ -z "${HERDR_PANE_ID:-}" ]]; then
  echo "Error: interactive-command.sh must run inside herdr, but \$HERDR_PANE_ID is not set." >&2
  exit 1
fi

# A new herdr tab's pane starts in the workspace's default directory, not the
# one this script was invoked from. Capture the current directory so the command
# runs where it was invoked, matching the working directory the caller (e.g. a
# git-aware review) expects.
current_directory="$PWD"

# Create the tab in the background (--no-focus) in the caller's workspace, and
# capture its id and root pane's id (to run the command in).
read -r tab pane < <(
  herdr tab create --workspace "$HERDR_WORKSPACE_ID" --label "$name" --no-focus |
    jq -r '.result.tab.tab_id + " " + .result.root_pane.pane_id'
)

# Close the tab if this script exits before it closes naturally (e.g., when the
# agent terminates the background process).
trap 'herdr tab close "$tab" 2>/dev/null || true' EXIT

# Run the command in the tab's pane, in the caller's directory, followed by
# `exit` so the underlying shell terminates and the tab closes as soon as the
# command finishes, regardless of whether it succeeded.
herdr pane run "$pane" "cd $(printf '%q' "$current_directory") && $command; exit"

# Bring the new tab to the foreground only if the user is still looking at the
# calling pane; otherwise leave it in the background so we don't pull them away
# from whatever they're doing. Check this now rather than before the tab was
# created: the user may have moved to another workspace while the command was
# starting, and focusing the tab would yank them back to this one.
focused_pane="$(herdr pane get "$HERDR_PANE_ID" | jq -r '.result.pane.focused')"
focused_tab="$(herdr tab get "$HERDR_TAB_ID" | jq -r '.result.tab.focused')"
focused_workspace="$(herdr workspace get "$HERDR_WORKSPACE_ID" | jq -r '.result.workspace.focused')"

if [[ "$focused_pane" == "true" && "$focused_tab" == "true" && "$focused_workspace" == "true" ]]; then
  herdr tab focus "$tab"
fi

# Block until the tab is gone (the command finished or the user closed it).
while herdr tab get "$tab" >/dev/null 2>&1; do
  sleep 0.5
done
