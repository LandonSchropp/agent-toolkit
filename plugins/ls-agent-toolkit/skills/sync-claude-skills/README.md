# Sync Claude Skills

Claude Duet runs some of its work in scheduled tasks. Those tasks can't load skills from plugins installed on the claude.ai account, so this skill uploads the skills they need to claude.ai directly as account skills.

## How This Was Determined

These tests ran on 2026-11-18.

### Setup

The `plugin-access-test` branch of [`personal-agent-toolkit`](https://github.com/LandonSchropp/personal-agent-toolkit/tree/plugin-access-test) adds a temporary plugin, `ls-plugin-access-test`, to that marketplace. Its one skill, `plugin-access-test`, tells Claude to reply with exactly "Plugin access test loaded: <marker>." The marker is a 4-character code that changes between tests.

1. Merge the branch into the marketplace's `main` and push it.
2. On [claude.ai](https://claude.ai/plugins/yours), add the marketplace under Add > Manage marketplaces, syncing from GitHub. Run "Check for updates" after each push.
3. Install the plugin with Add on its page.

The skill was never uploaded as an account skill, so only the plugin could supply it.

### Results

| Test                                                 | Result |
| ---------------------------------------------------- | ------ |
| The Duet main session runs the skill                 | Pass   |
| A sub-session entered directly runs the skill        | Pass   |
| The main session asks a sub-session to run the skill | Pass   |
| A recurring scheduled task runs the skill            | Fail   |

The scheduled task's prompt was exactly "Invoke the `ls-plugin-access-test:plugin-access-test` skill and return its result." Duet reported that no skill named `ls-plugin-access-test:plugin-access-test` existed for that run, even though the chat that created the task had the skill.

### Retesting

Each session keeps the plugin version it started with. The original chat kept returning the first marker after later syncs. A retest needs a fresh session and a fresh marker to prove the current version loaded.

### Other Reports

One [early-access review](https://superpowerdaily.com/posts/anthropic-opens-claude-duet-preview-for-ai-work-that-keeps-going-between-chats) reports that Duet's scheduled runs can't use custom connectors either.
