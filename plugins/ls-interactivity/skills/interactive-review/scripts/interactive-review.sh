#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: interactive-review.sh <mode> [<arguments>] [--directory <path>]"
  echo
  echo "Opens revdiff in a new herdr tab named 'review', blocks until the tab"
  echo "closes, then prints the user's annotations to stdout (empty if they left"
  echo "none). Must run inside herdr."
  echo
  echo "Every mode but 'commit' exits 0 if the user approved the changes when"
  echo "prompted after closing revdiff, or 1 if they denied (or closed the tab"
  echo "without answering). 'commit' mode has nothing to approve and always"
  echo "exits 0. A mode with no changes to review prints an error and exits 1"
  echo "without opening a review."
  echo
  echo "Modes:"
  echo
  echo "  working                 Review uncommitted changes, including untracked files."
  echo "  staged                  Review staged changes only."
  echo "  commit <sha>            Review a single commit's diff (its parent to itself)."
  echo "  diff <before> <after>   Review one path against another. Both are files, or"
  echo "                          both are directories, and neither needs to be in a"
  echo "                          repository."
  echo
  echo "Options:"
  echo
  echo "  --directory <path>  Repository to review. Required by every mode but 'diff'."
  echo "  --help              Show this help message and exit."
}

# Resolve the sibling scripts relative to this one, before changing directory.
script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
inner="$script_directory/_interactive-review.sh"
interactive_command="$script_directory/../../interactive-command/scripts/interactive-command.sh"

directory=""
positionals=()

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --directory)
    directory="$2"
    shift 2
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

# Ensure every mode (except for diff) includes a repository directory.
if [[ "$mode" != "diff" ]]; then
  if [[ -z "$directory" ]]; then
    echo "Error: The --directory flag is required." >&2
    echo >&2
    print_help >&2
    exit 1
  fi

  cd "$directory"
fi

# Validate here so bad arguments fail before a window opens, rather than flashing one that
# closes with empty output. _interactive-review.sh's stderr dies with its tab, so this is the
# only place an argument error is visible.
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
diff)
  if [[ "${#positionals[@]}" -ne 3 ]]; then
    echo "Error: The diff mode requires a before path and an after path." >&2
    echo >&2
    print_help >&2
    exit 1
  fi

  for path in "${positionals[1]}" "${positionals[2]}"; do
    if [[ ! -e "$path" ]]; then
      echo "Error: The path $path does not exist." >&2
      exit 1
    fi
  done

  [[ -d "${positionals[1]}" ]] && before_is_directory=true || before_is_directory=false
  [[ -d "${positionals[2]}" ]] && after_is_directory=true || after_is_directory=false

  if [[ "$before_is_directory" != "$after_is_directory" ]]; then
    echo "Error: The before and after paths must both be files or both be directories." >&2
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

# revdiff writes annotations to its own scratch file; we print them afterward.
output="$(mktemp)"

# A shell in the herdr tab evaluates this string, so every word is quoted for it. diff mode's
# paths are the only arguments that can carry a space or a metacharacter.
command="$(printf '%q' "$inner")"

for positional in "${positionals[@]}"; do
  command+=" $(printf '%q' "$positional")"
done

command+=" --output $(printf '%q' "$output")"

# Open the review and wait for the tab to close. Run interactive-command in
# the background and forward termination to it so that if the agent kills this
# wrapper early, its cleanup still closes the herdr tab. interactive-command.sh
# relays _interactive-review.sh's own exit code (0 approved, 1 denied for every
# mode but commit, which is always 0), so capture it here without letting
# `set -e` abort before the annotations are printed.
"$interactive_command" --command "$command" --name review &
command_pid=$!
trap 'kill "$command_pid" 2>/dev/null || true' EXIT INT TERM HUP
wait "$command_pid" || exit_code=$?
exit_code="${exit_code:-0}"
trap - EXIT INT TERM HUP

# The tab has closed; print the user's annotations, if any, then relay the
# approve/deny outcome as this script's own exit code.
cat -- "$output"
exit "$exit_code"
