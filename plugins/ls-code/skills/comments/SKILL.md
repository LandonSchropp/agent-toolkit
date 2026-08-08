---
description: Use when writing a code comment, or when reviewing the comments in a diff before presenting it. Decides which comments stay in the source and which move to documentation.
---

# Comments

A comment labels, it does not argue. It names what the code is, in one line, in the places where the code can't name itself. Everything else belongs in documentation.

## The Procedure

List every comment in the diff with its line count, including the ones the diff already carried and not only the ones you wrote. Then give each entry one of exactly three dispositions:

- `label, kept`: A one-line label naming what the code is.
- `moved to <path>`: Rationale, whose content now lives in a reference file and is gone from the source.
- `deleted`: It restated the code, so the code already says it and nothing needs to survive.

There is no fourth disposition. "Kept, because it explains something the code can't" is not one of these, and writing that sentence means the check did not run. A comment you never listed is a comment you never checked.

## What Counts As Rationale

Rationale is why this approach, what broke last time, what not to do instead. Two tests find it:

- A comment longer than the code it describes is rationale in disguise.
- A comment you can delete without leaving the reader less sure what the line does was never describing the line.

Rationale is documentation. Move it into the repository's reference documentation, and when the repository has none, create `references/<topic>.md` and start it. Having no destination yet is not an exemption, and moving is not deleting: the content survives where a reader goes looking for it.

Leave no pointer behind. A comment may only refer to what is inside its own file, because code gets copied out of its home and a path dangles the moment it moves.

## The Failure Mode

This exists to stop you answering review pushback by writing the defence into the file. Do that a few times and the file carries an essay nobody asked for, a commit at a time.

## Rationalizations

| Thought                                         | Reality                                                             |
| ----------------------------------------------- | ------------------------------------------------------------------- |
| "This documents why, not what"                  | Why is rationale. Rationale lives in a reference file.              |
| "It's load-bearing institutional knowledge"     | Knowledge worth keeping is worth keeping where it's looked for.     |
| "A future reader needs this warning right here" | They need it in the reference file, where it survives a copy-paste. |
| "That incident was expensive to learn from"     | Expense is what makes it rationale, not what exempts it.            |
| "Every sentence in it earns its place"          | Length is the test, not the defence. Past one line, it moves.       |
| "Deleting it destroys the only record"          | Moving it is not deleting it. Write the reference file, then cut.   |
| "This repository has nowhere to put it"         | Create `references/<topic>.md`. No destination is not an exemption. |
| "I'll tighten the comment instead"              | Rewriting in place leaves rationale in the source. Move it.         |
| "The diff has real bugs to fix first"           | Both get done. A bug in the diff is not an exemption from this.     |
