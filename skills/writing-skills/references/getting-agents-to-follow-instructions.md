# Getting Agents to Follow Instructions

Agents will find loopholes and rationalize ignoring instructions. This document contains techniques to close those escape routes.

## Close Every Loophole Explicitly

Agents will find loopholes. When they do, explicitly counter them by forbidding the workarounds.

Before:

```markdown
Write code before test? Delete it.
```

After (explicit loopholes):

```markdown
Write code before test? Delete it. Start over. Don't keep it as a "reference". Don't "adapt" it while writing tests.
```

## Rationalization Table

When testing with subagents, document every excuse agents make for violating the rule and add them
to a Rationalizations table in your skill.

```markdown
## Rationalizations

| Thought/Excuse                   | Reality                                                                 |
| -------------------------------- | ----------------------------------------------------------------------- |
| "Too simple to test"             | Simple code breaks. Tests take 30 seconds to run.                       |
| "I'll test after"                | Tests passing immediately prove nothing.                                |
| "Tests after achieve same goals" | Tests-after = "what does this do?" Tests-first = "what should this do?" |
```

The table directly counters each rationalization, and the closing directive makes the consequence clear.

## Write Preventive Descriptions

The skill's description field should prevent agents from making mistakes. Write triggers that help agents trigger skills at the right time.

Good (preventive):

```yaml
description: Use when implementing any feature or bug fix. Call before writing implementation code.
```

Bad (reactive):

```yaml
description: Use when you need to fix bugs in your code.
```

The first catches agents at the decision point. The second only helps after they've already violated TDD.
