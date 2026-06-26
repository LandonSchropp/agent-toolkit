---
description: Use when writing or modifying tests for Ink (terminal UI) components.
---

# Testing Ink Components

Use `render` from `ink-testing-library`, not `@testing-library/react`. Ink has its own renderer, so the DOM library can't reach it.

```tsx
import { render } from "ink-testing-library";

const { lastFrame, frames, rerender } = render(<MyComponent />);
expect(lastFrame()).toContain("expected text");
```

- `lastFrame()`: the most recent rendered terminal frame as a string.
- `frames`: the full array of frames in render order.
- `rerender(<MyComponent prop={next} />)`: re-render with new props.

## Testing hooks in a Bun project

Bun has no DOM, so testing a hook (via `testing-react`) needs DOM globals registered. Call `@happy-dom/global-registrator` before any `@testing-library/react` import, so the DOM is present when React DOM loads.

```tsx
import { GlobalRegistrator } from "@happy-dom/global-registrator";

GlobalRegistrator.register();

import { renderHook } from "@testing-library/react";
```
