---
name: writing-skills
description: Use when creating, editing, evaluating, testing, or verifying ANY skill or skill-related file (SKILL.md, skill resources, skill scripts, or skill assets). If you're asked to evaluate or test a skill's effectiveness, use this skill.
---

## Test-Driven Development

Follow the TDD methodology when writing skills:

- **Red:** Design a scenario you expect to fail without the skill and run it with a subagent. Document the exact behavior of the agent, including what choices it made, what failed, what triggered those failures, and what rationalizations it made for not following instructions. This is equivalent to "watch the test fail"—you must see what agents naturally do before writing the skill.
- **Green:** Write a skill that addresses the behaviors you documented. Only address what you observed. Don't add extra content for hypothetical cases.
- **Refactor:** Continue to evaluate with subagents. Every time a failure or rationalization appears, add an explicit counter. Keep re-testing until the skill is bulletproof.

**THE IRON LAW: DON'T WRITE A SKILL WITHOUT A FAILING EVALUATION FIRST.** If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing. This applies to NEW skills AND EDITS to existing skills.

- Did you write the skill before testing it? Delete it. Start over.
- Did you edit the skill without testing it? Delete it. Start over.

## Required Reading

**STOP. Read these documents NOW. Not later. Not "as you go." Right now.**

- [Format Guide](references/format-guide.md)
- [Getting Agents to Follow Instructions](references/getting-agents-to-follow-instructions.md)
- [Skill Specification](https://raw.githubusercontent.com/agentskills/agentskills/main/docs/specification.mdx)
- [Skill Authoring Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md)
- [Persuasion Principles](https://raw.githubusercontent.com/obra/superpowers/main/skills/writing-skills/persuasion-principles.md)
