---
description: Use when opening a GitHub issue, bug report, feature request, or discussion in any repository, including one the user has no local checkout of.
---

# GitHub Issue

## Check It Isn't Already Handled

Search both, since a repository that routes features to discussions won't have them among its issues:

```bash
gh issue list --repo <owner>/<repo> --search "<terms>" --state all
gh discussion list --repo <owner>/<repo> --search "<terms>" --state all
```

Then confirm the thing being asked for doesn't already exist, which is a different question from whether it's been reported. Check the README, the changelog, and the tool's own `--help`.

Any hit ends the task. Tell the user what you found, with a link where there is one, and let them decide.

## Follow The Repository's Template

Maintainers wrote the template so reports arrive in a shape they can triage, and inventing a structure instead is the fastest way to get an issue closed. Before writing anything, find out what the repository expects, using `gh api repos/<owner>/<repo>/contents/<path>` when there's no local checkout:

- List `.github/ISSUE_TEMPLATE/` for issue forms and Markdown templates, and check the legacy `.github/ISSUE_TEMPLATE.md`.
- Read `.github/ISSUE_TEMPLATE/config.yml`. `blank_issues_enabled: false` means the maintainers expect one of the listed templates, and `contact_links` may route this kind of report somewhere else entirely.
- Check whether the repository routes this kind of report to discussions instead. The deciding evidence is `contact_links` or `CONTRIBUTING.md`, not `gh repo view <owner>/<repo> --json hasDiscussionsEnabled` on its own, since plenty of repositories enable discussions and still take feature requests as issues. When they do route it, look for a matching form in `.github/DISCUSSION_TEMPLATE/`, draft a discussion, and say so when presenting it for review.
- Read `CONTRIBUTING.md`.

Fill in every field the chosen template asks for, and delete nothing but its instructional comments. A Markdown template keeps its headings and their order. A YAML issue form has no headings of its own: each field's `label` becomes a `### <label>` heading, in the file's order, and every `required: true` field must be answered. When several templates could fit, ask the user which one.

## Write The Draft

Shape the draft as a bare title on the first line, a blank line, then the body, so the line maintainers read first goes through review too. The title is plain text, not a Markdown heading.

**REQUIRED:** Use the `ls-writing:format` skill on the prose inside the fields. The template owns the headings; never restyle them.

A person reads this. Include what a maintainer needs to act, and stop:

- Only the sections the template asks for. No extra headings.
- Give the shortest reproduction that triggers the problem, not a transcript of how it was found.
- Quote the relevant log or stack trace lines, not the whole output.
- Leave out speculation about the cause unless it was actually verified, and leave out the fix unless the user asked to propose one.
- No AI attribution, no emoji, no offers to submit a pull request the user didn't make.

## Get Approval

Write the draft to a scratch file, plus an empty file to diff it against. **REQUIRED:** Use the `ls-interactivity:interactive-review` skill in `diff <empty file> <draft>` mode.

Exit code 0 approves it. Nonzero means revise using the annotations and review again.

CRITICAL: Never submit an issue without the user explicitly approving the draft!

## Create It

Split the approved draft with `head -n 1 <draft>` for the title and `tail -n +3 <draft> > <body>` for the body, then run whichever one applies:

```bash
# An issue
gh issue create --repo <owner>/<repo> --title "<title>" --body-file <body>

# Or a discussion, which needs gh 2.100 or newer
gh discussion create --repo <owner>/<repo> --category "<category>" --title "<title>" --body-file <body>
```

Give the user the resulting URL.

## Rationalizations

| Thought                                          | Reality                                                            |
| ------------------------------------------------ | ------------------------------------------------------------------ |
| "They said the draft looks good in chat"         | Only exit code 0 from the review approves it. Nothing else does.   |
| "This repository's template doesn't fit"         | It's the maintainer's call, not yours. Use it or ask the user.     |
| "More context helps the maintainer"              | It buries the report. Include what they need to act, and stop.     |
| "A quick issue doesn't need the whole process"   | Every issue is drafted, reviewed and approved before it's created. |
| "The search found something, but file it anyway" | A hit ends the task. Report the link instead of drafting.          |
