---
name: write-skill
description: Use when creating, editing, evaluating, testing, or verifying ANY skill or skill-related file (SKILL.md, skill resources, skill scripts, or skill assets). If you're asked to evaluate or test a skill's effectiveness, use this skill.
---

Read these before writing or editing a skill:

- [Format Guide](references/format-guide.md)
- [Writing Instructions](references/writing-instructions.md)
- [Agent Skills](https://code.claude.com/docs/en/skills.md)
- [Skill Specification](https://raw.githubusercontent.com/agentskills/agentskills/main/docs/specification.mdx)
- [Skill Authoring Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md): Where it suggests stronger language such as "MUST", follow Writing Instructions instead. That advice predates current models.

Before writing, confirm the skill's purpose and expected outcome with the user, unless the request already makes both clear.

## New Plugins

A skill in a new plugin stays invisible until the plugin is registered and enabled, so land that first, as its own commit, before writing the skill:

1. Add `plugins/<plugin>/.claude-plugin/plugin.json` and the plugin's entry in the repository's root `.claude-plugin/marketplace.json`. Leave `version` out of both, so the plugin's version is its latest commit and installs pick up every merge.
2. Enable it in both Claude Code settings files, `~/.dotfiles/tag-personal/claude/settings.json` and `~/.dotfiles/tag-work/claude/settings.json`, as `"<plugin>@landonschropp": true`. Missing one leaves the plugin working on only half the machines.

The dotfiles are a separate repository, so that step lands there. Claude Code reads the setting at startup, so the new skill only appears in sessions opened afterwards.

## Testing

After writing a skill, ask the user whether they'd like you to test it. Many skills are tested by the user by hand, or can't be tested automatically.

When you test it, run each scenario in a fresh subagent, five or more times per variant, and read every result yourself:

1. **Run a control without the guidance:** Describe the scenario to the user first. If the agent already behaves correctly without the new guidance, the guidance isn't needed, so don't write it.
2. **Run it with the guidance:** Check the outcome the skill exists for, not only whether the agent followed the steps.
3. **Treat variance as a signal:** When the runs disagree on how to read the guidance, the wording isn't binding yet. Restructure it before adding more words.

To test triggering, run prompts that should and shouldn't load the skill, and tune the description against the rate at which it loads.

## Review

After changing a skill, run a prompt audit on the files you changed by invoking the `claude-api` skill with the `prompt-audit` subcommand, then act on its findings.

## Scripts

When a skill includes executable scripts, use the `ls-scripting:script` skill for language selection and conventions.

Installing a plugin copies its directory elsewhere, without the repository's dependency files such as a `Gemfile`. A skill script can't rely on them, so it must install its own dependencies, the way a Ruby script uses inline Bundler.

## State and Configuration

When a skill needs to store files outside the repository, such as state, configuration or data, read [State and Configuration](references/state-and-configuration.md).

## Interactive File Editing

When a skill needs the user to edit a file mid-workflow and hand the result back, have its SKILL.md invoke the `ls-interactivity:interactive-edit` skill.

## Claude Duet Skills

A skill is a Claude Duet skill when the user says so or its repository's documentation marks it as one. When writing or editing one, read [Claude Duet](references/claude-duet.md).
