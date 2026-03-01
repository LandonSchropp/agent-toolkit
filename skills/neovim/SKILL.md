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
