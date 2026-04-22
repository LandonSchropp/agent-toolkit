#!/usr/bin/env bun
import { cli } from "cleye";

const argv = cli({
  name: "script-name",
  help: {
    description: "Description of what the script does.",
  },
  flags: {
    required: {
      type: String,
      description: "Description of required flag.",
    },
    optional: {
      type: String,
      description: "Description of optional flag.",
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
if (!argv.flags.required) {
  console.error("Error: The --required flag is required.");
  argv.showHelp();
  process.exit(1);
}

// TODO: Implement script
