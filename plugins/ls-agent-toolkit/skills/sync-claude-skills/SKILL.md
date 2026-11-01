---
name: sync-claude-skills
description: Use when skills need uploading to the user's claude.ai account so Claude Duet routines can run them, such as after merging skill changes into main or when the user asks to sync their claude.ai skills.
---

# Sync Claude Skills

Claude Duet routines can't run skills installed through plugins, so the skills they need are uploaded to claude.ai directly. The `scripts/build-skill-zips.rb` script owns the list of skills to upload.

1. Run `scripts/build-skill-zips.rb` with `--output` set to a directory in the session's scratchpad. Pass `--since <commit>` when you were given one, to build only the skills that changed. If it prints nothing, stop.
2. Add every zip it printed at https://claude.ai/customize/skills/new/upload, then start the upload. (Adding the files doesn't upload them.) **REQUIRED:** Use the `ls-browser:browser` skill.
3. For each skill that already exists, confirm "Upload and replace" as its prompt appears. Replacing keeps the earlier versions, so never delete a skill first.
4. Wait until every skill reports it was added, and tell the user about any that failed.

The Chrome `file_upload` tool only accepts files the session can share and caps one call at 10 MB. Split the upload across calls when the zips are larger than that.

## Rationalizations

| Thought                                  | Reality                                                               |
| ---------------------------------------- | --------------------------------------------------------------------- |
| "I'll zip the skill directory myself"    | The script builds from main and rewrites the plugin prefixes. Use it. |
| "I'll delete the old skill and re-add"   | Replacing keeps the version history. Confirm "Upload and replace".    |
| "I'll upload the changed skills by hand" | `--since` already picks them. Upload exactly what the script printed. |
