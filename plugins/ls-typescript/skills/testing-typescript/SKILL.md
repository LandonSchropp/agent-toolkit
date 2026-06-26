---
description: Use when writing tests for TypeScript or JavaScript code in frameworks such as Jest, Vitest, Bun, etc.
---

Read:

- [Better Tests](references/better-tests.md)
- [Personal Preferences](references/personal-preferences.md)

## Framework-Specific Conventions

After reading the references above, invoke the skill matching the project's test framework.

| How to detect                                            | Skill to invoke |
| -------------------------------------------------------- | --------------- |
| Imports from `bun:test`, or a `bunfig.toml` / `bun.lock` | `testing-bun`   |

## Renderer-Specific Conventions

These apply on top of the framework skill above, based on what you're testing.

| What you're testing            | Skill to invoke |
| ------------------------------ | --------------- |
| A React hook                   | `testing-react` |
| An Ink (terminal UI) component | `testing-ink`   |
