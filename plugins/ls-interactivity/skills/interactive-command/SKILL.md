---
description: Runs an interactive command in a separate window and waits for it to close. Invoked only when another skill explicitly calls for it, never on its own.
user-invocable: false
---

# Interactive Command

Run `scripts/interactive-command.sh --command '<command>' --name <name>`. It opens the command in a new tmux window beside the agent's and blocks until that window closes. The command persists its own result — an editor saves the file it was given, so write a scratch file first and read it back after.

Always run the script in the background. After running the command, print a short message provided by the calling skill to let the user know it has been opened. You're notified when the window closes.
