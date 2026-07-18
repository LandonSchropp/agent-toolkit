#!/usr/bin/env bash

set -euo pipefail

function print_help() {
  echo "Usage: script-name [options]"
  echo
  echo "Description of what the script does."
  echo
  echo "Options:"
  echo
  echo "  --first <value>     Description of the first flag."
  echo "  --second <value>    Description of the second flag."
  echo "  --help              Show this help message and exit."
}

# Parse arguments
first=""
second=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    print_help
    exit 0
    ;;
  --first)
    first="$2"
    shift 2
    ;;
  --second)
    second="$2"
    shift 2
    ;;
  *)
    echo "Error: The option $1 is invalid." >&2
    echo >&2
    print_help >&2
    exit 1
    ;;
  esac
done

# Validate required arguments
if [[ -z "$first" ]]; then
  echo "Error: The --first flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

if [[ -z "$second" ]]; then
  echo "Error: The --second flag is required." >&2
  echo >&2
  print_help >&2
  exit 1
fi

# TODO: Implement script
