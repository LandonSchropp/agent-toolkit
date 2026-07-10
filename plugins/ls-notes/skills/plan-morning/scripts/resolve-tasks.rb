#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require_relative "lib/vault"
require_relative "lib/unresolved_task_renderer"

# The scratch file each plan-morning stop opens for interactive editing. Guarded
# so reloading the script (as the spec does) does not reassign the constant.
OUTPUT_PATH = "/tmp/plan-morning.md" unless defined?(OUTPUT_PATH)

def print_help
  puts <<~HELP
    Usage: resolve-tasks [options]

    Writes the recent daily notes' unresolved (- [ ]) tasks to #{OUTPUT_PATH},
    grouped by day, so they can be resolved in a single editing pass before
    forwarding. Forwardable markers (>, <, /) carry forward on their own and are
    left out. Writes nothing and reports when no unresolved tasks remain.

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

renderer = UnresolvedTaskRenderer.new(Vault.new.previous_daily_notes)

if renderer.empty?
  puts "No unresolved tasks in the recent daily notes."
else
  File.write(OUTPUT_PATH, renderer.to_markdown)
  puts "Wrote unresolved tasks to #{OUTPUT_PATH}."
end
