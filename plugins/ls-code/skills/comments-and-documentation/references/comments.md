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

| Thought                                         | Reality                                                             |
| ----------------------------------------------- | ------------------------------------------------------------------- |
| "This documents why, not what"                  | Why is rationale. Rationale lives in a reference file.              |
| "It's load-bearing institutional knowledge"     | Knowledge worth keeping is worth keeping where it's looked for.     |
| "A future reader needs this warning right here" | They need it in the reference file, where it survives a copy-paste. |
| "That incident was expensive to learn from"     | Expense is what makes it rationale, not what exempts it.            |
| "Every sentence in it earns its place"          | Length is the test, not the defense. Past one line, it moves.       |
| "Deleting it destroys the only record"          | Moving it is not deleting it. Write the reference file, then cut.   |
| "This repository has nowhere to put it"         | Create `references/<topic>.md`. No destination is not an exemption. |
| "I'll tighten the comment instead"              | Rewriting in place leaves rationale in the source. Move it.         |
