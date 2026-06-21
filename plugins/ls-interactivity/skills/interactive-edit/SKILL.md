---
description: Use when a skill needs the user to interactively edit a file in Neovim mid-workflow, then read their changes back. Takes a window name and the file to edit.
user-invocable: false
---

# Interactive Edit

**REQUIRED:** Use the `interactive-command` skill, running `nvim <file>` with `<name>` as the window name.

When the window closes, `<file>` holds the user's edits — read it back and continue. To present generated content for editing, write it to a scratch file first and edit that.
