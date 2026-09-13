# Multica

Work that edits a repository under `~/Development` does not happen here. **REQUIRED:** Invoke the `ls-agent:delegate` skill and send it to Herdr.

Creating or changing a skill is not automatically repository work. **REQUIRED:** Invoke the `ls-agent:delegate` skill to decide where a skill lives before building or delegating it.

## Claude Code Configuration

Multica agents run Claude Code with `CLAUDE_CONFIG_DIR` set to `~/.multica/claude`, not the user's `~/.claude`. Its `settings.json` is linked from the user's dotfiles repository. No plugins are enabled there: an agent's skills are the Multica skills attached to it.
