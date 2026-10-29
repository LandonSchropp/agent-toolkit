---
name: plan
description: Use when instructed to create a plan (feature, bug fix, or refactor).
---

# Planning

## Workflow

1. If the scope of the plan is not clear from the arguments or previous context, ask the user: "Please describe the plan or provide a Linear issue ID, Linear issue URL, Linear branch name, or Sentry issue URL (for bug-fix)." If the user responds with a Linear issue or branch name, fetch the issue details using the Linear MCP server. Linear branch names follow the pattern `[team-prefix]/[ISSUE-ID]-description` or `[ISSUE-ID]-description` (e.g., `landon/eng-123-fix-login` or `eng-123-fix-login`) — extract the issue ID with the regex `[A-Za-z]+-\d+` and uppercase it. If the user provides a Sentry issue URL (bug-fix only), store it for use in the plan template.

2. Copy `assets/plan.md` to a scratch file. Fill in the title, then complete the Linear Issue ID and Sentry Issue lines or delete them if they don't apply.

3. The Skills section comes pre-filled with the always-required skills. Review the available skills and add any additional ones that apply to the work, each on its own list item.

4. Fill out each section of the plan one at a time. Follow the instructions in the template for each section.
   - CRITICAL: DO NOT edit a Claude plan file in `.claude/plans`, and don't edit `assets/plan.md` itself. Only edit the copy you made.
   - Research the plan and its implementation before writing the Overview. Ask the user clarifying questions if needed to understand the task and what's required to implement it.
   - For the Commits section, invoke the `ls-git:git-atomic-commit` skill and apply its principles to decompose the implementation into ordered atomic commits, then fill in the list. Order the commits so the tree stays green at each step (pure refactors first, behavior changes on top). The plan file stores the commits as an ordered list, but when presenting the breakdown to the user in the conversation, render it as a table (columns: #, Commit, Contents).

5. **REQUIRED:** Launch one `general-purpose` subagent with the Agent tool, with `run_in_background: false`, and give it this prompt, with `<plan file>` resolved:

   > Apply the `ls-writing:streamline` skill to `<plan file>`, but report each cut instead of editing the file. Look for repetition and wordiness. Keep the template's sections.

   Apply the cuts that keep every commit, check and detail the work needs.

6. Once the cuts are applied, invoke the `ls-interactivity:interactive-edit` skill with the plan file so the user can review and edit it, then read their changes back. Where that skill isn't available, post the plan in the conversation instead, wait for the user's reply, and update the plan file with their changes.

ultrathink
