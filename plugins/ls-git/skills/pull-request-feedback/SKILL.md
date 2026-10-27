---
name: pull-request-feedback
description: Use when working through review feedback on a GitHub pull request or a stack of them — reading review and inline comments one by one, discussing and making changes, replying or reacting, then pushing and re-requesting review. Trigger on "review the PR feedback", "go through the comments", "address review feedback".
---

# Pull Request Feedback

## Stacks

When the pull request is part of a stack, walk the stack from the bottom up: check out each branch in turn and run every section below for it. Before starting on a branch's comments, sync it onto its updated parent so it picks up the fixes made lower in the stack, and run the relevant tests after resolving any conflicts, before continuing the sync. Fix any conflicts or breakages the sync surfaces, from the parent or `main`, through the normal commit-and-review flow already in effect for this session, then resume the walk. **REQUIRED:** Use the `ls-git:stacked-pull-requests` skill to find the stack and sync it.

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

Drop bot comments and threads the user already resolved or answered.

## Summary

Once the branch is synced, the summary line is the first thing the user sees for the pull request, before any other output about it. Print the review status and the comment count that survived the filters above:

```bash
gh pr view "$NUMBER" --json latestReviews --jq '.latestReviews[] | "\(.author.login): \(.state)"'
```

Format it like `✅ 2 approved · ❌ 1 changes requested · 💬 9 comments`: ✅ per approving reviewer, ❌ per reviewer who requested changes, 💬 for the total comment count (inline plus general, after the filters).

## Walk the comments

Each comment is decided with the user when the walk reaches it. Never decide or batch comments ahead of time, and never fold them into a plan, including one from `ls-agent:plan`.

For each comment, in order:

1. Print `Comment <index> / <total>:`, then the body as a blockquote, verbatim — no summarizing or paraphrasing. Follow it with a short recommendation and the proposed change, nothing more, and leave out how it affects pull requests higher in the stack.
2. Discuss what to do about it and make any needed changes. Changes follow the normal commit-and-review flow already in effect for this session.
3. Draft a reply for the user to approve or edit, or ask whether to react or move on:
   - **Reply has any text in it** (even alongside an emoji): post it as a reply, not a reaction. If it refers to a code change, push that change first.
     - Review comment: `gh api "repos/$REPO/pulls/$NUMBER/comments/<id>/replies" -f body="..."`
     - General comment: `gh pr comment "$NUMBER" --body "..."`
   - **Reply is only an emoji**: post it as a reaction. Map to GitHub's fixed reaction set: 👍 → `+1`, 👎 → `-1`, 😄/😆/😂 → `laugh`, 😕/😐 → `confused`, ❤️/😍 → `heart`, 🎉/🥳 → `hooray`, 🚀 → `rocket`, 👀 → `eyes`. If it doesn't map, say so and ask for a supported emoji or a text reply instead.
     - Review comment: `gh api "repos/$REPO/pulls/comments/<id>/reactions" -f content="..."`
     - General comment: `gh api "repos/$REPO/issues/comments/<id>/reactions" -f content="..."`
   - **Move on**: no action, continue to the next comment.

## Wrap up

1. `git push`.
2. Check CI with `gh pr checks "$NUMBER"`. Before fixing a failing check, make sure it isn't a cancelled run with a passing sibling on the same commit.
3. Re-request review only from reviewers whose latest review state (from the Summary step) isn't `APPROVED`: `gh pr edit "$NUMBER" --add-reviewer <login>`.
4. Find the Slack thread where this pull request was posted for review: search for the pull request's URL with the `slack:slack-search` skill. If found, offer to post a reply there — using the `slack:slack-messaging` skill's conventions — letting the reviewer know it's ready for re-review. If no thread turns up, say so and move on.

## Rationalizations

| Thought                                                   | Reality                                                                         |
| --------------------------------------------------------- | ------------------------------------------------------------------------------- |
| "The reply has an emoji in it, react instead"             | Only pure-emoji replies become reactions. Any text goes in the reply body.      |
| "I'll re-request from everyone"                           | Only reviewers who haven't approved need another look.                          |
| "I'll paraphrase the comment to save space"               | Post it verbatim in the blockquote — the user is reading it, not a summary.     |
| "General comments can be replied to like review comments" | GitHub has no reply endpoint for general comments — post a new comment instead. |
| "I'll decide them all up front and put them in the plan"  | Each comment is decided with the user when the walk reaches it.                 |
| "I'll describe the pull request first"                    | The summary line is the first thing the user sees for each pull request.        |
| "This rebase conflict is a detour from the walk"          | Fix it through the commit-and-review flow, then resume the walk.                |
