#!/usr/bin/env ruby

# frozen_string_literal: true

# Forwards the previous daily notes' forwardable tasks into today's note and the Today scratch file.

require "date"
require_relative "lib/vault"
require_relative "lib/daily_note"
require_relative "lib/task_forwarder"

SCRATCH_PATH = "/tmp/plan-morning-#{Date.today.iso8601}-today.md".freeze

vault = Vault.new
todays_daily_note = vault.find_or_create_todays_daily_note
previous_daily_notes = vault.previous_daily_notes
scratch_note = DailyNote.new(path: SCRATCH_PATH, content: File.read(SCRATCH_PATH))

begin
  forwarder = TaskForwarder.new(todays_daily_note, previous_daily_notes)
  forwarder.forward.each { vault.write(_1) }
  File.write(SCRATCH_PATH, scratch_note.create_tasks(forwarder.forwarded_tasks).content)
rescue TaskForwarder::IncompleteTasksError => error
  warn error.message
  exit 1
end
