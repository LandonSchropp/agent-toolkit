#!/usr/bin/env ruby

# frozen_string_literal: true

# PreToolUse hook that blocks `git commit` until the pending changes have been reviewed. Reads a
# tool-call description as JSON from stdin and denies it unless the target repo's current HEAD is
# recorded as reviewed in the shared reviews database.

require "json"
require "shellwords"

DATABASE = File.join(ENV["XDG_CACHE_HOME"] || File.join(ENV.fetch("HOME"), ".cache"), "agent-toolkit", "reviews.db")

# The disable-review skill suspends the review requirement for a herdr workspace by recording its
# disable time. Treat the requirement as disabled while that time is within the last hour.
def review_disabled?
  return false unless File.exist?(DATABASE)

  workspace_id = ENV["HERDR_WORKSPACE_ID"]
  return false unless workspace_id && !workspace_id.empty?

  query = <<~SQL
    SELECT 1 FROM overrides
    WHERE workspace = '#{workspace_id}'
      AND disabled_at > strftime('%s', 'now') - 3600
    LIMIT 1;
  SQL
  !`sqlite3 #{DATABASE.shellescape} #{query.shellescape} 2>/dev/null`.strip.empty?
end

# The pending work on this base has already been reviewed. Guard on the database file so a fresh
# machine (no reviews recorded yet) doesn't create an empty one here.
def reviewed?(head)
  return false unless File.exist?(DATABASE)

  query = "SELECT 1 FROM reviews WHERE head = '#{head}' LIMIT 1;"
  !`sqlite3 #{DATABASE.shellescape} #{query.shellescape} 2>/dev/null`.strip.empty?
end

input = JSON.parse($stdin.read)
command = input.dig("tool_input", "command") || ""
working_directory = input["cwd"] || "."

# Only gate commands that create a commit; ignore everything else. Match `commit` as the git
# subcommand after any global options (e.g. `git -C <dir> commit`), not as a substring in a flag
# value or branch name.
exit 0 unless command =~ /(^|[^[:alnum:]])git[[:space:]]+([^[:space:]]+[[:space:]]+)*commit([[:space:]]|$)/

# Amends edit existing history rather than adding new work, so leave them alone.
exit 0 if command.include?("--amend")

# The user has temporarily disabled the review requirement for this session, so allow the commit.
exit 0 if review_disabled?

# The hook runs in the session's primary repo, but the commit may target another one by passing
# `git -C <dir>`. Use that directory when present. An in-command `cd` isn't visible here, so
# commits in another repo must go through `git -C`.
if (match = command.match(/[[:space:]]-C[[:space:]]+([^[:space:]]+)/))
  working_directory = match[1]
end

# The commit builds on the target repo's HEAD. Before the first commit there is no HEAD to build
# on, so there's nothing to review.
head = `git -C #{working_directory.shellescape} rev-parse --verify --quiet HEAD 2>/dev/null`.strip
exit 0 if head.empty?

# Allow the commit when the pending work on this base has already been reviewed.
exit 0 if reviewed?(head)

reason = "The user has not reviewed these changes. Invoke the interactive-review skill, present the changes to the user, and only commit once the user signs off."

puts JSON.generate(
  {
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: reason,
    },
  }
)
