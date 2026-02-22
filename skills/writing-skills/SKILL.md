---
description: Use when creating, editing, evaluating, testing, or verifying ANY skill or skill-related file (SKILL.md, skill resources, skill scripts, or skill assets). If you're asked to evaluate or test a skill's effectiveness, use this skill.
---

## Understand Requirements First

When asked to create or edit a skill:

1. If helpful, **ask clarifying questions** about the skill's purpose:
   - What specific problem does this skill solve?
   - What should the output/outcome be?
   - What context or inputs will the skill work with?
   - What are the key behaviors or patterns it should enforce?

2. **Summarize your understanding** and get user confirmation:
   - "Let me confirm: this skill should [summary]. Is this correct?"
   - Wait for user approval before proceeding

**You cannot create a good skill without understanding what you're building.**

## Testing

After writing a skill, ask the user: "Would you like me to test the skill?" (Skills are often manually tested by the user, or can't be tested in an automated way, so you should ask before proceeding.)

If the user opts for the agent to test the skill:

1. **Design a scenario** that exercises the skill's core purpose. Describe it to the user and get approval before running it.
2. **Run the scenario** with a subagent. Document exactly what the agent did—what choices it made, what worked, what didn't.
3. **If the agent failed or rationalized away the skill's intent**, identify the gap, add an explicit counter to the skill, and re-test.
4. **Repeat** until the skill reliably produces the intended behavior.

## Required Reading

**STOP. Read these documents NOW. Not later. Not "as you go." Right now.**

- [Format Guide](references/format-guide.md)
- [Getting Agents to Follow Instructions](references/getting-agents-to-follow-instructions.md)
- [Script Conventions](references/scripts.md)
- [Agent Skills](https://code.claude.com/docs/en/skills.md)
- [Skill Specification](https://raw.githubusercontent.com/agentskills/agentskills/main/docs/specification.mdx)
- [Skill Authoring Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md)
- [Persuasion Principles](https://raw.githubusercontent.com/obra/superpowers/main/skills/writing-skills/persuasion-principles.md)
