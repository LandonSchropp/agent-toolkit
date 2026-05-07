# Colored Echo

Use ANSI escape codes for colored terminal output. Format: `echo -e "\033[0;<CODE>m<TEXT>\033[0m"`.

## Color codes

| Color  | Code |
| ------ | ---- |
| Black  | 30   |
| Red    | 31   |
| Green  | 32   |
| Yellow | 33   |
| Blue   | 34   |
| Purple | 35   |
| Cyan   | 36   |
| White  | 37   |

## Inline usage

```bash
echo -e "\033[0;31mError: something failed\033[0m"
echo -e "\033[0;32mSuccess!\033[0m"
```

## Reusable functions

Only extract helper functions if the inline form would be repeated several times in the script. For one-off colored output, prefer inline. Define one function per color used:

```bash
echo-red() {
  echo -e "\033[0;31m$1\033[0m"
}

echo-green() {
  echo -e "\033[0;32m$1\033[0m"
}
```
