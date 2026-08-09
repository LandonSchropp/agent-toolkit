# Documentation

Documentation states the behavioral contract of the module it represents. For functions and methods, that means what each parameter means where its name and type don't say it, what the return value represents (unless void), and what can go wrong. _Observable behavior only._

## Cut

- Narration of the implementation: what it calls, what it awaits, what it loops over.
- Type information the types already carry.
- Rationale, which moves rather than dies.
- Examples of the obvious call. Keep an example only where the calling shape is genuinely surprising.
- Asides: history and performance notes.
- Ceremony. "This method is responsible for" is four words before the sentence starts.

What survives should be brief and worth a human's time to read.

## Don't Inflate What You Didn't Change

A refactor that preserves behavior preserves the documentation. If the contract didn't change, the documentation doesn't change — unless what's there is inaccurate, in which case correct it.

Growing a slim, clean documentation block while restructuring the code under it is the most common way this rot gets in — the code moved, so expanding the documentation feels like diligence. It isn't. If you have expanded documentation for code whose observable behavior you left alone, revert that hunk.

## Rationalizations

| Thought                                         | Reality                                                          |
| ----------------------------------------------- | ---------------------------------------------------------------- |
| "I'll put it in the docstring instead"          | Same file, same essay. It goes to a reference file.              |
| "I restructured this, so I'll document it more" | Same behavior, same documentation. Revert the expansion.         |
| "The old docs were too sparse"                  | Sparse and correct is the target, not a defect to fix.           |
| "The types are unclear, so I'll restate them"   | Fix the types. Documentation that mirrors them drifts from them. |
