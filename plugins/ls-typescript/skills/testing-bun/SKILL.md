---
description: Use when writing or modifying tests in a Bun project
---

# Testing with Bun

REQUIRED: fetch the [Bun mocks documentation](https://bun.com/docs/test/mocks.md) before writing or modifying tests.

## Running the suite

Run the full suite via `bun run test`, never `bun test` directly. The script passes `--isolate`, which runs each test file in its own worker. Without it, `mock.module()` calls leak across files and tests fail in confusing, order-dependent ways.

For ad-hoc single-file runs, use `bun test --isolate <file>`.

## Mock helpers

Prefer the specific mock helpers over `mockImplementation`:

- `mockResolvedValue(value)` / `mockResolvedValueOnce(value)` — async functions returning a value.
- `mockRejectedValue(error)` / `mockRejectedValueOnce(error)` — async functions that throw.
- `mockReturnValue(value)` / `mockReturnValueOnce(value)` — sync functions.

Only reach for `mockImplementation` when behavior depends on arguments or call count.

Set mock return values close to the test that asserts on them, with the concrete value the test needs. Indirection through shared variables or transformations makes tests harder to read.

## Spying on object methods

Never reassign properties on global or imported objects to stub them — use `spyOn`. Re-spy in `beforeEach` so each test starts from a known state.

```ts
// Good — spy, scoped to the test that needs it
import { spyOn } from "bun:test";

// Bad — reassigns the property
const original = Bun.stdin;
beforeEach(() => {
  // @ts-expect-error
  Bun.stdin = { json: () => Promise.resolve(payload) };
});
afterEach(() => {
  // @ts-expect-error
  Bun.stdin = original;
});

it("processes the payload", async () => {
  spyOn(Bun.stdin, "json").mockResolvedValue({ hook_event_name: "Stop" });
  // ... assertions
});
```

## Mocking modules

Use static imports — Bun's ESM live bindings let `mock.module()` update modules that have already been imported. No dynamic `await import()` needed.

`mock.module()` returns a promise, so it must be awaited:

```ts
import { isGitInstalled } from "../../src/commands/git.ts";
import { describe, expect, it, mock } from "bun:test";

const runCommandMock = mock(() => Promise.resolve({ exitCode: 0, stdout: "", stderr: "" }));

await mock.module("../../src/commands/shell.ts", () => ({
  runCommand: runCommandMock,
}));
```

Clear mocks between tests with a global `beforeEach` in a shared setup file so individual test files don't need their own clearing logic.
