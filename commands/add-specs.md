---
description: Add specs using a structured testing approach
---

Ask the user: "What would you like to add specs for?"

After receiving their response, add specs for the user's target using the following process:

1. Invoke the `testing-ruby` skill.
2. **Analyze current state:** Determine the appropriate spec file location. If there's an existing spec file, read it to understand the current structure.
3. **Plan test structure:** List describe and context blocks without wrapping in commands:

   ```
   #method_name
     when condition A
     when condition B
     when edge case C
   ```

4. **Review and approval:** Wait for feedback on proposed structure before implementation.
5. **Implement Incrementally:** Implement one context block at a time. Wait for approval after each context implementation. Run specs after each context addition. Fix failures before proceeding.
