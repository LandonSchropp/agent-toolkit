#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require_relative "lib/vault"
require_relative "lib/unresolved_task_renderer"

SCRATCH_PATH = "/tmp/plan-morning-#{Date.today.iso8601}-yesterday.md".freeze

renderer = UnresolvedTaskRenderer.new(Vault.new.previous_daily_notes)

if renderer.empty?
  puts "No unresolved tasks in the recent daily notes."
else
  File.write(SCRATCH_PATH, renderer.to_markdown)
  puts "Wrote unresolved tasks to #{SCRATCH_PATH}."
end
