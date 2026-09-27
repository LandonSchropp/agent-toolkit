# Skill Format Guide

## Directories

Use subdirectories like `references`, `scripts`, and `assets` if you have the corresponding file types. Supporting markdown documentation MUST go in `references/`. Executable scripts MUST go in `scripts/`. Static resources MUST go in `assets/`.

## File References

All file paths MUST be relative to the `SKILL.md` file, not absolute paths from the project root.

```markdown
<!-- GOOD: Relative to SKILL.md -->

See [Format Guide](references/format-guide.md)

Run the `scripts/example.ts` script.

<!-- BAD: Absolute from project root -->

See [Format Guide](skills/writing-skills/references/format-guide.md)

<!-- BAD: Missing subdirectory -->

Run the `example.ts` script.
```

## Name

Every skill sets a `name` property matching its directory name. In a plugin skill, `name` supplies the last segment of the command, so declaring it states what the skill answers to in the file itself rather than leaving it implied by the path. Rename the directory and the property together; a `name` left behind keeps the old command alive.

## Description

Describe ONLY _when_ to use the skill, NOT what it does.

**Guidelines:**

- Start the description with "Use when" and include specific symptoms, situations, and contexts.
- Use concrete triggers and symptoms that signal when the skill applies.
- Describe the problem (e.g. race conditions), not language-specific symptoms (e.g. `setTimeout`).
- Keep it technology-agnostic unless the skill is technology-specific.
- Use a third-person perspective.
- Keep it under 500 characters.

```yaml
# BAD: Too much process detail
description: Use for TDD—write test first, watch it fail, write minimal code, refactor

# BAD: Too abstract, vague
description: For async testing

# BAD: First person
description: I can help you with async tests when they're flaky

# BAD: Mentions technology but skill isn't specific to it
description: Use when tests use setTimeout/sleep and are flaky

# GOOD: Triggering conditions only
description: Use when implementing any feature or bugfix, before writing implementation code

# GOOD: Problem-focused description
description: Use when tests have race conditions, timing dependencies, or pass/fail inconsistently

# GOOD: Technology-specific (when skill IS tech-specific)
description: Use when using React Router and handling authentication redirects
```

## Invocation Control

By default, both the user and the model can invoke a skill. Two Claude Code frontmatter fields (an extension to the Agent Skills standard) restrict this:

- `disable-model-invocation: true`: Only the user can invoke it, via `/skill-name`. The model never triggers it automatically, and its description is kept out of context. Use for skills with side effects or where the user controls timing — deploying, committing, syncing, sending messages.
- `user-invocable: false`: Only the model can invoke it, when another skill or the conversation calls for it. There is no `/skill-name` command. Use for background knowledge or skills that exist only to be invoked by other skills.

Set both to restrict a skill to neither invoker. Omit both (the default) when either should be able to invoke it.

## Referring To The User

Write "the user", never a personal name. A skill that names someone reads as being about that person rather than about whoever is running it, and it goes wrong the moment the skill is shared or the person changes. Package names, bundle identifiers, and marketplace handles are not references to a person and are fine as they are.

## Code Examples

**One excellent example beats many mediocre ones.** One great example is enough. Choose the most relevant language for the example—TypeScript/JavaScript are a good fallback if the language is not obvious.

Good examples are:

- Complete and runnable
- Commented only where the pattern isn't evident from the code. **REQUIRED:** Use the `ls-code:comments-and-documentation` skill
- From a real scenario
- Shows the pattern clearly
- Ready to adapt (not generic)

Avoid:

- Implementing in multiple languages
- Creating fill-in-the-blank templates
- Writing contrived examples

## Token Efficiency

Frequently-loaded skills appear in EVERY conversation. Every token counts, so keep them concise.

| Skill Type        | Target Word Count |
| ----------------- | ----------------- |
| Always loaded     | < 150             |
| Frequently loaded | < 200             |
| Circumstantial    | < 500             |

You can check the word count with this command:

```bash
wc -w skills/<skill-name>/SKILL.md
```

**Techniques to stay concise:**

- Move details to tool `--help` instead of documenting in skill
- Reference other skills instead of repeating instructions
- Compress examples to essentials
- Don't repeat what's in cross-referenced skills (see [One Canonical Home](#one-canonical-home))
- Don't explain what's obvious from the command

```markdown
<!-- BAD: Document all flags -->

`search-conversations` supports `--text`, `--both`, `--after <date>`, `--before <date`, `--limit <count>`

<!-- GOOD: Reference help -->

`search-conversations` supports multiple modes and filters. Run `--help` for details.
```

## One Canonical Home

Every rule, definition, and workflow has exactly one canonical home: the skill or reference file that owns it. Before writing anything into a skill, or editing one, find out whether it already lives somewhere else. Search the other skills and their references, and check the skills this one already requires.

If it does, point to it with a requirement marker (see [Referencing Other Skills](#referencing-other-skills)) and write nothing more about it. A copy drifts: when the canonical home changes, the copy keeps teaching the old rule, and the agent can't tell which one is right. This includes partial copies, like a summary of what the other file covers or a restated list of allowed values.

Point to another skill by requiring the skill itself, never one of its reference files. A skill only links to references in its own directory. The other skill decides which of its references to load, so it can reorganize them later without breaking anything that points to it.

If it doesn't live anywhere yet, decide where it belongs before writing it. A rule that applies beyond this one skill belongs in the skill or reference that owns that broader subject, and this skill points to it.

```markdown
<!-- BAD: Restates the workflow another skill owns -->

Before testing, commit your changes:

1. Run `git status` to check working directory
2. Run `git diff` to see what changed
3. Stage files with `git add`
4. Create commit with descriptive message
   [15 more lines of git workflow details that are repeated elsewhere]

<!-- BAD: Summarizes what the referenced file covers -->

**REQUIRED:** Read [<Reference Name>](references/<reference>.md) for <topic A>, <topic B>, and <topic C>.

<!-- GOOD: Points to the canonical home -->

Before testing, commit your changes. **REQUIRED:** Use the `ls-git:git-commit` skill.

**REQUIRED:** Read [<Reference Name>](references/<reference>.md).
```

### Rationalizations

| Thought                                          | Reality                                                              |
| ------------------------------------------------ | -------------------------------------------------------------------- |
| "A quick summary helps the agent"                | The summary goes stale when the source changes. Point to it instead. |
| "Restating the values makes this skill complete" | The skill is complete once it points to where the values live.       |
| "It's only one line"                             | One stale line is enough to contradict the source. Point to it.      |

## Referencing Other Skills

When referencing other skills, wrap the skill name in backticks and use explicit requirement markers.

Name a skill exactly as the skills listing shows it, which for a skill in a plugin is `plugin:skill`. A bare name the Skill tool can't resolve reads to the agent as a skill that doesn't exist, and it moves on without the guidance.

```markdown
<!-- GOOD: Qualified name, explicit requirement marker -->

**REQUIRED:** Use the `ls-typescript:testing-bun` skill

<!-- GOOD: Clear requirement language -->

**REQUIRED:** You MUST use the `ls-git:git-commit` skill

<!-- BAD: Bare name the Skill tool can't resolve -->

**REQUIRED:** Use the `testing-bun` skill

<!-- BAD: Unclear if required -->

See skills/testing/test-driven-development
```
