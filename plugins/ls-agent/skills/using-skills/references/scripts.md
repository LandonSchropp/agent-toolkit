# Skill Scripts

Scripts in skills are always relative to the `SKILL.md` file. For example, if a `SKILL.md` file references `scripts/<script-name>.ts` and is located at `skills/<skill-name>/SKILL.md`, then the script's path would be `skills/<skill-name>/scripts/<script-name>.ts`.

Skill scripts are _always_ self-executing. You should NEVER run a script with another command, such
as `bash` or `bun`. For example, the script mentioned above would be run with:

```bash
./skills/<skill-name>/scripts/<script-name>.ts
```

All skill scripts include a `--help` flag. Always run the script with this flag first to see the script's supported arguments.

```bash
./skills/<skill-name>/scripts/<script-name>.ts --help
```

## Rationalizations

| Thought                                         | Reality                                                                   |
| ----------------------------------------------- | ------------------------------------------------------------------------- |
| "I can run the script through bash or bun"      | Skill scripts are always self-executing. Run the file directly.           |
| "I don't need to check the `--help` flag first" | The script's arguments are discoverable via `--help`; read them first.    |
| "I can wrap a script in another command"        | The script is invoked as its own executable, not through a shell wrapper. |
