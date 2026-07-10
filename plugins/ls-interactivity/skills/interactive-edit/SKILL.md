---
description: Use when a skill needs the user to interactively edit a file in Neovim mid-workflow, then read their changes back. Takes a window name and the file to edit.
user-invocable: false
---

# Interactive Edit

Run `scripts/interactive-edit.sh --file <file> --name <name>`. It opens `<file>` in Neovim in a new tmux window, blocks until the window closes, and prints the user's saved edits to stdout — no separate read needed.

Run it in the background; it blocks until the window closes. To present generated content for editing, write it to a scratch file first and pass that as `<file>`.
