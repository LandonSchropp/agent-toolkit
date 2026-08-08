# Pre-Review Checks

Review the diff adversarially. Assume it has a problem and go find it.

**REQUIRED:** Invoke the `ponytail-review` skill and fold its findings into your report.

## Checks

- **Tests:** Every test the diff adds or changes has to follow this environment's testing skill. Search the available skills for the one covering tests in this language, framework, or layer of the stack, invoke it, and read the tests against its guidelines. Report whatever diverges.
- **Documentation:** Documentation describes the observable behavior a function promises, not how it carries it out. Flag anything that restates the implementation, and the minutia that survives only because it was easy to write down. What's left should be brief and worth a human's time to read.
- **Comments:** A comment labels, it does not argue. One-line labels naming what the code is stay; rationale, meaning why this approach, what broke last time, what not to do instead, belongs in a reference file. Rule on every comment the diff touches, including the ones it already carried. **REQUIRED:** Invoke the `comments` skill.
- **Commit size:** Reviews happen a commit at a time, so a diff carrying more than one logical change is harder to review than it needs to be. If this one can be split, say so and name the split.

## Reporting

Report findings only. Do not edit files, stage anything, or commit. Each finding is one line: file and line, what's wrong, what to do about it. Say plainly if a check found nothing.
