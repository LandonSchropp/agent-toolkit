#!/usr/bin/env bash

set -euo pipefail

# SQLite database of reviewed commits and review overrides, shared with the commit hook.
DATABASE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-toolkit/reviews.db"

function print_help() {
  echo "Usage: interactive-review.sh <mode> [<arguments>] [--directory <path>]"
  echo
  echo "Opens Hunk in a background herdr tab named 'review' and prints the repository"
  echo "to listen to with 'hunk review listen --repo'. Returns right after starting"
  echo "Hunk; it doesn't wait for a decision. Must run inside herdr."
  echo
  echo "If a review of the same repository is already open, reloads it in place,"
  echo "keeping the user's comments. If a review of another repository is open,"
  echo "refuses rather than closing it."
  echo
  echo "A mode with no changes to review prints an error and exits 1 without opening"
  echo "a review. When review is disabled for this workspace, prints 'Review is"
  echo "disabled for this workspace.' instead and exits 0."
  echo
  echo "Modes:"
  echo
  echo "  working                 Review unstaged changes, including untracked files."
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

# The disable-review skill suspends the review requirement for a herdr workspace by recording its
# disable time. Treat the requirement as disabled while that time is within the last hour.
function is_review_disabled() {
  [[ -f "$DATABASE" ]] || return 1

  [[ -n "$(sqlite3 "$DATABASE" \
    "SELECT 1 FROM overrides
     WHERE workspace = '$HERDR_WORKSPACE_ID'
       AND disabled_at > strftime('%s', 'now') - 3600
     LIMIT 1;" 2>/dev/null)" ]]
}

# Refuse to open Hunk on nothing, which is almost always the wrong mode. Each check mirrors what
# Hunk shows in that mode, not whether the repository is dirty.
function require_changes_to_review() {
  case "$1" in
  working)
    if ! git diff --quiet || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
      return 0
    fi
    ;;
  staged | diff) if ! git diff --cached --quiet; then return 0; fi ;;
  commit)
    # A root commit has no parent, so compare it with the empty tree.
    local base
    base="$(git rev-parse --verify --quiet "$2^" || git hash-object -t tree /dev/null)"
    if ! git diff --quiet "$base" "$2"; then return 0; fi
    ;;
  esac

  echo "Error: The '$1' mode has no changes to review. Double check the mode is correct." >&2
  exit 1
}

# Copy one revision's content into the ephemeral repository. Handles both individual files and
# directories.
function copy_revision() {
  local source="$1" scratch
  scratch="$(mktemp -d)"

  if [[ -d "$source" ]]; then
    cp -R "$source/." "$scratch"
  else
    cp "$source" "$scratch/$(basename "$source")"
  fi

  find "$scratch" -name .git -prune -exec rm -rf {} +
  cp -R "$scratch/." .
}

# Stage two paths as the before and after of this workspace's ephemeral repository, and move into
# it. While a review is open the repository is updated in place, so the review reloads rather than
# starting over.
function prepare_diff() {
  local before after repository amend=(--amend)

  before="$(realpath "$1")"
  after="$(realpath "$2")"
  repository="$(realpath "${TMPDIR:-/tmp}")/agent-toolkit/review-$HERDR_WORKSPACE_ID"

  [[ -n "$(review_tab)" ]] || rm -rf "$repository"
  mkdir -p "$repository"
  cd "$repository"

  if [[ ! -d .git ]]; then
    git init --quiet .
    amend=()

    # Marks the repository as ephemeral, so approving the review records nothing.
    git config --local review.ephemeral true
  fi

  # These files are reviewed precisely because they are outside version control, so the global
  # ignore list — .env, *.local.md, tmp/ — must not decide what the user gets to see. Hence --force.
  find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
  copy_revision "$before"
  git add --all --force

  git commit --quiet --allow-empty "${amend[@]}" --message before

  find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
  copy_revision "$after"
  git add --all --force
}

# The review tab open in this workspace, if any.
function review_tab() {
  herdr tab list --workspace "$HERDR_WORKSPACE_ID" |
    jq --raw-output '.result.tabs[] | select(.label == "review") | .tab_id'
}

# The directory a review tab was opened in.
function review_directory() {
  herdr pane list --workspace "$HERDR_WORKSPACE_ID" |
    jq --raw-output --arg tab "$1" 'first(.result.panes[] | select(.tab_id == $tab) | .cwd)'
}

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

if [[ -z "${HERDR_ENV:-}" ]]; then
  echo "Error: This command can only be run within herdr." >&2
  exit 1
fi

mode="${positionals[0]:-}"

if [[ -z "$mode" ]]; then
  echo "Error: A mode is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

if [[ "$mode" != "diff" ]]; then
  if [[ -z "$directory" ]]; then
    echo "Error: The --directory flag is required." >&2
    echo >&2
    print_help >&2
    exit 1
  fi

  cd "$directory"
fi

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

# When review is disabled for this workspace the commit hook already allows commits, so there is
# nothing to review.
if is_review_disabled; then
  echo "Review is disabled for this workspace."
  exit 0
fi

# The arguments Hunk reviews each mode with.
case "$mode" in
working)
  require_changes_to_review working
  hunk_arguments=(diff --watch)
  ;;
staged)
  require_changes_to_review staged
  hunk_arguments=(diff --staged --watch)
  ;;
commit)
  require_changes_to_review commit "${positionals[1]}"
  hunk_arguments=(show --watch "${positionals[1]}")
  ;;
diff)
  prepare_diff "${positionals[1]}" "${positionals[2]}"
  require_changes_to_review diff
  hunk_arguments=(diff --staged --watch)
  ;;
esac

tab="$(review_tab)"

# When a review is already open, reload it with these changes rather than opening another.
if [[ -n "$tab" ]]; then
  open_directory="$(review_directory "$tab")"

  if [[ "$open_directory" != "$(pwd -P)" ]]; then
    echo "Error: A review of $open_directory is already open in this workspace. Close it first." >&2
    exit 1
  fi

  # Reload the open review in place, which keeps the user's comments.
  hunk session reload --repo "$PWD" -- "${hunk_arguments[@]}" >/dev/null
# Otherwise, open Hunk in a new review tab.
else
  # A shell in the herdr tab evaluates this string, so every word is quoted for it.
  printf -v command '%q ' hunk "${hunk_arguments[@]}"

  pane="$(
    herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd "$PWD" --label review --no-focus |
      jq --raw-output '.result.root_pane.pane_id'
  )"

  # The trailing `exit` closes the tab when Hunk quits.
  herdr pane run "$pane" "$command; exit" >/dev/null
fi

# Print the repository to listen to, which in diff mode is the temporary one.
pwd
