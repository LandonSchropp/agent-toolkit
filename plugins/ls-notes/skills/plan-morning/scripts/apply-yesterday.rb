#!/usr/bin/env ruby

# frozen_string_literal: true

# Applies the user's edits from the Yesterday scratch file back to each daily note it covers.

require "date"
require_relative "lib/vault"
require_relative "lib/resolved_task_parser"

SCRATCH_PATH = "/tmp/plan-morning-#{Date.today.iso8601}-yesterday.md".freeze

vault = Vault.new
parser = ResolvedTaskParser.new(File.read(SCRATCH_PATH))

vault.previous_daily_notes.each do |note|
  next unless parser.covers?(note.date)

  edited_tasks = parser.tasks(note.date)
  original_tasks = note.tasks

  incomplete_tasks = original_tasks.select { _1.any?(&:incomplete?) }
  deleted_tasks = incomplete_tasks.reject { _1.in?(edited_tasks) }
  created_tasks = edited_tasks.reject { _1.in?(original_tasks) }

  updated_note = note
    .create_tasks(created_tasks)
    .update_tasks(edited_tasks)
    .delete_tasks(deleted_tasks)

  vault.write(updated_note) unless updated_note == note
end
