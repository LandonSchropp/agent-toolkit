# Claude Duet

Formats Claude can use when a skill runs in Claude Duet. They exist only there. Elsewhere, fall back to the equivalent Markdown for display blocks and to plain text questions and replies for interactive ones.

Add a format only where a step's output or question already has that shape. A skill with nothing that fits stays plain text. Name the blocks when the look matters; otherwise leave the layout to Claude. Left to itself, Claude keeps cards simple.

## Formats

- **Card:** Native blocks for structured results, short lists to pick from, statuses and decisions.
- **Chips:** 1 to 3 one-tap replies, up to 24 characters each.
- **Draft card:** An editable email, text or Slack message with a Send button.
- **Visual widget:** SVG or HTML with working scripts, for charts, diagrams and small interactive tools.
- **Published page:** A full HTML page shared as a link.
- **Map:** Pins for places or a day-by-day itinerary.

## Card Blocks

- **Header:** Title, with an optional badge or button.
- **Section:** Paragraph, with an optional button. A labeled section draws as an inset panel that stands out from the rest of the card, for a key point, a proposed action or a draft.
- **Fields:** Two-column label and value grid.
- **Columns:** Two or three big numbers.
- **Table:** Up to 10 rows by 5 columns.
- **Progress:** Bar with value, max and label.
- **Route:** One trip with legs, times, stops and price.
- **Context:** Small print, usually a timestamp.
- **Divider:** A horizontal rule.
- **Actions:** A row of buttons.

Buttons send Claude a message, so a card can offer choices or confirm an action.

## Widget Notes

Widgets can load common JavaScript libraries and send Claude a message from a button.

## Examples

Each format instruction in a skill names the format, what goes in it, and the fallback:

> In Claude Duet, show the log as a card table, newest first. Elsewhere, use a Markdown table.

> In Claude Duet, open the weekly review with a card: columns for average sleep efficiency, time asleep and nights logged, then a table of the week, newest first. Elsewhere, use a short summary line and a Markdown table.
