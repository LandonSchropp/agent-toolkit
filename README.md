# Agent Toolkit

This repository contains my personal toolkit for working with AI agents such as Claude Code and
Codex CLI. It's primarily composed of skills, which are implemented following the [Agent
Skills](https://agentskills.io/) specification. It also contains reusable documentation which is
intended to be referenced in `AGENTS.md` files.

The toolkit is customized to my personal workflow, and isn't meant to be used by anyone else,
although others are welcome to use it if they'd like.

## Installation

### Claude Code

To use this toolkit with Claude Code, first add the marketplace provided by this plugin.

```sh
claude plugin marketplace add ./.claude-plugin/marketplace.json
```

Then, you can install the `ls` plugin normally.

```sh
claude plugin install ls
```

### Copilot CLI

To use this toolkit with the
[GitHub Copilot CLI](https://docs.github.com/en/copilot/concepts/agents/about-plugins), first add the
marketplace.

```sh
copilot plugin marketplace add LandonSchropp/agent-toolkit
```

Then install the plugins you want by name.

```sh
copilot plugin install ls-git@landonschropp
copilot plugin install ls-scripting@landonschropp
copilot plugin install ls-typescript@landonschropp
copilot plugin install ls-ruby@landonschropp
copilot plugin install ls-code@landonschropp
copilot plugin install ls-agent@landonschropp
copilot plugin install ls-agent-toolkit@landonschropp
copilot plugin install ls-writing@landonschropp
copilot plugin install ls-browser@landonschropp
```
