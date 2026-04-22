---
name: script
description: Use when creating a new command-line script or standalone executable from scratch. Covers language selection and defers to a language-specific skill for conventions and templates.
---

## Choose the language

Pick the language that makes the task simplest:

- **Bash:** orchestrating CLI tools (`git`, `grep`, `jq`, `curl`) and piping commands. Avoid when logic grows complex or you need data structures.
- **Ruby:** file parsing and text manipulation, especially with regular expressions. Rich standard library with no dependencies.
- **Bun/TypeScript:** external NPM packages, complex data transformation, or type safety. Use when correctness matters.

The best choice is the one that's simplest for the job.

## Next steps

Once you've picked a language, follow its skill:

- **REQUIRED:** Use the `bash-script` skill for Bash
- **REQUIRED:** Use the `ruby-script` skill for Ruby
- **REQUIRED:** Use the `bun-script` skill for Bun/TypeScript
