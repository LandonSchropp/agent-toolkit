---
name: vibe
description: Use when working in a vibe-coded repository, where the user never reads the code and only runs the product and gives feedback, or when the user wants to start building a project that way.
---

# Vibe

The user never reads the code here. They run the product and react to it, so nobody else will catch a bug in the code, and the only thing worth reporting is what they can see.

For a new project, **REQUIRED:** use the `ls-code:project-conventions` skill to create the root files first. At the start of every session, make sure the README, `AGENTS.md` and coverage setup below are in place.

## README

`README.md` is one of the few files the user reads and approves. It describes the product's primary interface, so the user sets its direction. Every change to it goes through `ls-interactivity:interactive-review` in `staged` mode with only `README.md` staged, and is committed on its own before any other work continues. No other file ever appears in a review.

The README opens, above everything else, with this callout:

```markdown
> [!WARNING]
> **This repository is 100% vibe coded.** The author did not read any of the code. Use it at your own risk.
```

## AGENTS.md

Directly after the line requiring agents to read `README.md`, `AGENTS.md` has this instruction:

```markdown
**REQUIRED:** Invoke the `ls-agent:vibe` skill and follow its instructions. At the start of every session, ask the user to run `/ls-interactivity:disable-review`.
```

## Coverage

Set up tooling that fails below 100% test coverage, such as a coverage check, script or CI step. Checking the number by eye doesn't count, and neither do coverage exclusions or ignore comments the user hasn't approved.

## Working With the User

- **Talk about the product:** Report what changed on screen or in behavior. Never mention code, tests, refactors or review findings unless they change what the user experiences.
- **Keep the product current:** Rebuild or reinstall after every change, and end every hand-off with exactly what to try.
- **Open on the work in progress:** When the product has several screens or steps, make it open directly on the one being built, loaded with the right data, so the user never has to navigate there. Use a development-only switch that's removed once the full flow is connected. Clicking through the whole flow is only for testing how the pieces connect, at the end.
- **Record preferences immediately:** Any rule or preference the user states goes into `AGENTS.md` right away, even one about the product.
- **Surface what the user can't see:** As the one exception to talking only about the product, raise data loss risks, any write to real data, and terms-of-service or licensing problems, and let the user decide.
- **Keep momentum:** After an approval, state what's next in one line and start on it. Stop only for decisions the user has to make, and describe options by how they behave, not how they're built.

## Approval

Outside the README, this replaces the `ls-interactivity:interactive-review` steps of the commit process from `ls-agent:instructions`; the rest still applies. After `ls-code:pre-review`, hand the change off for the user to try instead of opening a review. The user approves a change by trying it and saying it looks good, or by running `/ls-interactivity:disable-review`. Either one means commit.

Never commit what the user hasn't manually tested and approved. Groundwork with nothing visible waits until the next change they test and approve, then is committed along with it, in its own commit when it's a separate logical change.

## Quality

You own the code's quality. Keep coverage at 100%, and run `ls-code:pre-review` before every hand-off, not just before commits. Report only the effects of its fixes the user would notice.

## Real Data

Read the user's real data freely to check changes, but make no destructive writes to it until the user agrees the product is otherwise done. The step that writes is built last.

## Rationalizations

| Thought                                    | Reality                                                            |
| ------------------------------------------ | ------------------------------------------------------------------ |
| "They'd like to hear about this fix"       | Only if they'd notice it in the product. Otherwise leave it out.   |
| "They can click through to the new screen" | Open the product on it, with the right data already loaded.        |
| "Excluding this file gets coverage to 100" | Exclusions need the user's approval. Write the test.               |
| "One write to real data would prove it"    | Read real data. Destructive writes wait for the final step.        |
| "I'll ask before starting the next piece"  | After an approval, say what's next and start. Ask only real calls. |
