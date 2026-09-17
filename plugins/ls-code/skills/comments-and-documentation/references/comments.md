# Comments

A comment labels. It names what the code is, in one line, where the code can't name itself.

A directive the toolchain reads is not a comment. It only looks like one because the language had nowhere else to put it. Interpreter lines, pragmas, linter and type-checker suppressions, and code-generation markers are instructions to a machine, so they carry no disposition and belong in no inventory.

## What Counts As Rationale

Two tests find it:

- A comment longer than the code it describes is rationale in disguise.
- A comment you can delete without leaving the reader less sure what the line does was never describing the line.

Rationale is not a comment that needs rewriting. It is content in the wrong file.

## The Failure Mode

This exists to stop you answering review pushback by writing the defense into the file. Do that a few times and the file carries an essay nobody asked for, a commit at a time.

## Rationalizations

| Thought                                          | Reality                                                                                                                    |
| ------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| "This documents why, not what"                   | Why is rationale, and it leaves the source. Default to the commit message; a reference file only if durable and conventional. |
| "It's load-bearing institutional knowledge"      | Institutional weight doesn't justify a new `references/` directory by itself. Even durable knowledge defaults to the commit message until the repo already keeps this kind of thing in `references/`. |
| "A future reader needs this warning right here"  | They need it out of the source. The commit message is the default even for a durable warning, until the repo already has a reference-file convention. |
| "That incident was expensive to learn from"      | Expense is what makes it rationale, not what decides where it goes.                                                       |
| "Every sentence in it earns its place"           | Length is the test, not the defense. Past one line, it leaves.                                                            |
| "Deleting it destroys the only record"           | The commit message or a reference file keeps the record. Only delete outright when nothing needs to survive.             |
| "This repository has nowhere to put it"          | No destination is the common case, not a gap to fill. The commit message is always available.                            |
| "I'll fold it into the commit message"           | Fine for a one-off. Not fine when the repo already keeps this kind of knowledge in `references/` — durable content still goes where readers look for it. |
| "I'll tighten the comment instead"                | Rewriting in place leaves rationale in the source. It has to leave.                                                       |
