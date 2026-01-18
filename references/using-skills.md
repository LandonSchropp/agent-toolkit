## EXTREMELY IMPORTANT

If you think there is a chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

## Rationalizations

| Thought                             | Reality                                                |
| ----------------------------------- | ------------------------------------------------------ |
| "This is just a simple question"    | Questions are tasks. Check for skills.                 |
| "I need more context first"         | Skill check comes BEFORE clarifying questions.         |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first.           |
| "I can check git/files quickly"     | Files lack conversation context. Check for skills.     |
| "Let me gather information first"   | Skills tell you HOW to gather information.             |
| "This doesn't need a formal skill"  | If a skill exists, use it.                             |
| "I remember this skill"             | Skills evolve. Read current version.                   |
| "This doesn't count as a task"      | Action = task. Check for skills.                       |
| "The skill is overkill"             | Simple things become complex. Use it.                  |
| "I'll just do this one thing first" | Check BEFORE doing anything.                           |
| "This feels productive"             | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means"            | Knowing the concept ≠ using the skill. Invoke it.      |

## Skill Scripts

Scripts in skills are always relative to the `SKILL.md` file. For example, if a `SKILL.md` file references `scripts/generate-plan-template.ts` and is located at `skills/writing-skill/SKILL.md`, then the script's path would be `skills/writing-skill/scripts/generate-plan-template.ts`.

Skill scripts are _always_ self-executing. You should NEVER run a script with another command, such
as `bash` or `bun`. For example, the script mentioned above would be run with:

```bash
./skills/writing-skill/scripts/generate-plan-template.ts
```

All skill scripts include a `--help` flag. Always run the script with this flag first to see the script's supported arguments.

```bash
./skills/writing-skill/scripts/generate-plan-template.ts --help
```
