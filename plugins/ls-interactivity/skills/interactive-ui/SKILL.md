---
description: Contains interactive interaction scripts. Use when another skill explicitly instructs invoking this one. Do not invoke on your own initiative.
user-invocable: false
---

# Interactive UI

## Scripts

- `scripts/interactive-confirm.sh --prompt <text> --affirmative <label> --negative <label> --name <name>`: Opens a themed approve/deny prompt for the user and blocks until the tab closes. Exits `0` for the affirmative choice or `1` for the negative choice (or quit).
