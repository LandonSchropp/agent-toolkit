---
name: generate
description: Use when the user wants to run one or more generators from `@landonschropp/generate` (initialize, prettier, only-allow, eslint, typescript, jest, husky).
disable-model-invocation: true
---

## Process

1. **Fetch the readme** from `https://github.com/LandonSchropp/generate` to confirm the current generator list and canonical order. Do NOT rely on memory — the list changes.

2. **Present the generators** to the user and ask which ones to run. Preserve the readme's documented order.

3. **Run `--help` on every selected generator BEFORE asking the user anything**:

   ```
   pnpx @landonschropp/generate <generator> --help
   ```

   Collect every flag across every selected generator. Identify conceptual overlaps — the same question may appear under different flag names (e.g. jest's `--react`, husky's `--react`, and eslint's `--plugins` checkbox all ask about React). Ask the user ONCE for each conceptual question.

   `--help` lists flag names and messages but not enumerated choices for list or checkbox prompts. When the allowed values for a flag are unclear, read the generator's source on GitHub (e.g. `https://raw.githubusercontent.com/LandonSchropp/generate/main/src/<generator>/index.js`) — the `choices` array lists every valid value.

4. **Ask the user for the consolidated inputs.** Do not start running generators until you have answers for every required flag across every selected generator.

5. **Invoke each selected generator in the readme's canonical order**, passing every answer as `--flag=value`. Example:

   ```
   pnpx @landonschropp/generate typescript --type=node --outDir=
   pnpx @landonschropp/generate jest --typescript=true --react=false
   ```

## Rationalizations

| Thought                                         | Reality                                                                                  |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------- |
| "Positional args are shorter"                   | Positional order is undocumented and fragile. Always use `--flag=value`.                 |
| "I'll ask as I go, one generator at a time"     | That defeats dedup. Gather flags from ALL selected generators' `--help` first, then ask. |
| "The CLI will prompt for anything I miss"       | No. Run non-interactively. If a flag is missing, ask the user first, then invoke.        |
| "I already know the generator list from memory" | Fetch the readme. Generators and their flags change — the readme is the source of truth. |
| "Running `--help` on 5 generators is wasteful"  | It takes seconds and prevents repeated questions. Always do it up front.                 |
