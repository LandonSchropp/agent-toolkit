---
name: react-component
description: Use when writing or editing a React component. Covers preferred patterns for functional components, prop types, and styling.
---

## Conventions

- Functional component declared with `export function ComponentName` (named export, not default, not arrow)
- Props typed above the component as `type ComponentNameProps = { ... }`
- Each prop has a JSDoc comment documenting its purpose
- Destructure props in the function signature
- Use Tailwind classes for styling (no custom CSS classes)
- Use `clsx` only when combining dynamic classes

## Example

```tsx
import clsx from "clsx";

type UserAvatarProps = {
  /** The URL of the user's avatar image. */
  imageUrl: string;

  /** The user's full name, used as the alt text. */
  name: string;

  /** The size of the avatar. */
  size?: "small" | "medium" | "large";
};

export function UserAvatar({ imageUrl, name, size = "medium" }: UserAvatarProps) {
  return (
    <img
      src={imageUrl}
      alt={name}
      className={clsx(
        "rounded-full",
        size === "small" && "h-8 w-8",
        size === "medium" && "h-12 w-12",
        size === "large" && "h-16 w-16",
      )}
    />
  );
}
```
