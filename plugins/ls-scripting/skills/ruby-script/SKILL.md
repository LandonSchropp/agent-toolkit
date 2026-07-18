---
name: ruby-script
description: Use when writing a Ruby script. Covers the template, conventions, and required patterns.
---

## Template

Two templates cover the two kinds of scripts. Copy the right one exactly and fill in the specific logic.

- **Simple:** Scripts intended to be run directly by a user. These typically take either no arguments or a single positional argument. Start from [`assets/template-simple.rb`](assets/template-simple.rb). It shows the one-argument form; if the script takes no arguments, delete the argument check and keep the top comment.
- **Complex:** Scripts capable of taking multiple arguments via flags. Skill scripts should _always_ be considered complex scripts. Start from [`assets/template-complex.rb`](assets/template-complex.rb). These always support `--help`.

## Conventions

- File: `<name>.rb` with kebab-case (e.g., `extract-pr-number.rb`)
- Make the file executable (`chmod +x`)
- Flag-based arguments using `--flag-name` (kebab-case). Only use positional args for very simple cases.
- Arguments are always required. Never make script arguments optional unless the user _explicitly_ asks for it.
- Full variable names (`directory`, not `dir`)
- Exit `0` for success, `1` for errors
- stdout for primary output, stderr for errors/warnings/progress messages

## Required patterns

Always:

- `#!/usr/bin/env ruby` shebang
- `# frozen_string_literal: true` magic comment, after the shebang
- All error messages must start with `Error: ` and go to stderr via `warn`

Simple scripts:

- A top comment describing what the script does
- No `--help` flag
- If it takes an argument, print a usage message to stderr and exit `1` when the argument is missing

Complex scripts:

- `print_help` method for help output
- `--help` flag handled inside the `OptionParser` block
- Use `OptionParser` from the standard library for argument parsing
- Always call `print_help` when validation fails or unknown options are encountered
- Validate required flags after parsing completes
- Rescue `OptionParser::InvalidOption` and print `Error: The option <option> is invalid.`
