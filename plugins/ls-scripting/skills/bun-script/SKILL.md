---
name: bun-script
description: Use when writing a TypeScript script with Bun. Covers the template, conventions, and required patterns.
---

## Template

Start from the template at [`assets/template.ts`](assets/template.ts). Copy it exactly and fill in the specific logic.

## Conventions

- File: `<name>.ts` with kebab-case (e.g., `extract-pr-number.ts`)
- Make the file executable (`chmod +x`)
- Flag-based arguments using `--flag-name` (kebab-case). Only use positional args for very simple cases.
- Variable names use camelCase (`outputDirectory`, not `output_directory`)
- Full variable names (`directory`, not `dir`)
- Exit `0` for success, `1` for errors
- stdout for primary output, stderr for errors/warnings/progress messages

## Required patterns

- `#!/usr/bin/env bun` shebang
- Use `cleye` for argument parsing (auto-generates `--help` and separates unknown flags into `argv.unknownFlags`)
- All error messages must start with `Error: ` and go to stderr via `console.error`
- Invalid options must print `Error: The option --<option> is invalid.`
- Validate required flags with explicit checks (cleye does not enforce required flags)
- Use `argv.showHelp()` to print help after error messages
- `process.exit(1)` on error
