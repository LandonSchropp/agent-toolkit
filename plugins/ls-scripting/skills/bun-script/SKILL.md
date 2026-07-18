---
name: bun-script
description: Use when writing a TypeScript script with Bun. Covers the template, conventions, and required patterns.
---

## Template

Two templates cover the two kinds of scripts. Copy the right one exactly and fill in the specific logic.

- **Simple:** Scripts intended to be run directly by a user. These typically take either no arguments or a single positional argument. Start from [`assets/template-simple.ts`](assets/template-simple.ts). It shows the one-argument form; if the script takes no arguments, delete the argument check and keep the top comment.
- **Complex:** Scripts capable of taking multiple arguments via flags. Skill scripts should _always_ be considered complex scripts. Start from [`assets/template-complex.ts`](assets/template-complex.ts). These always support `--help`.

## Conventions

- File: `<name>.ts` with kebab-case (e.g., `extract-pr-number.ts`)
- Make the file executable (`chmod +x`)
- Flag-based arguments using `--flag-name` (kebab-case). Only use positional args for very simple cases.
- Arguments are always required. Never make script arguments optional unless the user _explicitly_ asks for it.
- Variable names use camelCase (`outputDirectory`, not `output_directory`)
- Full variable names (`directory`, not `dir`)
- Exit `0` for success, `1` for errors
- stdout for primary output, stderr for errors/warnings/progress messages

## Required patterns

Always:

- `#!/usr/bin/env bun` shebang
- All error messages must start with `Error: ` and go to stderr via `console.error`
- `process.exit(1)` on error

Simple scripts:

- A top comment describing what the script does
- No `--help` flag
- If it takes an argument, print a usage message to stderr and exit `1` when the argument is missing

Complex scripts:

- Use `cleye` for argument parsing (auto-generates `--help` and separates unknown flags into `argv.unknownFlags`)
- Invalid options must print `Error: The option --<option> is invalid.`
- Validate required flags with explicit checks (cleye does not enforce required flags)
- Use `argv.showHelp()` to print help after error messages
