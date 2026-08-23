Session name: {{session-name}}

Before doing any work, create a new Git worktree using the branch `{{session-name}}` and switch into it. The branch name must exactly match the session name above. All work must happen inside that worktree. Do not modify files in the main working directory.

Prepare the worktree before planning or implementation:

1. Copy applicable local configuration files from the main working directory into the worktree, including uncommitted or Git-ignored dotfiles such as `.env`, `.env.local`, and similar repository-specific files. Do not copy files already tracked by Git, and never copy `.git`. Do not read, display, parse, log, or expose the contents of copied configuration files. Only identify their paths and copy them while preserving permissions.
2. Copy applicable repository-local dependency caches or installations, such as `node_modules`, `vendor/bundle`, or equivalent directories, when doing so can accelerate setup. Copy only files stored inside the repository. Do not copy globally installed packages or tools. Treat copied dependencies as a cache, not as a substitute for installation.
3. Determine the repository's package managers and setup commands from its committed manifests, lockfiles, documentation, and existing scripts. Run the appropriate package, bundle, or dependency installers inside the worktree so its local dependencies are complete and consistent with the lockfiles. Do not install or update unrelated dependencies.

Once the worktree is prepared, you MUST invoke the `plan` skill and follow its instructions.

After completing the plan, present it to the user and wait for explicit approval before starting implementation.

The approval requirement is a bright line: the user MUST say exactly `plan approved`, ignoring case and allowing surrounding whitespace.

No other acknowledgement counts. Do not accept `approve`, `approved`, `yes`, `ok`, `looks good`, `proceed`, implied consent, silence, prior approval, or any longer phrase as approval of the plan.

Until the user provides that exact response, you MUST NOT implement the plan, edit implementation files, or begin any task work. You may only revise the plan in response to feedback and present it again for approval.

If the plan changes after approval, present the revised plan and obtain a new exact `plan approved` response before implementation.

Here is your task, provided verbatim:

{{task}}
