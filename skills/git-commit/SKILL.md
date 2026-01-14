---
name: git-commit
description: Use when creating Git commit messages.
---

# Git Commit Messages

## Critical Rule

**YOUR FIRST WORD MUST BE THE COMMIT TITLE.** No preamble. No introduction. No explanation.

If your response doesn't start with the actual commit title, you've violated this rule. Delete everything and start over with the title.

## Output Format

Do not write:

- "Here's the commit message"
- "Based on the guidelines..."
- "The commit message is..."
- Explanations of your choices
- Multiple versions

Just output the commit message, nothing else.

## Title

Create a clear, succinct title that explains what the commit accomplishes. Brief - only the essentials.

**Use imperative mood:** "Add feature" not "Added feature" or "Adds feature"

Good examples:

- Add user authentication
- Fix memory leak in parser
- Update dependencies
- Remove deprecated API endpoints

Avoid overly detailed titles and phrases like "This commit..." or "Changes to..."

## Body

**DO NOT ADD A BODY UNLESS ABSOLUTELY NECESSARY.** Most commits need only a title.

Only add a body when the title can't capture important context. The body should contain non-redundant detail that adds value.

**Write bodies in markdown.** Use markdown formatting for lists, emphasis, code, etc.

Common patterns:

- **Simple context (1-2 sentences):** Explain the "why" or rationale when it's not obvious
- **Bullet list:** List specific changes when there are multiple distinct items
- **Paragraph + bullet list:** Provide context, then list specific changes under a "Changes:" header
- **Multiple sections:** Use headers to organize complex changes (e.g., "Changes:" and "Template-specific changes:")

The title says "what" - the body explains "why" or provides specific details

## Rationalizations

| Thought                            | Reality                           |
| ---------------------------------- | --------------------------------- |
| "I'll provide multiple versions"   | Output ONE commit message only    |
| "I should explain the format"      | Start with the title directly     |
| "I'll introduce the message"       | NO introductory text whatsoever   |
| "This simple change needs context" | Simple changes rarely need bodies |

**REQUIRED:** See [references/examples.md](references/examples.md) for correct formatting.
