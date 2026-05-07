---
name: bash-script
description: Use when writing a Bash script. Covers the template, conventions, and required patterns.
---

## Template

Start from the template at [`assets/template.sh`](assets/template.sh). Copy it exactly and fill in the specific logic.

## Conventions

- File: `<name>.sh` with kebab-case (e.g., `extract-pr-number.sh`)
- Make the file executable (`chmod +x`)
- Flag-based arguments using `--flag-name` (kebab-case). Only use positional args for very simple cases.
- Full variable names (`directory`, not `dir`)
- Exit `0` for success, `1` for errors
- stdout for primary output, stderr for errors/warnings/progress messages

## Required patterns

- `set -euo pipefail` at the top of every script
- `print_help()` function for help output
- `--help` flag must be the first case in argument parsing
- All error messages must start with `Error: ` and go to stderr (`>&2`)
- Always print help to stderr when validation fails or unknown options are provided
- Always quote variable expansions (`"$variable"`)
- Validate required flags after the parsing loop completes
- Invalid options must print `Error: The option <option> is invalid.`

## References

For colored terminal output, see [`references/colored-echo.md`](references/colored-echo.md).
