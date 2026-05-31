#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: recommend-merge-mode.sh [options]"
  echo
  echo "Inspect the current repository and recommend how to land a finished worktree branch:"
  echo
  echo "  direct-to-main   Merge the branch into the default branch (personal repos)."
  echo "  feature-branch   Keep the branch and push it for a pull request (shared repos)."
  echo
  echo "Prints the recommendation to stdout. This is a suggestion only — always confirm the mode"
  echo "with the user before landing the branch."
  echo
  echo "Options:"
  echo
  echo "  --help   Show this help message and exit."
}

# Print the recommendation in a single, agent-friendly two-line form and exit.
function recommend() {
  echo "Recommendation: $1"
  echo "Reason: $2"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  *)
    echo "Error: The option $1 is invalid." >&2
    echo >&2
    print_help >&2
    exit 1
    ;;
  esac
done

remote="origin"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: Not inside a Git repository." >&2
  exit 1
fi

# With no remote, this is a local-only repository — merge straight to the default branch.
if ! git remote get-url "$remote" >/dev/null 2>&1; then
  recommend "direct-to-main" "No '$remote' remote was found, so this looks like a local-only repository."
fi

# A CODEOWNERS file or pull request template indicates a pull request workflow.
if [[ -f .github/pull_request_template.md || -d .github/PULL_REQUEST_TEMPLATE || -f CODEOWNERS || -f .github/CODEOWNERS || -f docs/CODEOWNERS ]]; then
  recommend "feature-branch" "A pull request template or CODEOWNERS file exists, which indicates a pull request workflow."
fi

# The remaining signals come from GitHub. Without the CLI, fall back and let the user decide.
if ! command -v gh >/dev/null 2>&1; then
  recommend "direct-to-main" "The GitHub CLI is unavailable, so protection and ownership could not be checked — confirm with the user."
fi

repository_json=$(gh repo view --json owner,name,defaultBranchRef 2>/dev/null || true)
if [[ -z "$repository_json" ]]; then
  recommend "direct-to-main" "Could not read repository metadata from GitHub — confirm with the user."
fi

owner=$(echo "$repository_json" | jq -r '.owner.login')
repository_name=$(echo "$repository_json" | jq -r '.name')
default_branch=$(echo "$repository_json" | jq -r '.defaultBranchRef.name')

authenticated_user=$(gh api user --jq '.login' 2>/dev/null || echo "")
protected=$(gh api "repos/${owner}/${repository_name}/branches/${default_branch}" --jq '.protected' 2>/dev/null || echo "")

# A protected default branch is the strongest signal of a pull request workflow.
if [[ "$protected" == "true" ]]; then
  recommend "feature-branch" "The default branch '$default_branch' is protected, which indicates a pull request workflow."
fi

# A repository owned by someone other than the authenticated user is a shared repository.
if [[ -n "$authenticated_user" && "$owner" != "$authenticated_user" ]]; then
  recommend "feature-branch" "The repository owner '$owner' is not your account '$authenticated_user', which indicates a shared repository."
fi

# Otherwise this looks like a personal repository that works off the default branch.
if [[ -n "$authenticated_user" ]]; then
  recommend "direct-to-main" "You own '$owner/$repository_name' and the default branch '$default_branch' is not protected."
fi
recommend "direct-to-main" "The default branch '$default_branch' is not protected."
