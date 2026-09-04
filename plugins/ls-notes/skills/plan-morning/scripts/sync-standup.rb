#!/usr/bin/env ruby

# frozen_string_literal: true

# Refreshes the Standup scratch file's Today reference block from the Today scratch file's current Work tasks.

require "date"
require_relative "lib/daily_note"
require_relative "lib/markdown"

TODAY_PATH = "/tmp/plan-morning-#{Date.today.iso8601}-today.md".freeze
STANDUP_PATH = "/tmp/plan-morning-#{Date.today.iso8601}-standup.md".freeze

REFERENCE_PREFIX = "Work tasks from today's daily note (reference only — not included in standup)"
COMMENT_REGEX = /<!--.*?-->/m

today_note = DailyNote.new(path: TODAY_PATH, content: File.read(TODAY_PATH))
work_tasks = today_note.tasks.select { _1.subheader == "Work" }

comment = if work_tasks.empty?
  "<!-- #{REFERENCE_PREFIX}: none -->"
else
  "<!-- #{REFERENCE_PREFIX}:\n#{work_tasks.map(&:to_markdown).join("\n")}\n-->"
end

standup_content = File.read(STANDUP_PATH)
today_section = Markdown.section(standup_content, "Today", 2)
updated_section = today_section.sub(COMMENT_REGEX, comment)

File.write(STANDUP_PATH, Markdown.replace_section(standup_content, "Today", 2, updated_section))
