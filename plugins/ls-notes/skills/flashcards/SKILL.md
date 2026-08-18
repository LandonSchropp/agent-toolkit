---
description: Use when the user wants flash cards, a spaced-repetition deck, or a Mochi deck built from a note, a course, a book or any other source material.
---

# Flashcards

Cards are only worth reviewing if they cover the source completely and ask one thing at a time. So: audit, build, prune, package.

**REQUIRED:** Invoke the `ls-notes:note` skill first.

## 1. Audit

**REQUIRED:** Before writing a single card, enumerate every claim in the source in a scratch file, mapping each to the card that will cover it.

| Claim in the note                                                      | Card                          |
| ---------------------------------------------------------------------- | ----------------------------- |
| Vertical upgrades the hardware and is simple to implement              | What is **vertical scaling**? |
| Vertical is limited by one machine's capacity and may require downtime | What is **vertical scaling**? |

Many claims mapping to one card is expected. A claim with no card is a gap, and finding gaps is why this step exists. Work section by section, and never stop at a paragraph's headline claim; the sentence after it is usually where the content is.

Keep the file in the scratchpad directory and delete it once the deck is built.

## 2. Write the cards

Read [Card Design](references/card-design.md) and follow it exactly.

## 3. Prune

Present every trivial card to the user and let the user choose what to keep. **REQUIRED:** Invoke the `ls-interactivity:interactive-edit` skill with the candidates as a bulleted list. **The lines the user deletes are the cards to remove from the deck**, and anything left behind stays. Say so in the file itself.

## 4. Package

Read [Mochi Format](references/mochi-format.md) and build the archive next to the source note.

## Rationalizations

| Thought                                    | Reality                                                             |
| ------------------------------------------ | ------------------------------------------------------------------- |
| "The source is short, I'll skip the audit" | The audit catches the qualifying clauses. Do it every time.         |
| "I'll audit as I write the cards"          | Then the cards define coverage instead of the source. Audit first.  |
| "This claim is a detail, not worth a row"  | Details are what the user gets asked about. Every claim gets a row. |
| "I'll decide which cards are thin myself"  | The user knows what they already know. Present the candidates.      |
