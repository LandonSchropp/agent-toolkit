## Overview

Follow the TDD methodology when writing code.

## Red-Green-Refactor

- **Red:** Write a test showing what should happen. Then run it and verify that it fails. This is MANDATORY—never skip this step. Confirm that the test fails (not errors), the failure message is expected and it fails because the feature is missing.

  If the test passes, then you're testing existing behavior—fix the test. If the test fails with an unexpected error, then fix the error and re-run until it fails correctly.

- **Green:** Write the simplest code you can to make the test pass. Don't add features, refactor other code, or "improve" beyond the test. Then re-run the tests (MANDATORY) to verify they pass, other tests still pass, and the output does not contain errors or warnings.

  If the test fails, fix the code, not the test. If other tests fail, fix the code until they pass.

- **Refactor:** Only after the tests are green, you may clean up the code, doing things like de-duplicating or extracting. Don't add any new behavior. Make sure you keep the tests green.

Repeat this process each time you add a new feature or behavior.

## The Iron Law

**THE IRON LAW: DON'T WRITE CODE WITHOUT A FAILING TEST FIRST.** If you didn't watch a test fail, you don't know if it tests the right thing. This applies to new code and edits to existing code.

This applies to new features, bug fixes, refactors and behavior changes. The only exceptions are throwaway prototypes, generated code or configuration files.

Did you write the code before the test? Delete it. Start over.

## Rationalizations

| Excuse                                 | Reality                                                                 |
| -------------------------------------- | ----------------------------------------------------------------------- |
| "Too simple to test"                   | Simple code breaks. Test takes 30 seconds.                              |
| "I'll test after"                      | Tests passing immediately prove nothing.                                |
| "Tests after achieve same goals"       | Tests-after = "what does this do?" Tests-first = "what should this do?" |
| "Already manually tested"              | Ad-hoc ≠ systematic. No record, can't re-run.                           |
| "Deleting X hours is wasteful"         | Sunk cost fallacy. Keeping unverified code is technical debt.           |
| "Keep as reference, write tests first" | You'll adapt it. That's testing after. Delete means delete.             |
| "Need to explore first"                | Fine. Throw away exploration, start with TDD.                           |
| "Test hard = design unclear"           | Listen to test. Hard to test = hard to use.                             |
| "TDD will slow me down"                | TDD faster than debugging. Pragmatic = test-first.                      |
| "Manual test faster"                   | Manual doesn't prove edge cases. You'll re-test every change.           |
| "Existing code has no tests"           | You're improving it. Add tests for existing code.                       |
