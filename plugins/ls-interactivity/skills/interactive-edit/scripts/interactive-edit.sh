#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: interactive-edit.sh --file <file> --name <name>"
  echo
  echo "Opens <file> in Neovim in a new herdr tab named <name>, blocks until the"
  echo "tab closes, then prints the file's contents to stdout. Write the content"
  echo "to be edited into <file> first; the user's saved edits are what gets printed."
  echo "Must run inside herdr."
  echo
  echo "Options:"
  echo
  echo "  --file <file>   File to open in the editor."
  echo "  --name <name>   Name for the new window's tab."
  echo "  --help          Show this help message and exit."
}

file=""
name=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --file)
    file="$2"
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

if [[ -z "$file" ]]; then
  echo "Error: The --file flag is required." >&2
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

if [[ ! -f "$file" ]]; then
  echo "Error: The file $file does not exist." >&2
  exit 1
fi

# Resolve the sibling interactive-command skill's script relative to this one.
# Both skills ship in the ls-interactivity plugin, so this layout is fixed
# wherever the plugin is installed.
script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
interactive_command="$script_directory/../../interactive-command/scripts/interactive-command.sh"

# Open the file in Neovim and wait for the tab to close. Run interactive-command
# in the background and forward termination to it so that if the agent kills this
# wrapper early, its cleanup still closes the herdr tab.
"$interactive_command" --command "nvim -- '$file'" --name "$name" &
command_pid=$!
trap 'kill "$command_pid" 2>/dev/null || true' EXIT
wait "$command_pid"
trap - EXIT

# The window has closed; print the user's saved edits.
cat -- "$file"
