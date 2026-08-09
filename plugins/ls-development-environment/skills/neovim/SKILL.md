---
description: Use when interacting with the user's local Neovim instance. Requires a running Neovim instance with a socket at `.agents/neovim.sock`.
---

# Neovim

Open a file in the user's running Neovim instance:

```bash
./skills/neovim/scripts/edit.sh --file <path>
```

To block until the user has finished editing, use the `ls-interactivity:interactive-edit` skill instead.
