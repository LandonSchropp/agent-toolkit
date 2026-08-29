---
description: Use when a skill needs the user to interactively edit a file in Neovim mid-workflow, then read their changes back. Takes a window name and the file to edit.
user-invocable: false
---

# Interactive Edit

Run `scripts/interactive-edit.sh --file <file> --name <name>`. It opens `<file>` in Neovim in a new herdr tab, blocks until the tab closes, and prints the user's saved edits to stdout — no separate read needed.

Run it in the background; it blocks until the tab closes. To present generated content for editing, write it to a scratch file first and pass that as `<file>`.

## Editing While the Tab Is Open

The file being open in Neovim is not a lock. If the user asks for a change while the tab is open, edit the file on disk with the normal file tools and tell the user it changed. Neovim reloads it automatically unless the user has unsaved edits in the buffer, in which case it prompts them to reconcile on their next write. Don't wait for the tab to close, ask the user to close it, or route the edit through Neovim.

## Rationalizations

| Thought                                                  | Reality                                                          |
| -------------------------------------------------------- | ---------------------------------------------------------------- |
| "The file is open, so I'll wait or ask them to close it" | Neovim picks up disk changes. Edit now and say the file changed. |
