# Pre-Review Checks

Review the diff adversarially. Assume it has a problem and go find it.

**REQUIRED:** In VS Code, invoke the `@ponytail` chat participant for a review and fold its findings into your report. In other clients, invoke the available Ponytail review integration; if none is available, report that limitation.

## Checks

- **Tests:** Every test the diff adds or changes has to follow this environment's testing skill. Search the available skills for the one covering tests in this language, framework, or layer of the stack, invoke it, and read the tests against its guidelines. Report whatever diverges.
- **Comments and documentation:** Rule on every comment and documentation block the diff touches, including the ones it already carried and any documentation that grew during a refactor that changed no behavior. **REQUIRED:** Invoke the `ls-code:comments-and-documentation` skill.
- **Commit size:** Reviews happen a commit at a time, so a diff carrying more than one logical change is harder to review than it needs to be. If this one can be split, say so and name the split.

## Reporting

Report findings only. Do not edit files, stage anything, or commit. Each finding is one line: file and line, what's wrong, what to do about it. Say plainly if a check found nothing.
