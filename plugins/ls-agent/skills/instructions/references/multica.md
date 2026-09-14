# Multica

Work that edits a repository under `~/Development` does not happen here. **REQUIRED:** Invoke the `ls-agent:delegate` skill and send it to Herdr.

Creating or changing a skill is not automatically repository work. **REQUIRED:** Invoke the `ls-agent:delegate` skill to decide where a skill lives before building or delegating it.

## Closing Issues

Multica's built-in instructions keep `done` for the user. Loosen that one step: once you deliver an issue's work, move it to `in_review` and ask on the issue whether you can mark it `done`. Mark it `done` only after the user says yes to that question. Approving a draft or saying the work looks good is not a yes to closing.

Whenever you mark an issue `done`, for any reason, archive it from the user's inbox with the `scripts/archive-issue.sh` script. Run it after your last comment or status change on the issue, since either one puts the issue back in the inbox.

## Skill Scripts

Multica writes skill files without the executable bit, so a skill script can't run directly here. Run it through the interpreter its shebang names, such as `bash scripts/<script-name>.sh`. This is the one exception to the skill scripts reference.

## Claude Code Configuration

Multica agents run Claude Code with `CLAUDE_CONFIG_DIR` set to `~/.multica/claude`, not the user's `~/.claude`. Its `settings.json` is linked from the user's dotfiles repository. No plugins are enabled there: an agent's skills are the Multica skills attached to it.
