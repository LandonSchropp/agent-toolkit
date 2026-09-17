---
name: comments-and-documentation
description: Use when writing or editing a code comment or a documentation block, and when reviewing the comments and documentation in a diff before presenting it. Decides what stays in the source, what moves to the commit message or reference documentation, and what gets deleted.
---

# Comments And Documentation

Source carries the minimum that conveys the contract. Past that, every line is a liability: it goes stale, and once a reader catches one line lying they stop trusting the rest.

Two forms, two jobs:

- [Comments](references/comments.md) label. A comment names what the code is, in one line, where the code can't name itself.
- [Documentation](references/documentation.md) states the contract. What a caller passes, what comes back, what can go wrong.

Read the reference for whichever form the diff touches. Read both when it touches both.

## The Procedure

List every comment and every documentation block the diff touches, with its line count, including the ones the diff already carried and not only the ones you wrote. Toolchain directives are the one exemption, and `references/comments.md` says which. Give each remaining entry exactly one disposition:

- `label, kept`: A one-line comment naming what the code is.
- `contract, kept`: Documentation already at the contract and no larger.
- `trimmed`: Documentation cut down to the contract.
- `noted in commit message`: Rationale folded into the introducing commit, gone from the source.
- `moved to <path>`: Durable rationale, now in a reference file and gone from the source.
- `deleted`: It restated the code, or wasn't worth keeping anywhere.

There is no seventh disposition. "Kept, because it explains something the code can't" is not one of these, and writing that sentence means the check did not run. An entry you never listed is an entry you never checked.

## Rationale Has Three Homes

Neither form argues. Rationale is why this approach, what broke last time, what not to do instead.

Default to the commit message: it already answers "why", and most rationale is one-off, belonging to the change that prompted it. Fold it in, delete the comment.

Reach for `references/<topic>.md` only when the repository already treats reference files as durable knowledge's home. Starting that convention is a deliberate call about the repo, not something one long comment should trigger on its own — so even genuinely durable rationale defaults to the commit message until the repo earns a reference file the normal way. Moving is not deleting: the content survives where a reader looks for it.

Rationale that's neither durable nor worth a commit-message note gets deleted outright.

The documentation block above the code is not a destination for any of this — the same essay six lines higher, now dressed as a contract.

Leave no pointer behind: neither form may refer to anything outside its own file, since code gets copied out of its home and a path dangles the moment it moves.

## Rationalizations

| Thought                                           | Reality                                                         |
| ------------------------------------------------- | --------------------------------------------------------------- |
| "This one is a comment, not documentation"        | Both get ruled on, by the rules of whichever form each is.      |
| "I only wrote one of these, so I'll rule on that" | Every entry the diff touches, including the ones it carried.    |
| "The diff has real bugs to fix first"             | Both get done. A bug in the diff is not an exemption from this. |
