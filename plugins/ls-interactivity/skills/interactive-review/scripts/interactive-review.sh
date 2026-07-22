#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: interactive-review.sh <mode> [<sha>]"
  echo
  echo "Opens revdiff in a new herdr tab named 'review', blocks until the tab"
  echo "closes, then prints the user's annotations to stdout (empty if they left"
  echo "none). Must run inside herdr. See review.sh --help for what each mode diffs."
  echo
  echo "For 'working' and 'staged' mode, exits 0 if the user approved the"
  echo "changes when prompted after closing revdiff, or 1 if they denied (or"
  echo "closed the tab without answering). 'commit' mode has nothing to"
  echo "approve and always exits 0."
  echo
  echo "Modes:"
  echo
  echo "  working          Review uncommitted changes, including untracked files."
  echo "  staged           Review staged changes only."
  echo "  commit <sha>     Review a single commit's diff (its parent to itself)."
  echo
  echo "Options:"
  echo
  echo "  --help           Show this help message and exit."
}

positionals=()

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  -*)
    echo "Error: The option $1 is invalid." >&2
    echo >&2
    print_help >&2
    exit 1
    ;;
  *)
    positionals+=("$1")
    shift
    ;;
  esac
done

mode="${positionals[0]:-}"

if [[ -z "$mode" ]]; then
  echo "Error: A mode is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

# Validate the mode and its arity here so bad arguments fail before a window
# opens, rather than flashing a window that closes with empty output.
# _interactive-review.sh repeats these checks as the source of truth for what it
# accepts.
case "$mode" in
working | staged)
  if [[ "${#positionals[@]}" -gt 1 ]]; then
    echo "Error: The $mode mode does not take a sha." >&2
    echo >&2
    print_help >&2
    exit 1
  fi
  ;;
commit)
  if [[ "${#positionals[@]}" -ne 2 ]]; then
    echo "Error: The commit mode requires a single sha." >&2
    echo >&2
    print_help >&2
    exit 1
  fi
  if ! git rev-parse --verify --quiet "${positionals[1]}^{commit}" >/dev/null 2>&1; then
    echo "Error: The sha ${positionals[1]} is not a valid commit." >&2
    exit 1
  fi
  ;;
*)
  echo "Error: The mode $mode is invalid." >&2
  echo >&2
  print_help >&2
  exit 1
  ;;
esac

# Resolve the sibling scripts relative to this one. The private
# _interactive-review.sh lives in this skill; interactive-command.sh ships in the
# same ls-interactivity plugin, so both paths are fixed wherever the plugin is
# installed.
script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
inner="$script_directory/_interactive-review.sh"
interactive_command="$script_directory/../../interactive-command/scripts/interactive-command.sh"

# revdiff writes annotations to its own scratch file; we print them afterward.
output="$(mktemp)"

# Open the review and wait for the tab to close. Run interactive-command in
# the background and forward termination to it so that if the agent kills this
# wrapper early, its cleanup still closes the herdr tab. interactive-command.sh
# relays _interactive-review.sh's own exit code (0 approved, 1 denied for
# working/staged mode; always 0 for commit mode), so capture it here without
# letting `set -e` abort before the annotations are printed.
"$interactive_command" --command "'$inner' ${positionals[*]} --output '$output'" --name review &
command_pid=$!
trap 'kill "$command_pid" 2>/dev/null || true' EXIT INT TERM HUP
wait "$command_pid" || exit_code=$?
exit_code="${exit_code:-0}"
trap - EXIT INT TERM HUP

# The tab has closed; print the user's annotations, if any, then relay the
# approve/deny outcome as this script's own exit code.
cat -- "$output"
exit "$exit_code"
