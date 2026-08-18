# Mochi Format

A `.mochi` file is a zip archive containing a single `data.edn`. Build it in the scratchpad and write the archive next to the source note.

See [Mochi's format reference](https://mochi.cards/docs/import-and-export/mochi-format-reference/) for the full schema. What follows is the part the docs leave out.

## data.edn

```clojure
{:version 2
 :decks
 [{:id :sysdesign-fundamentals
   :name "System Design Fundamentals"
   :cards
   [{:content "What is **availability**?\n---\nThe percentage of time a service is operating, usually measured in nines."}
    {:content "How do you calculate **availability**?\n---\n(Total Time − Downtime) / Total Time"}]}]}
```

`:content` is one markdown string, and a line of exactly `---` separates the front from the back. Cards nested under a deck need no `:deck-id`. Markdown formatting works inside `:content`, and `{{double braces}}` make a cloze deletion.

EDN strings need `\"` and `\\` escaped, and newlines written as `\n`. Prefer wording that avoids double quotes entirely.

## Building

```bash
zip -q "<note directory>/<Note Name> Flash Cards.mochi" data.edn
```

Run it from the directory holding `data.edn`, so the archive contains the file at its root rather than under a path.

## Why not markdown

Mochi also imports a markdown file split on a delimiter chosen at import time. Avoid it. The deck name is lost, any preamble becomes a card, and the delimiter has to be picked by hand every time.
