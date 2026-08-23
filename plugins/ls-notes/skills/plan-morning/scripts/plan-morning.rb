#!/usr/bin/env ruby

# frozen_string_literal: true

# Runs plan-morning's whole editing pass: the Yesterday, Today, and Standup
# windows and the steps between them.
#
# HARD INVARIANT. DO NOT VIOLATE.
#
# This is the ONLY script the skill runs for the editing pass, and it must stay
# that way. The whole pass runs start to finish here, with NO agent step between
# any two of its steps. The agent still pre-processes the scratch files before
# the pass and post-processes the results after it. What it must never do is
# interrupt the pass partway through.
#
# Never split this script into multiple scripts and change the skill to run them
# separately. Each handoff back to the agent is dead time the user sits through
# between windows, staring at a closed editor while a model thinks. That cost is
# invisible in a passing test suite. Only the person waiting feels it. A change
# that reads as a harmless refactor ("just run the scripts separately", "let the
# agent check in between") reintroduces exactly the stall this was built to
# remove.
#
# Every step belongs here. When a new one is needed, add it to this sequence
# rather than asking the skill to run it. The scripts this one calls are
# internal to the pass: they are not agent entry points.

require "date"

DATE = Date.today.iso8601

YESTERDAY = "/tmp/plan-morning-#{DATE}-yesterday.md".freeze
TODAY = "/tmp/plan-morning-#{DATE}-today.md".freeze
STANDUP = "/tmp/plan-morning-#{DATE}-standup.md".freeze
LOG = "/tmp/plan-morning-#{DATE}.log".freeze

APPLY_YESTERDAY_SCRIPT = File.expand_path("apply-yesterday.rb", __dir__).freeze
FORWARD_TASKS_SCRIPT = File.expand_path("forward-tasks.rb", __dir__).freeze

abort "Error: Missing plan-morning scratch files for #{DATE}." unless File.exist?(YESTERDAY) && File.exist?(TODAY)

system("nvim", "--", YESTERDAY, exception: true)
system(APPLY_YESTERDAY_SCRIPT, out: [LOG, "a"], err: %i[child out], exception: true)
system(FORWARD_TASKS_SCRIPT, out: [LOG, "a"], err: %i[child out], exception: true)
system("nvim", "--", TODAY, exception: true)
system("nvim", "--", STANDUP, exception: true) if File.exist?(STANDUP)
