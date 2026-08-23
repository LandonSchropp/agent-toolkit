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

## Rationalizations

| Thought                                         | Reality                                                                   |
| ----------------------------------------------- | ------------------------------------------------------------------------- |
| "I can run the script through bash or bun"      | Skill scripts are always self-executing. Run the file directly.           |
| "I don't need to check the `--help` flag first" | The script's arguments are discoverable via `--help`; read them first.    |
| "I can wrap a script in another command"        | The script is invoked as its own executable, not through a shell wrapper. |
