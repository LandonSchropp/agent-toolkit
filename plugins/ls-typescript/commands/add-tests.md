---
description: Add tests using a structured testing approach
---

Ask the user: "What would you like to add tests for?"

After receiving their response, add tests for the user's target using the following process:

1. Invoke the `testing-typescript` skill.
2. **Analyze current state:** Determine the appropriate test file location. If there's an existing test file, read it to understand the current structure.
3. **Plan test structure:** List describe and context blocks without wrapping in commands:

   ```
   functionName
     when condition A
     when condition B
     when edge case C
   ```

4. **Review and approval:** Wait for feedback on proposed structure before implementation.
5. **Implement Incrementally:** Implement one context block at a time. Wait for approval after each context implementation. Run tests after each context addition. Fix failures before proceeding.
