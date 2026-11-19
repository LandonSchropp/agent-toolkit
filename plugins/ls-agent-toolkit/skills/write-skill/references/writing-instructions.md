# Writing Instructions

Current models follow a plainly worded instruction closely, and often too literally. Instructions that once compensated for models skipping rules now cause over-application: a cautious note makes the agent hold back routine work, and a shouted rule gets applied where it doesn't fit. Write less, and write it calmly.

## What to Leave Out

Before writing a line, ask two questions. Could the agent find this by reading the code or the files it works on? Would it actually go and look? When both answers are yes, leave the line out. Descriptions of the stack, the file layout or the tools a project uses are the usual cases. Generic virtues such as "be thorough" or "keep going until it's done" go too, because current models already do both and the reminder causes over-work.

What stays is what only the author knows: the audience, decisions made outside the repository, places where the code misleads, exact commands, and the reasons behind constraints.

A rule that has to hold every time belongs in a hook, a permission rule or a script, not in prose. Prose is context the agent weighs, and a hook is enforced.

## How to Phrase a Rule

- **State it plainly, with the reason:** For example, "Use `trash` instead of `rm`, because it's recoverable" lets the agent generalize to cases the rule didn't name. Capitals, "MUST" and "CRITICAL" make the agent over-apply the rule. Use emphasis only on one rule whose failure you've reproduced on a current model, and keep the reason beside it.
- **Say what to do:** A prohibition can anchor the agent toward the very thing it forbids. Write the behavior you want instead.
- **Write the exception into the rule:** A bare "never X" stops the agent even when X is approved. "Ask before X" or "X only when Y" keeps the rule and leaves the approved path open.
- **Number steps only where order matters:** For judgment work, state the goal and the quality bar, and let the agent plan.
- **Drop hedges from requirements:** "Try to include a summary" reads as permission to skip it. "Include a summary" doesn't.

## Match the Form to the Failure

When testing shows the agent getting something wrong, work out how it fails before writing guidance. The form that fixes one kind of failure makes another kind worse.

| Failure                                                                | Form that works                                                      | Form that backfires                          |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------- | -------------------------------------------- |
| The agent knows the rule and skips it under pressure                   | A prohibition, with its loopholes closed and a rationalization table | Soft guidance such as "prefer" or "consider" |
| The agent complies, but the output has the wrong shape                 | A recipe that states what the output is: its parts, in order         | A list of prohibitions                       |
| The agent leaves a required element out of something it already writes | A required field or slot in the template it fills in                 | A reminder in the prose near the template    |
| The right behavior depends on a condition                              | A conditional keyed to something the agent can observe               | A blanket rule with exemption clauses        |

A prohibition backfires on the shape of the output because the agent negotiates with it. When another goal pulls the other way, such as making a prompt self-contained, the agent weighs "don't X" against that goal and often decides X is justified. Prohibitions produce more of the unwanted content than recipes do, and can do worse than no guidance at all. A recipe leaves nothing to negotiate, since the output either matches the stated shape or doesn't.

Whichever form you pick:

- **Skip nuance clauses:** "Don't X unless it matters" reopens the negotiation, and even one such clause makes a recipe's results inconsistent. Write a real exception as its own conditional on something observable.
- **Restructure instead of exempting:** "This limit doesn't apply to code blocks" still shrinks the code blocks. If part of the output has to be exempt, restructure the instructions so the rule can't reach that part.

## Discipline Failures

These techniques cover the first row of the table, where testing showed the agent knowing the rule and rationalizing its way past it. Use them only for that failure, and keep the register calm. What makes them work is the reasons, not the volume.

### Close the Loophole You Saw

When the agent found a workaround, name it in the rule.

Before:

```markdown
Write code before the test? Delete it.
```

After:

```markdown
Write code before the test? Delete it and start over. Keeping it as a reference or adapting it while writing the test still means the test came second.
```

### Rationalization Table

A rationalization table pairs the thought an agent used to skip a rule with the reason the thought is wrong.

```markdown
## Rationalizations

| Thought              | Reality                                                    |
| -------------------- | ---------------------------------------------------------- |
| "Too simple to test" | Simple code breaks too, and the test takes thirty seconds. |
| "I'll test after"    | A test that passes the first time it runs proves nothing.  |
```

Add a row when an agent skips an existing instruction in testing. It may state why ("this is too simple") or skip it silently. Either way, infer the thought from the behavior and answer it with a reason. Don't add rows for a failure you haven't seen, and don't add them when the instruction itself is missing. Add the instruction first, then test whether agents talk their way around it.
