#!/usr/bin/env bash

set -euo pipefail

readonly SETTLE_TIMEOUT_SECONDS=1800

# Longer than the five seconds herdr allows a prompt to start in, so a prompt that never starts is
# reported as stalled rather than reclassified as a timeout.
readonly DELIVERY_TIMEOUT_SECONDS=10

readonly REPLY_LINES=200

function print_help() {
  echo "Usage: prompt.sh --workspace <id> --prompt <text> [--wait]"
  echo
  echo "Sends a prompt to the agent running in a herdr workspace. With --wait, blocks until"
  echo "that agent stops — finished, or waiting on a permission prompt — and prints its"
  echo "terminal output, which includes the agent's own interface around the reply."
  echo
  echo "Options:"
  echo
  echo "  --workspace <id>   Workspace whose agent receives the prompt."
  echo "  --prompt <text>    Prompt to send."
  echo "  --wait             Wait for the agent to finish and print its output."
  echo "  --help             Show this help message and exit."
  echo
  echo "Exits non-zero if the agent never started the prompt, so a dropped delegation is"
  echo "never reported as delivered. It does not resend: herdr may have already typed the"
  echo "prompt in, and a retry would give the agent the same task twice."
  echo
  echo "Notes on --wait:"
  echo
  echo "  It settles on the agent stopping, which includes stopping to ask a permission"
  echo "  question. Answer that with 'herdr agent send-keys'."
  echo
  echo "  It does not track turns, so prompting an agent that is already working can"
  echo "  settle on the turn already in flight and print a reply to a different prompt."
}

# Parse arguments
workspace=""
prompt=""
wait_for_reply="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --workspace)
    workspace="$2"
    shift 2
    ;;
  --prompt)
    prompt="$2"
    shift 2
    ;;
  --wait)
    wait_for_reply="true"
    shift
    ;;
  *)
    echo "Error: The option $1 is invalid." >&2
    echo >&2
    print_help >&2
    exit 1
    ;;
  esac
done

# Validate required arguments
if [[ -z "$workspace" ]]; then
  echo "Error: The --workspace flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

if [[ -z "$prompt" ]]; then
  echo "Error: The --prompt flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

# herdr's agent commands address a pane, not a workspace.
pane=$(herdr agent list | jq --raw-output --arg id "$workspace" \
  'first(.result.agents[] | select(.workspace_id == $id) | .pane_id) // empty')

if [[ -z "$pane" ]]; then
  echo "Error: No agent is running in workspace $workspace." >&2
  exit 1
fi

# Always wait, since herdr confirms a prompt started only when asked to. A short timeout when the
# caller isn't waiting for the reply lets the agent keep working uninterrupted.
if [[ "$wait_for_reply" == "true" ]]; then
  timeout="$SETTLE_TIMEOUT_SECONDS"
else
  timeout="$DELIVERY_TIMEOUT_SECONDS"
fi

status=0
output=$(herdr agent prompt "$pane" "$prompt" --wait --timeout "$((timeout * 1000))" 2>&1) || status=$?

# A timeout means the prompt landed and the agent is still on it. Everything else non-zero means it
# never started, including agent_blocked, which herdr rejects before sending anything.
if [[ "$status" -ne 0 && "$output" != *timeout* ]]; then
  echo "Error: The agent in workspace $workspace never started the prompt." >&2
  echo "$output" >&2
  exit 1
fi

if [[ "$wait_for_reply" == "false" ]]; then
  exit 0
fi

if [[ "$status" -ne 0 ]]; then
  echo "Error: The agent in workspace $workspace did not finish. Its output follows." >&2
fi

herdr agent read "$pane" --source recent --lines "$REPLY_LINES" --format text
exit 0
