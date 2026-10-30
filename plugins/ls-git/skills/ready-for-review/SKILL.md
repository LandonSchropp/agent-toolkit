---
name: ready-for-review
description: Use only in a work repository, when the user has explicitly said or approved that a pull request is ready for review, to mark it ready on GitHub and post it to the team's Slack review channels. Never invoke it on your own judgment that the work looks done.
---

# Ready for Review

Invoking this skill is the approval to post. Don't ask again before posting.

Handle each pull request on its own, including every pull request in a stack:

1. **Mark it ready:** Run `gh pr ready <url>`.
2. **Read the channels:** Run `scripts/read-review-channels.sh --pull-request-url <url>`. It waits for the bot comment that lists the pull request's review channels, then prints the title, URL, line counts and channels. If it fails or lists no channels, stop and ask the user where to post.
3. **Post:** For each channel, find its ID with the Slack `slack_search_channels` tool, then send one message with `slack_send_message`, leaving `unfurl_app_links` unset:

   ```text
   [<title>](<url>) `+<additions>/-<deletions>`
   ```

4. **Report:** Give the user each message's Slack link.

## Rationalizations

| Thought                                            | Reality                                                                               |
| -------------------------------------------------- | ------------------------------------------------------------------------------------- |
| "One message can cover the whole stack"            | The review integration tracks one message per pull request. Post each one separately. |
| "The bot comment has copy-paste text ready to go"  | Its format isn't the one the user wants. Use the line above.                          |
| "A link preview makes the message clearer"         | The user doesn't want the preview. Leave `unfurl_app_links` unset.                    |
| "No comment yet, so I'll guess the team's channel" | A guess posts to the wrong team. Ask the user.                                        |
