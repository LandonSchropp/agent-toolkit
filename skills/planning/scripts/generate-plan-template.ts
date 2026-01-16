#!/usr/bin/env bun
import { mkdir, readFile, writeFile } from "fs/promises";
import { Liquid } from "liquidjs";
import { join, dirname, resolve } from "path";
import dedent from "ts-dedent";
import { parseArgs } from "util";
import { z } from "zod";

// Parse the command line arguments
const { values } = parseArgs({
  args: process.argv.slice(2),
  options: {
    title: { type: "string" },
    type: { type: "string" },
    featureBranch: { type: "string" },
    baseBranch: { type: "string" },
    linearIssueId: { type: "string" },
    sentryIssueUrl: { type: "string" },
  },
  strict: true,
});

// Define Zod schema for validation
const argsSchema = z.object({
  title: z.string(),
  type: z.enum(["feature", "bug-fix", "refactor"]),
  featureBranch: z.string(),
  baseBranch: z.string(),
  linearIssueId: z
    .string()
    .regex(/^[A-Z]+-\d+$/, "Must be in format ABC-123")
    .optional(),
  sentryIssueUrl: z.string().url().optional(),
});

// Validate arguments with Zod
const parseResult = argsSchema.safeParse(values);

if (!parseResult.success) {
  console.error(dedent`
    Usage: generate-plan-template.ts \\
      --title <title> \\
      --type <feature|bug-fix|refactor> \\
      --featureBranch <branch> \\
      --baseBranch <branch> \\
      [--linearIssueId <id>] \\
      [--sentryIssueUrl <url>]
  `);
  console.error("\nValidation errors:");

  for (const issue of parseResult.error.issues) {
    console.error(`- ${issue.path.join(".")}: ${issue.message}`);
  }

  process.exit(1);
}

const options = parseResult.data;

// Create a timestamp from the current ISO date
const timestamp = new Date()
  .toISOString()
  .replace(/\..*$/, "")
  .replace(/[:]/g, "-")
  .replace("T", "_");

// Determine the paths
const templatePath = join(import.meta.dir, "..", "assets", `${options.type}.md.liquid`);
const planPath = resolve(
  join(".agent/plans", options.featureBranch, `${timestamp}_${options.type}.md`),
);

// Render the template
const liquid = new Liquid({
  root: "/",
  relativeReference: true,
  extname: ".md.liquid",
  strictFilters: true,
  strictVariables: true,
  lenientIf: true,
});

const templateContent = await readFile(templatePath, "utf-8");
const renderedContent = await liquid.parseAndRender(templateContent, options);

// Write plan file
await mkdir(dirname(planPath), { recursive: true });
await writeFile(planPath, renderedContent, "utf-8");

// Output the path
console.log(planPath);
