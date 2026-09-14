# Multica

Work that edits a repository under `~/Development` does not happen here. **REQUIRED:** Invoke the `ls-agent:delegate` skill and send it to Herdr.

Creating or changing a skill is not automatically repository work. **REQUIRED:** Invoke the `ls-agent:delegate` skill to decide where a skill lives before building or delegating it.

## Closing Issues

Multica's built-in instructions keep `done` for the user. Loosen that one step: once you deliver an issue's work, move it to `in_review` and ask on the issue whether you can mark it `done`. Mark it `done` only after the user says yes to that question. Approving a draft or saying the work looks good is not a yes to closing.

## Claude Code Configuration

Multica agents run Claude Code with `CLAUDE_CONFIG_DIR` set to `~/.multica/claude`, not the user's `~/.claude`. Its `settings.json` is linked from the user's dotfiles repository. No plugins are enabled there: an agent's skills are the Multica skills attached to it.
