# Cloud Engineering

Cloud Engineering runs in Devin. Each task gets its own session, on its own machine with its own clone of the repository.

## Sending

Start the session with the `devin_session_create` tool from the Devin MCP server, passing the repository as `owner/repo`. Send work that spans several pull requests as one session: Devin splits it into child sessions itself.

Devin clones from the remote, so it can't see anything that isn't pushed. If the task depends on local work, push it before sending, or describe it in the prompt.

## The Prompt

Devin builds straight from the prompt without planning first, so the prompt is the plan. Before sending, **REQUIRED:** invoke the `ls-agent:plan` skill, and send the plan the user approves as the prompt, along with the Linear issue's URL if there is one. A task that would fit in a single commit skips planning and goes as given.

Devin opens the pull requests and archives its session on its own, so leave those out.
