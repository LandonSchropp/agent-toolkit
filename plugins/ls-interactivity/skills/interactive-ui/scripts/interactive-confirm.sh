#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: interactive-confirm.rb --prompt <text> --affirmative <label> --negative <label> --name <name>"
  echo
  echo "Opens confirm.rb in a new herdr tab named <name>, blocks until the tab"
  echo "closes, then exits 0 for the affirmative choice or 1 for the negative"
  echo "choice or quit. Must run inside herdr."
  echo
  echo "Options:"
  echo
  echo "  --prompt <text>        Question to display."
  echo "  --affirmative <label>  Label for the affirmative button."
  echo "  --negative <label>     Label for the negative button."
  echo "  --name <name>          Name for the new tab's label."
  echo "  --help                 Show this help message and exit."
}

prompt=""
affirmative=""
negative=""
name=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --prompt)
    prompt="$2"
    shift 2
    ;;
  --affirmative)
    affirmative="$2"
    shift 2
    ;;
  --negative)
    negative="$2"
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

if [[ -z "$prompt" ]]; then
  echo "Error: The --prompt flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

if [[ -z "$affirmative" ]]; then
  echo "Error: The --affirmative flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

if [[ -z "$negative" ]]; then
  echo "Error: The --negative flag is required." >&2
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

if ! command -v gum >/dev/null 2>&1; then
  echo "Error: gum is not installed. See https://github.com/charmbracelet/gum." >&2
  exit 1
fi

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
confirm="$script_directory/confirm.rb"
interactive_command="$script_directory/../../interactive-command/scripts/interactive-command.sh"

# confirm.rb writes its result to a file since interactive-command.sh doesn't relay exit codes.
output="$(mktemp)"

command="'$confirm' --prompt $(printf '%q' "$prompt") --affirmative $(printf '%q' "$affirmative") --negative $(printf '%q' "$negative") --output '$output'"

# Forward termination to interactive-command.sh so an early kill still closes the herdr tab.
"$interactive_command" --command "$command" --name "$name" &
command_pid=$!
trap 'kill "$command_pid" 2>/dev/null || true' EXIT INT TERM HUP
wait "$command_pid"
trap - EXIT INT TERM HUP

# The tab has closed; relay confirm.rb's exit code as this script's own.
exit "$(cat -- "$output")"
