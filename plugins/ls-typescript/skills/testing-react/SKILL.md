---
description: Use when writing or modifying tests for React hooks.
---

# Testing React Hooks

Use `renderHook` and `act` from `@testing-library/react`. Don't write a probe component — `renderHook` is the affordance for testing a hook in isolation.

```tsx
import { useMyHook } from "./use-my-hook.ts";
import { act, renderHook } from "@testing-library/react";

const { result, rerender, unmount } = renderHook(() => useMyHook(arg));
expect(result.current).toBe(/* ... */);
```

`renderHook` needs DOM globals. A typical React project provides them through its configured test environment (jsdom or happy-dom), so no per-test setup is required.
