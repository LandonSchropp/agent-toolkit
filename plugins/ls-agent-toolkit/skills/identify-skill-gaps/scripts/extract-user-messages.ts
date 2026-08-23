#!/usr/bin/env bun
import { glob } from "fs/promises";
import { readFile } from "fs/promises";
import { join } from "path";
import { parseArgs } from "util";

interface ConversationEvent {
  type: string;
  timestamp: string;
  message?: {
    role: string;
    content: string | Array<{ type: string; text: string }>;
  };
}

const { values } = parseArgs({
  args: process.argv.slice(2),
  options: {
    after: { type: "string" },
    help: { type: "boolean" },
    path: { type: "string" },
  },
  strict: true,
});

if (values.help) {
  console.log("Usage: extract-user-messages.ts --path <logs-directory> --after <date>");
  process.exit(0);
}

if (!values.path || !values.after) {
  console.error("Both --path and --after are required.");
  process.exit(1);
}

function extractText(content: string | Array<{ type: string; text: string }>): string {
  return typeof content === "string"
    ? content
    : content.filter((item) => item.type === "text").map((item) => item.text).join("\n");
}

const files = glob(join(values.path, "**", "*.jsonl"));

for await (const filePath of files) {
  const content = await readFile(filePath, "utf-8");
  const events = content.trim().split("\n").filter(Boolean).map((line) => JSON.parse(line) as ConversationEvent);

  for (const event of events) {
    if (event.type !== "user" || event.message?.role !== "user" || event.timestamp < values.after) continue;
    const text = extractText(event.message.content);
    if (text.trim().length < 5) continue;
    console.log(`[${event.timestamp}]\n${text}\n---`);
  }
}