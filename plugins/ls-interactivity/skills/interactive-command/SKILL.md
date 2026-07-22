---
description: Runs an interactive command in a separate window and waits for it to close. Invoked only when another skill explicitly calls for it, never on its own.
user-invocable: false
---

# Interactive Command

Run `scripts/interactive-command.sh --command '<command>' --name <name>`. It opens the command in a new herdr tab in the agent's workspace and blocks until that tab closes. The command persists its own result — an editor saves the file it was given, so write a scratch file first and read it back after.

The script also exits with the command's own exit code once the tab closes (or 1 if the tab is closed before the command finishes). Read this exit code if the wrapped command's own success/failure is meaningful to the caller. If it isn't, ignore it explicitly — `wait "$command_pid" || true` — so `set -e` doesn't abort the caller on an exit code it doesn't care about.

Always run the script in the background, with no timeout, so it can run until the tab closes. After running the command, print a short message provided by the calling skill to let the user know it has been opened. You're notified when the tab closes.
