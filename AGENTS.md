**REQUIRED:** Read `README.md` before doing anything else. It documents the project's purpose, setup, and commands.

## Project Overview

This is a personal toolkit for working with AI agents like Claude Code. The project uses Bun as the runtime and package manager. It contains skills following the [Agent Skills](https://agentskills.io/) specification and reusable documentation for agent workflows.

## Commands

- `bun check-types`: Run TypeScript type checking.
- `bun prettier --write <path>`: Format a file.

## Architecture

### Project Structure

This is a monorepo. Each plugin lives under `plugins/` as its own subdirectory. To see all plugins and their descriptions, read `.claude-plugin/marketplace.json`.

- **TypeScript Config**: `tsconfig.json` at root validates the entire project
- **Plugins**: Individual plugins under `plugins/`, each with a `.claude-plugin/plugin.json`, `skills/`, and optionally `commands/`
- **References**: Reusable documentation in `references/` directory

When asked to edit a skill in this repository, always edit the skill under `plugins/<plugin-name>/skills/` here—not the installed copy in `~/.claude/skills/`.

### Interactive Command Workflow

Some skills need to hand control to the user in a separate window and block until they're done — running `revdiff` for a review, opening Neovim to edit a file, etc. That building block lives in `plugins/ls-interactivity`: `interactive-command` opens the given command in a new herdr tab and waits for it to close, and `interactive-review` and `interactive-edit` build on it for their respective workflows.

Not every prompt needs a fully executable window. When a skill just needs a simple UI — a quick yes/no, a short pick-one answer — its script calls `gum` (e.g. `gum confirm`, `gum choose`) directly instead of opening a new herdr tab: it runs synchronously in the current terminal and returns a plain result (exit code or stdout), so there's no window lifecycle to manage.

## Code Quality

- Prettier configuration with import sorting and JSDoc plugins
- TypeScript strict mode enabled
- Consistent file naming: kebab-case for files, camelCase for exports
- **Always run `bun check-types` after updating any TypeScript file**
- **Never write test files for Bash scripts** (e.g. `*.test.sh`). Verify Bash scripts manually instead.
