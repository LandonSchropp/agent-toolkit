---
name: pull-request-feedback
description: Use when working through review feedback on a GitHub pull request — reading review and inline comments one by one, discussing and making changes, replying or reacting, then pushing and re-requesting review. Trigger on "review the PR feedback", "go through the comments", "address review feedback".
---

# Pull Request Feedback

## Context

Resolve the pull request and repository coordinates, and read the pull request's own title and description for context before looking at any feedback:

```bash
NUMBER=$(gh pr view --json number --jq '.number')
REPO=$(gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"')
gh pr view "$NUMBER" --json title,url,body
```

## Collect the comments

Merge inline review comments and general conversation comments into one chronological list, sorted by `created_at`, tagging bot authorship:

```bash
gh api "repos/$REPO/pulls/$NUMBER/comments" --paginate --jq '[.[] | select(.in_reply_to_id == null) | {kind: "review", id, path, line, body, bot: (.user.type == "Bot"), url: .html_url, created_at}]'
gh api "repos/$REPO/issues/$NUMBER/comments" --paginate --jq '[.[] | {kind: "general", id, body, bot: (.user.type == "Bot"), url: .html_url, created_at}]'
```

Drop a `bot: true` comment only when it's purely informational — a status postback, linkback, or automated report with nothing to act on (a Linear linkback, a bundle-size report). Judge this from the body. Keep a bot comment that leaves substantive review feedback, such as an automated review tool flagging a real issue in the code — walk it like any other comment.

## Summary

Before walking anything, print the review status and the comment count that survived the bot filter above:

```bash
gh pr view "$NUMBER" --json latestReviews --jq '.latestReviews[] | "\(.author.login): \(.state)"'
```

Format it like `✅ 2 approved · ❌ 1 changes requested · 💬 9 comments`: ✅ per approving reviewer, ❌ per reviewer who requested changes, 💬 for the total comment count (inline plus general, after dropping informational bot comments).

## Walk the comments

For each comment, in order:

1. Print `Comment <index> / <total>:`, then the body as a blockquote, verbatim — no summarizing or paraphrasing.
2. Discuss what to do about it and make any needed changes. Changes follow the normal commit-and-review flow already in effect for this session.
3. Ask whether to reply, react, or move on:
   - **Reply has any text in it** (even alongside an emoji): post it as a reply, not a reaction.
     - Review comment: `gh api "repos/$REPO/pulls/$NUMBER/comments/<id>/replies" -f body="..."`
     - General comment: `gh pr comment "$NUMBER" --body "..."`
   - **Reply is only an emoji**: post it as a reaction. Map to GitHub's fixed reaction set: 👍 → `+1`, 👎 → `-1`, 😄/😆/😂 → `laugh`, 😕/😐 → `confused`, ❤️/😍 → `heart`, 🎉/🥳 → `hooray`, 🚀 → `rocket`, 👀 → `eyes`. If it doesn't map, say so and ask for a supported emoji or a text reply instead.
     - Review comment: `gh api "repos/$REPO/pulls/comments/<id>/reactions" -f content="..."`
     - General comment: `gh api "repos/$REPO/issues/comments/<id>/reactions" -f content="..."`
   - **Move on**: no action, continue to the next comment.

## Wrap up

1. `git push`.
2. Re-request review only from reviewers whose latest review state (from the Summary step) isn't `APPROVED`: `gh pr edit "$NUMBER" --add-reviewer <login>`.
3. Find the Slack thread where this pull request was posted for review: search for the pull request's URL with the `slack:slack-search` skill. If found, offer to post a reply there — using the `slack:slack-messaging` skill's conventions — letting the reviewer know it's ready for re-review. If no thread turns up, say so and move on.

## Rationalizations

| Thought                                                   | Reality                                                                                          |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| "The reply has an emoji in it, react instead"             | Only pure-emoji replies become reactions. Any text goes in the reply body.                       |
| "I'll re-request from everyone"                           | Only reviewers who haven't approved need another look.                                           |
| "I'll paraphrase the comment to save space"               | Post it verbatim in the blockquote — the user is reading it, not a summary.                      |
| "General comments can be replied to like review comments" | GitHub has no reply endpoint for general comments — post a new comment instead.                  |
| "It's from a bot, drop it"                                | Only drop it if it's purely informational. A bot leaving real review feedback stays in the walk. |
