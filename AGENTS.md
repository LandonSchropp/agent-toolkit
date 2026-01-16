## Project Overview

This is a personal toolkit for working with AI agents like Claude Code. The project uses Bun as the runtime and package manager. It contains skills following the [Agent Skills](https://agentskills.io/) specification and reusable documentation for agent workflows.

## Commands

- `bun check-types`: Run TypeScript type checking.
- `bun prettier --write <path>`: Format a file.

## Architecture

### Project Structure

- **TypeScript Config**: `tsconfig.json` at root validates the entire project
- **Skills**: Individual skills in `skills/` directory following Agent Skills specification
- **References**: Reusable documentation in `references/` directory
- **Commands**: Command documentation in `commands/` directory

### Environment Variables

Configured in `mise.toml`:

- `WRITING_FORMAT`: Path to markdown formatting guidelines document
- `PLANS_DIRECTORY`: Relative path to directory for storing plan files

## Code Quality

- Prettier configuration with import sorting and JSDoc plugins
- TypeScript strict mode enabled
- Consistent file naming: kebab-case for files, camelCase for exports
