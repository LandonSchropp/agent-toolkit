---
description: Use when creating or updating a pull request.
---

# Creating and Updating Pull Requests

## Process

1. **Analyze changes:** Invoke the `git-diff-feature-branch` skill to get the current branch's changes and determine the base branch. If there are no changes, stop.

2. **Check for Linear issue:** Run `scripts/extract-issue-from-current-branch.sh` to check if the current branch has a Linear issue ID. If it outputs an issue ID, fetch the Linear issue using the Linear MCP.

3. **Check for existing PR:** Run `gh pr view --json number,title,body` to check if a PR already exists for the current branch. If it does, note the PR number - you'll be updating this PR instead of creating a new one.

4. **Create PR title:** Write a clear, descriptive title that explains what the PR accomplishes. Often this will be a slightly reworked version of the Linear issue title. If there's a Linear issue, prepend the title with the issue ID in square brackets.

   Examples:
   - Add user profile management system
   - Update API documentation with examples
   - [IAM-12] Resolve authentication timeout issues
   - [AI-345] Simplify database connection logic

5. **Create PR description:** Write a concise description focused on essential information. Keep it brief and focused.
   - Check for a PR template at `.github/pull_request_template.md`
     - If it exists, use it:
       - If the PR contains a checklist, review each item and determine completion. Ask user if unsure. Remove the checklist section when done.
       - Remove merging instructions or generic template text
       - Keep screenshots/demo sections but leave them empty
     - If no template exists, create a simple description with Summary and Changes sections:
       - **Summary:** Short paragraph explaining what changed and why
       - **Changes:** Bulleted list of key modifications
   - For simple changes, use a single paragraph summary only
   - Focus on what changed and why, not implementation details
   - Use backticks for code terms, file names, and technical references

6. **Present for review:** Show the proposed PR title and body to the user. Display them clearly formatted. Indicate whether this will create a new PR or update an existing one. Ask if they'd like to proceed or make changes.

7. **Create or update PR:** After user approval:
   - Push commits: `git push`
   - If a PR exists, update it: `gh pr edit --title "<title>" --body "<description>" --base "<base-branch>"`
   - If no PR exists, create it: `gh pr create --title "<title>" --body "<description>" --base "<base-branch>" --web`
