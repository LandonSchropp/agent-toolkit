# Card Design

## One card per named concept

The back carries the concept's definition **and whatever the source attaches to it**: its limits, its costs, when it fails, what it requires. Those belong to the concept rather than standing alone, and splitting them off means recalling the definition without the half that matters.

```markdown
What is **vertical scaling?**

---

Upgrading the hardware of a single machine. Simple to implement, but limited by that machine's maximum capacity, and upgrades may require downtime.
```

The definition is one sentence and the rest is what the source says about it. Never card the definition and drop the sentences around it.

## Ask exactly one thing, and permit exactly one answer

It must be obvious both what is being asked and what single response counts as correct.

- **No enumerations.** A card whose answer is a list can't be graded and trains order rather than meaning. Cover the list by inverting it: one card per item, asking from the description back to the name. "Which NoSQL type stores nodes and edges?" rather than "name the four NoSQL types."
- **No bare yes/no questions.** "Is sharding usually necessary?" is a coin flip. Either reframe as "why" or "when," or append the why to the question so the answer has to carry the reasoning.
- **No "give an example."** Several answers are right and the reviewer argues with themselves.

## Put the term inside the question, in bold

> **GOOD:** What does **availability** measure?
> **BAD:** Availability: what does it measure?

A topic prefix is only for cards where the question alone wouldn't say which domain it belongs to. When the term is the subject, prefixing repeats it and forces the question to refer back to it as "it."

## Card types worth building

- **Definition.** What is X. Cheap, and the ones already known space out fast.
- **Discrimination.** How does X differ from Y. The highest value type, because it targets confusions that actually bite: ACID versus CAP consistency, availability versus reliability, an HMAC versus a signature.
- **Formula.** How do you calculate X. Its own card, always.
- **Lever.** How does X improve Y. One card per lever, never one card listing them.
- **Acronym.** What does X stand for. Worth having despite the enumeration rule, because an acronym is exactly what gets said out loud.
- **Applied.** A concrete scenario with one defensible answer. "Synchronous or asynchronous replication for a likes counter?"

## Keep backs short

One idea, one or two sentences. A back long enough to skim is a back that never gets recalled.
