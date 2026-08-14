#!/usr/bin/env ruby

# frozen_string_literal: true

# Forwards the previous daily notes' forwardable tasks into today's note and the given scratch file.

require_relative "lib/vault"
require_relative "lib/daily_note"
require_relative "lib/task_forwarder"

abort "Usage: forward-tasks <scratch-file>" if ARGV.length != 1

scratch_path = ARGV.first
vault = Vault.new
todays_daily_note = vault.find_or_create_todays_daily_note
previous_daily_notes = vault.previous_daily_notes
scratch_note = DailyNote.new(path: scratch_path, content: File.read(scratch_path))

begin
  forwarder = TaskForwarder.new(todays_daily_note, previous_daily_notes)
  forwarder.forward.each { vault.write(_1) }
  File.write(scratch_path, scratch_note.create_tasks(forwarder.forwarded_tasks).content)
rescue TaskForwarder::IncompleteTasksError => error
  warn error.message
  exit 1
end
