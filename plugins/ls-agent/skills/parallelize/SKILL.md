---
description: Use when several tasks are going out to separate agents at once and the work needs splitting into what can run simultaneously and what has to wait, before any of it is kicked off.
---

# Parallelize

Turn a set of tasks into an ordered set of stages: what can run at the same time, and what has to wait for something else to land first. The goal is the most parallelism the dependencies allow, with no two agents doing overlapping work.

## Workflow

1. Gather the tasks. Where they are Linear issues, fetch them with the Linear MCP server so each one carries its own description rather than a title.
2. Copy `assets/parallelization.md` to `/tmp/[title].md`, slugifying the title.
3. Fill in the tasks, then sort them into stages. A task belongs in the earliest stage whose predecessors have all finished.
4. Look for overlaps: two tasks that would edit the same files, or that both have to add the same thing before they can start. Split, merge, or sequence them so no two agents in the same stage collide.
5. Present the stages to the user as a table (columns: Stage, Tasks, Waiting On).
6. Invoke the `ls-interactivity:interactive-edit` skill with the file so the user can adjust it, then read their changes back.

## Rationalizations

| Thought                                      | Reality                                                                     |
| -------------------------------------------- | --------------------------------------------------------------------------- |
| "I'll start the first stage while we talk"   | This skill only plans. Executing the stages is a separate step.             |
| "Everything looks independent, one stage"    | Check what they edit. Shared files are a dependency you missed.             |
| "I'll assign branches while I'm in here"     | Not this skill's call. The agent executing a task decides where work lands. |
| "Two tasks overlap, I'll let them race"      | Two agents editing one file is a conflict you chose. Sequence them.         |
| "The table is approved, the file can differ" | The file is what gets executed. Fix it, not just the table.                 |
