# Multica

Multica runs an asynchronous queue across several agents. A delegation is one issue, assigned to the agent whose scope the task falls in; split it into one issue per agent only when it genuinely spans two.

The issue description is the prompt, and the user reads it, so it takes no preamble explaining where it came from.

## Drafting

**Draft the issue. Do not create it.** Show the user the title, description, assignee, and status, and create it only once they say to. An edit is not approval: revise the draft, show it again, and wait for a yes.

Status is `todo` unless the user says the work isn't ready to start, which is `backlog`.

## Labeling

Every issue delegated this way carries the `Delegated` label, wherever the delegation started, so the user can pick delegated work back out of the queue. `multica label list --output json` gives its id; create it with `multica label create --name Delegated --color '#3b82f6'` if it is missing.

## Handing Back

Nothing beyond the issue keeps the finished work in front of the user. Multica already reserves `done` for a human confirmation: the receiving agent delivers into `in_review` and stops there. That is a convention its own instructions carry rather than something the server refuses, so a delegation leans on the receiving agent honoring it.

## From Inside Multica

Creating and assigning issues is already part of what you do here, and work belonging to the issue you are on is a child of it. Use the mechanism your own instructions give you, and set the label through it like any other field. The CLI below is the way in from outside, not a replacement for it.

There is also no chat channel the user reads from here, so a draft awaiting their approval, or a Claude Design prompt bound for them, goes onto the current issue as a comment rather than into your reply.

## From Another Platform

`multica` is on the `PATH`, authenticates on its own, and works against the configured workspace, so no workspace flag is needed. Choose the assignee by name and description, and pass the name: `--assignee` fuzzy-matches it. Narrow the listing, which otherwise carries every agent's full instructions and skills:

```bash
multica agent list --output json | jq --raw-output '.[] | "\(.name): \(.description)"'
```

Pipe the description in rather than passing it as a flag, which decodes `\n` and the other escapes out of a prompt that contains them.

```bash
response=$(multica issue create --title "$title" --description-stdin \
  --status "$status" --assignee "$agent_name" <<< "$description") || exit 1

multica issue label add "$(jq --raw-output .id <<< "$response")" "$label_id"
```

Let a failed create stop there rather than labeling an issue that was never made. A title matching an active issue is one way it fails, under the code `active_duplicate_issue`, and the error names the issue it found. That is the delegation already being on the board, so report that issue rather than reaching for `--allow-duplicate`.
