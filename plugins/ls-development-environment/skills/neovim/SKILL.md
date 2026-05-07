---
description: Use when interacting with the user's local Neovim instance. Requires a running Neovim instance with a socket at `.agents/neovim.sock`.
---

# Neovim

This skill provides several scripts for interacting with the user's local Neovim instance.

## Edit

Open a file in the user's running Neovim instance:

```bash
./skills/neovim/scripts/edit.sh --file <path>
```

## Edit and Wait

Open a file in Neovim and block until the user saves it. Useful when the agent needs the user to review or modify a file before continuing. Exits non-zero if the file is not saved within 15 minutes.

```bash
./skills/neovim/scripts/edit-and-wait.sh --file <path>
```

Set the Bash tool timeout to 15 minutes (900000ms) when running this script.
