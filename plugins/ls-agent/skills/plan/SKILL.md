---
description: Use when explicitly instructed to create an plan (feature, bug fix, or refactor). Not for automatic use—only when directly requested.
allowed-tools: Read, Write, Edit, Glob, Grep, EnterPlanMode, Skill
---

# Planning

## Workflow

1. If the scope of the plan is not clear from the arguments or previous context, ask the user: "Please describe the plan or provide a Linear issue ID, Linear issue URL, Linear branch name, or Sentry issue URL (for bug-fix)." If the user responds with a Linear issue or branch name, fetch the issue details using the Linear MCP server. Linear branch names follow the pattern `[team-prefix]/[ISSUE-ID]-description` or `[ISSUE-ID]-description` (e.g., `landon/eng-123-fix-login` or `eng-123-fix-login`) — extract the issue ID with the regex `[A-Za-z]+-\d+` and uppercase it. If the user provides a Sentry issue URL (bug-fix only), store it for use in the plan template.

2. Determine the feature branch. If the user provided a Linear branch name, use it as the feature branch. If the user provided a Linear issue (without a branch), use the branch specified in the issue. If the current branch is the default branch (main/master), ask the user: "What feature branch would you like to use?" Otherwise, ask the user: "Would you like to use `{current_branch}` as the feature branch?"

3. If the current branch is the feature branch, move on to step 4. Otherwise, ask the user: "Would you like to use `{current_branch}` as the base branch?". Then call `scripts/create-feature-branch.sh` with the feature branch and the base branch.

4. Read `assets/plan.md` and write it to `/tmp/{feature_branch}.md`, replacing any `/` in the branch name with `-`. Fill in the title, worktree, and branch fields in the header, then complete the Linear Issue ID and Sentry Issue lines or delete them if they don't apply.

5. The Skills section comes pre-filled with the always-required skills. Review the available skills and add any additional ones that apply to the work (e.g., `ls-typescript:testing-typescript`, `ls-ruby:rspec`), each on its own list item.

6. Fill out each section of the plan one at a time. Follow the instructions in the template for each section.
   - CRITICAL: DO NOT edit a Claude plan file in `.claude/plans`, and don't edit `assets/plan.md` itself. Only edit the copy you made.
   - Research the plan and its implementation before writing the Overview. Ask the user clarifying questions if needed to understand the task and what's required to implement it.
   - For the Commits section, invoke the `ls-git:git-atomic-commit` skill and apply its principles to decompose the implementation into ordered atomic commits, then fill in the list. Order the commits so the tree stays green at each step (pure refactors first, behavior changes on top). The plan file stores the commits as an ordered list, but when presenting the breakdown to the user in the conversation, render it as a table (columns: #, Commit, Contents).

7. After the plan is complete, invoke the `ls-interactivity:interactive-edit` skill with the plan file so the user can review and edit it, then read their changes back.

ultrathink
