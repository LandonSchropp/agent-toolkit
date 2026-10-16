# Cloud Engineering

Cloud Engineering runs in Devin. Each task gets its own session, on its own machine with its own clone of the repository.

## Sending

Start the session with the `devin_session_create` tool from the Devin MCP server, passing the repository as `owner/repo`. Send work that spans several pull requests as one session: Devin splits it into child sessions itself.

Devin clones from the remote, so it can't see anything that isn't pushed. If the task depends on local work, push it before sending, or describe it in the prompt.

## The Prompt

Devin plans, opens the pull request and archives its session on its own, so the prompt needs nothing beyond what any delegation needs. Don't include a plan of your own unless the user already approved it; a plan in the prompt skips Devin's plan review.
