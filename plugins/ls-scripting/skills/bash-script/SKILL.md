---
name: bash-script
description: Use when writing a Bash script. Covers the template, conventions, and required patterns.
---

## Template

Two templates cover the two kinds of scripts. Copy the right one exactly and fill in the specific logic.

- **Simple:** Scripts intended to be run directly by a user. These typically take either no arguments or a single positional argument. Start from [`assets/template-simple.sh`](assets/template-simple.sh). It shows the one-argument form; if the script takes no arguments, delete the argument check and keep the top comment.
- **Complex:** Scripts capable of taking multiple arguments via flags. Skill scripts should _always_ be considered complex scripts. Start from [`assets/template-complex.sh`](assets/template-complex.sh). These always support `--help`.

## Conventions

- File: `<name>.sh` with kebab-case (e.g., `extract-pr-number.sh`)
- Make the file executable (`chmod +x`)
- Flag-based arguments using `--flag-name` (kebab-case). Only use positional args for very simple cases.
- Arguments are always required. Never make script arguments optional unless the user _explicitly_ asks for it.
- Full variable names (`directory`, not `dir`)
- Exit `0` for success, `1` for errors
- stdout for primary output, stderr for errors/warnings/progress messages

## Required patterns

Always:

- `set -euo pipefail` at the top of every script
- All error messages must start with `Error: ` and go to stderr (`>&2`)
- Always quote variable expansions (`"$variable"`)

Simple scripts:

- A top comment describing what the script does
- No `--help` flag
- If it takes an argument, print a usage message to stderr and exit `1` when the argument is missing

Complex scripts:

- `print_help()` function for help output
- `--help` flag must be the first case in argument parsing
- Always print help to stderr when validation fails or unknown options are provided
- Validate required flags after the parsing loop completes
- Invalid options must print `Error: The option <option> is invalid.`

## References

For colored terminal output, see [`references/colored-echo.md`](references/colored-echo.md).
