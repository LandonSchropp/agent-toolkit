#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require_relative "lib/vault"
require_relative "lib/task_forwarder"

def print_help
  puts <<~HELP
    Usage: forward-tasks [options]

    Forwards forwardable tasks (>, <, /) from the recent previous daily notes into
    today's daily note. Forwarded and partial tasks become to-dos; scheduled tasks
    keep their marker and are removed from their source.

    Exits 1 if any previous note still holds an incomplete (- [ ]) task, listing
    the offending notes to stderr.

    Options:

      --help    Show this help message and exit.
  HELP
end

parser = OptionParser.new do |opts|
  opts.on("--help") do
    print_help
    exit 0
  end
end

begin
  parser.parse!
rescue OptionParser::InvalidOption => error
  warn "Error: The option #{error.args.first} is invalid."
  warn
  print_help
  exit 1
end

vault = Vault.new
todays_daily_note = vault.find_or_create_todays_daily_note
previous_daily_notes = vault.previous_daily_notes

begin
  TaskForwarder
    .new(todays_daily_note, previous_daily_notes)
    .forward
    .each { vault.write(_1) }
rescue TaskForwarder::IncompleteTasksError => error
  warn error.message
  exit 1
end
