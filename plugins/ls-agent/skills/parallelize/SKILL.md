---
name: parallelize
description: Use when several tasks are going out to separate agents at once and the work needs splitting into what can run simultaneously and what has to wait, before any of it is kicked off.
---

# Parallelize

Turn a set of tasks into an ordered set of stages: what can run at the same time, and what has to wait for something else to land first. The goal is the most parallelism the dependencies allow, with no two agents doing overlapping work.

## Workflow

1. Gather the tasks. Where they are Linear issues, fetch them with the Linear MCP server so each one carries its own description rather than a title.
2. Copy `assets/parallelization.md` to `/tmp/[title].md`, slugifying the title.
3. Fill in the tasks, then sort them into stages. A task belongs in the earliest stage whose predecessors have all finished. Keep stages to three tasks, moving the ones that unblock the least to a later stage. A fourth is fine only when holding it back would delay the whole plan. Never put five in one stage.
4. Look for overlaps: two tasks that would edit the same files, or that both have to add the same thing before they can start. Split, merge, or sequence them so no two agents in the same stage collide.
5. Present the stages to the user as a table (columns: Stage, Tasks, Waiting On).
6. Invoke the `ls-interactivity:interactive-edit` skill with the file so the user can adjust it, then read their changes back. Where that skill isn't available, post the file's contents in the conversation instead, wait for the user's reply, and update the file with their changes.
7. Build the implementation map from the final file as a Claude artifact. The Artifact tool publishes a local file, so copy `assets/implementation-map.html` to a temporary file, replace the data block at the top of its script following its comments, and publish that copy. Color each task by where the work happens, with work other teams do, like questions or requests, as External. The template has four colors, so use at most four locations. Where the Artifact tool isn't available, open the copy in a browser tab with the `herdr-gpui-browser` skill instead.
8. When the user asks to refresh the statuses, fetch them again and republish to the same link.

## Rationalizations

| Thought                                      | Reality                                                                     |
| -------------------------------------------- | --------------------------------------------------------------------------- |
| "I'll start the first stage while we talk"   | This skill only plans. Executing the stages is a separate step.             |
| "Everything looks independent, one stage"    | Check what they edit. Shared files are a dependency you missed.             |
| "I'll assign branches while I'm in here"     | Not this skill's call. The agent executing a task decides where work lands. |
| "Two tasks overlap, I'll let them race"      | Two agents editing one file is a conflict you chose. Sequence them.         |
| "The table is approved, the file can differ" | The file is what gets executed. Fix it, not just the table.                 |
| "Four tasks are ready, run them together"    | Three is the target. Hold the fourth back unless that delays the plan.      |
| "The map would look better redesigned"       | The template's layout is what the user settled on. Only replace its data.   |
