# OpenClaw

Work that edits a repository under `~/Development` does not happen here. Hand it to the Developer agent with `sessions_send`; that agent owns development work and delegates it onward.

## Skill Names

Skills load by bare name here, without the plugin prefix the skills themselves write, so the `ls-notes:note` skill is `note`. Strip the prefix and invoke the skill under the name it loaded with.

Each agent carries its own allowlist, so a skill named that way may not be loaded here at all. When it isn't, it isn't available to you: say so, rather than reading the skill's files out of the repository and following them yourself.
