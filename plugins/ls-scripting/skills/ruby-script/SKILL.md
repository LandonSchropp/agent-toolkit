---
name: ruby-script
description: Use when writing a Ruby script. Covers the template, conventions, and required patterns.
---

## Template

Start from the template at [`assets/template.rb`](assets/template.rb). Copy it exactly and fill in the specific logic.

## Conventions

- File: `<name>.rb` with kebab-case (e.g., `extract-pr-number.rb`)
- Make the file executable (`chmod +x`)
- Flag-based arguments using `--flag-name` (kebab-case). Only use positional args for very simple cases.
- Full variable names (`directory`, not `dir`)
- Exit `0` for success, `1` for errors
- stdout for primary output, stderr for errors/warnings/progress messages

## Required patterns

- `#!/usr/bin/env ruby` shebang
- `# frozen_string_literal: true` magic comment, immediately after the shebang
- `print_help` method for help output
- `--help` flag handled inside the `OptionParser` block
- Use `OptionParser` from the standard library for argument parsing
- All error messages must start with `Error: ` and go to stderr via `warn`
- Always call `print_help` when validation fails or unknown options are encountered
- Validate required flags after parsing completes
- Rescue `OptionParser::InvalidOption` and print `Error: The option <option> is invalid.`
