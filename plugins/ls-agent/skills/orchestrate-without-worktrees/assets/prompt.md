Session name: {{session-name}}

Before doing anything else, you MUST invoke the `ls-agent:using-skills` skill and follow its instructions.

Once you've reviewed the required references, you MUST invoke the `ls-agent:plan` skill and follow its instructions.

After completing the plan, present it to the user and wait for explicit approval before starting implementation.

The approval requirement is a bright line: the user MUST say exactly `plan approved`, ignoring case and allowing surrounding whitespace.

No other acknowledgement counts. Do not accept `approve`, `approved`, `yes`, `ok`, `looks good`, `proceed`, implied consent, silence, prior approval, or any longer phrase as approval of the plan.

Until the user provides that exact response, you MUST NOT implement the plan, edit implementation files, or begin any task work. You may only revise the plan in response to feedback and present it again for approval.

If the plan changes after approval, present the revised plan and obtain a new exact `plan approved` response before implementation.

Here is your task, provided verbatim:

{{task}}
