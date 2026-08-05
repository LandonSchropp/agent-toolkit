---
description: Use when a commit's changes are finished and about to be presented for review. Runs the checks that catch the objections the user would otherwise raise, before they spend time reviewing.
---

# Pre-Review

Review your own changes adversarially before the user sees them. Assume the diff has a problem and go find it.

**REQUIRED:** Invoke the `ponytail-review` skill.

## Checks

- **Tests:** Every test the diff adds or changes has to follow this environment's testing skill. Search the available skills for the one covering tests in this language, framework, or layer of the stack, invoke it, and read the tests against its guidelines rather than trusting that you already followed them. Rewrite whatever diverges.
- **Documentation:** Documentation describes the observable behavior a function promises, not how it carries it out. Cut anything that restates the implementation, and cut the minutia that survives only because it was easy to write down. What's left should be brief and worth a human's time to read.
- **Commit size:** Reviews happen a commit at a time, so a diff carrying more than one logical change is harder to review than it needs to be. If this one can be split, split it before presenting anything. **REQUIRED:** Invoke the `git-atomic-commit` skill. Presenting the whole diff and offering to split it afterward doesn't count.

Fix everything the pre-review turns up. Then continue to the interactive review, and state in one line what you fixed and anything you deliberately left alone.
