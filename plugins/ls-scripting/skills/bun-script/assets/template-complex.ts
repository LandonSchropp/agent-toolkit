#!/usr/bin/env bun

import { cli } from "cleye";

const argv = cli({
  name: "script-name",
  help: {
    description: "Description of what the script does.",
  },
  flags: {
    first: {
      type: String,
      description: "Description of the first flag.",
    },
    second: {
      type: String,
      description: "Description of the second flag.",
    },
  },
});

// Check for invalid options
const invalidOption = Object.keys(argv.unknownFlags)[0];

if (invalidOption) {
  console.error(`Error: The option --${invalidOption} is invalid.`);
  argv.showHelp();
  process.exit(1);
}

// Validate required arguments
if (!argv.flags.first) {
  console.error("Error: The --first flag is required.");
  argv.showHelp();
  process.exit(1);
}

if (!argv.flags.second) {
  console.error("Error: The --second flag is required.");
  argv.showHelp();
  process.exit(1);
}

// TODO: Implement script
