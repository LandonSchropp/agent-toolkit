---
description: Runs an interactive command in a separate window and waits for it to close, and covers closing a herdr tab safely. Invoked only when another skill explicitly calls for it, never on its own.
user-invocable: false
---

# Interactive Command

Run `scripts/interactive-command.sh --command '<command>' --name <name>`. It opens the command in a new herdr tab in the agent's workspace and blocks until that tab closes. The command persists its own result — an editor saves the file it was given, so write a scratch file first and read it back after.

The script also exits with the command's own exit code once the tab closes (or 1 if the tab is closed before the command finishes). Read this exit code if the wrapped command's own success/failure is meaningful to the caller. If it isn't, ignore it explicitly — `wait "$command_pid" || true` — so `set -e` doesn't abort the caller on an exit code it doesn't care about.

Always run the script in the background, with no timeout, so it can run until the tab closes. After running the command, print a short message provided by the calling skill to let the user know it has been opened. You're notified when the tab closes.

## Closing a Tab

The script traps termination signals and closes its own tab on exit, so end the script rather than closing its tab: run it with the Bash tool's `run_in_background` and stop it with `TaskStop` on the task id it returns.

- **Never background a script with `&`.** `run_in_background` gives you a task id to stop it by and tells you when it finishes. `&` gives you neither.
- **Never hunt for a script's process.** `pkill -f`, `killall`, and `ps | grep | xargs kill` match every workspace and agent session on the machine, killing other sessions' tabs and the user's editors along with yours. A filter that looks scoped, like `grep "name review"`, is the worst: that label is identical in every workspace.

A tab left over from an earlier session has no task id. Close that one by tab id, scoped to the workspace since labels aren't unique across workspaces:

```bash
tab_id=$(herdr tab list --workspace "$HERDR_WORKSPACE_ID" | jq -r --arg label "<label>" '.result.tabs[] | select(.label == $label) | .tab_id')
[[ -n "$tab_id" ]] && herdr tab close "$tab_id"
```
