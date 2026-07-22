#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: interactive-command.sh --command '<command>' --name <name>"
  echo
  echo "Opens '<command>' in a new herdr tab named <name>, in the calling pane's"
  echo "workspace, then blocks until the tab closes. The command runs as the tab's"
  echo "only process, so the tab closes as soon as it exits, and the command"
  echo "persists its own result. The tab opens in the background, so it never"
  echo "pulls the user away from what they're doing. Must run inside herdr."
  echo
  echo "Exits with <command>'s own exit code once the tab closes, or 1 if the tab"
  echo "is closed before <command> finishes. Callers that don't care about this"
  echo "should ignore it explicitly (e.g. 'wait \"\$command_pid\" || true') rather"
  echo "than let 'set -e' abort on an exit code they don't need."
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

# The command runs in a pane herdr manages asynchronously, so its exit status can't be
# read back directly (herdr exposes no way to query it). Have the pane's shell write it
# to a file instead, and default to failure in case the tab closes before that happens.
exit_code_file="$(mktemp)"
echo 1 >"$exit_code_file"

# Create the tab in the background (--no-focus) in the caller's workspace, and
# capture its id and root pane's id (to run the command in).
read -r tab pane < <(
  herdr tab create --workspace "$HERDR_WORKSPACE_ID" --label "$name" --no-focus |
    jq -r '.result.tab.tab_id + " " + .result.root_pane.pane_id'
)

# Close the tab if this script exits before it closes naturally (e.g., when the
# agent terminates the background process). Callers read this script's stdout as
# the command's own output, so discard herdr's JSON responses here and below.
# Trap the termination signals explicitly, not just EXIT: an untrapped SIGTERM
# kills bash without running the EXIT trap, which would strand the tab open.
trap 'herdr tab close "$tab" >/dev/null 2>&1 || true' EXIT INT TERM HUP

# Run the command in the tab's pane, in the caller's directory, capturing its exit status to
# exit_code_file before `exit` terminates the shell and closes the tab, regardless of whether
# the command succeeded.
herdr pane run "$pane" "cd $(printf '%q' "$current_directory") && $command; echo \$? > $(printf '%q' "$exit_code_file"); exit" >/dev/null

# Block until the tab is gone (the command finished or the user closed it).
while herdr tab get "$tab" >/dev/null 2>&1; do
  sleep 0.5
done

# Relay the wrapped command's own exit status as this script's own.
exit "$(cat -- "$exit_code_file")"
