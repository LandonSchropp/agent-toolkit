---
description: Use when analyzing agent conversation logs to find repeated user instructions that could become skills. Ask for a date range first.
---

# Identify Skill Gaps

Analyze agent conversation logs to identify repeated instructions that could become skills.

## Workflow

1. Ask the user what date range to analyze.
2. Run `scripts/extract-user-messages.ts --path <logs-directory> --after YYYY-MM-DD`.
3. Apply the waste analysis framework from [references/wastes.md](references/wastes.md).
4. Report repeated patterns, their frequency, and prioritized skill opportunities.