---
name: summarize-book
description: Use when the user wants a book summarized, condensed into cliff notes, or turned into a reference an agent can read in place of the full book.
---

# Summarize Book

A summary is a much smaller version of a book that captures its core ideas and is written for an agent to read, not a person.

## Locations

Summaries live in `~/Library/Mobile Documents/com~apple~CloudDocs/Documents/Books/`:

- **Book:** `<Author> - <Title>.<extension>`.
- **Summary:** `<Author> - <Title> (Summary).md`

If the original book file isn't already in the folder, copy it there under this name.

Take the author and title from the book's metadata, dropping any subtitle from the filenames.

## Process

1. Convert the book to plain text in the scratchpad directory, for example with Calibre's `ebook-convert` (`brew install --cask calibre` if it's missing). Delete the text file once the summary is written.
2. **REQUIRED:** Read the whole book before writing. Chapter summaries and the introduction are not the book; the frameworks, numbers and caveats live in the body chapters.
3. Read the existing `(Summary).md` files in the folder. They are approved summaries of other books; match their shape, depth and tone.
4. Write the summary.

## Shape

- **Opening paragraph:** No heading. What the book is, who wrote it, and its through-line.
- **Core Principles:** A short numbered list.
- **One section per major topic:** Bullets with bolded labels, covering the key frameworks and any concrete numbers or findings.
- **How to Apply This When Advising Someone:** How an agent should use the ideas when advising a specific person.
- **Misconceptions to Correct:** A list of common beliefs the book refutes.

Aim for a few thousand words.

## Writing Rules

- Paraphrase in your own words. No long quotes or reproduced passages.
- Leave out anecdotes unless one is needed to make a point clear.
- No H1 heading. Use title case for every heading.
- No em dashes anywhere. In bullet lists, separate a label from its description with a colon.
- Spell out an acronym on first use, with the acronym in parentheses.

## Rationalizations

| Thought                                      | Reality                                                             |
| -------------------------------------------- | ------------------------------------------------------------------- |
| "The chapter summaries cover the main ideas" | The numbers and caveats that make a summary useful are in the body. |
| "I know this book already"                   | Memory blurs books together. Summarize the text in front of you.    |
| "An em dash reads better here"               | None anywhere. Use a colon, a comma or a new sentence.              |
| "This quote says it best"                    | Paraphrase it. A summary that reproduces the book isn't a summary.  |
