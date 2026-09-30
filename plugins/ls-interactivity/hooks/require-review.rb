#!/usr/bin/env ruby

# frozen_string_literal: true

# PreToolUse hook that blocks `git commit` until the pending changes have been reviewed. Reads a
# tool-call description as JSON from stdin and denies it unless the target repo's current HEAD is
# recorded as reviewed in the shared reviews database.

require "json"
require "open3"
require "shellwords"

DATABASE = File.join(ENV["XDG_CACHE_HOME"] || File.join(ENV.fetch("HOME"), ".cache"), "agent-toolkit", "reviews.db")

# Checks whether the review requirement is suspended for this herdr workspace. The disable-review
# skill records a disable time, and the requirement stays suspended for an hour after it.
#
# @return [Boolean] True when the workspace disabled the review requirement within the last hour.
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

# Checks whether the pending work on a base has already been reviewed. Guard on the database file so
# a fresh machine (no reviews recorded yet) doesn't create an empty one here.
#
# @param head [String] The SHA of the commit the pending work builds on.
# @return [Boolean] True when a review is recorded for the head.
def reviewed?(head)
  return false unless File.exist?(DATABASE)

  query = "SELECT 1 FROM reviews WHERE head = '#{head}' LIMIT 1;"
  !`sqlite3 #{DATABASE.shellescape} #{query.shellescape} 2>/dev/null`.strip.empty?
end

# Denies the tool call and exits.
#
# @param reason [String] The explanation shown to the agent.
# @return [void]
def deny(reason)
  puts JSON.generate(
    {
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: reason,
      },
    }
  )
  exit 0
end

# Collects every simple command in a shell syntax tree, however deeply it's nested.
#
# @param node [Hash, Array, Object] A node from shfmt's JSON syntax tree.
# @return [Array<Hash>] The `CallExpr` nodes in the tree.
def extract_commands(node)
  case node
  in Array then node.flat_map { extract_commands(_1) }
  in { Type: "CallExpr" } then [node] + extract_commands(node.values)
  in Hash then extract_commands(node.values)
  else []
  end
end

# Resolves a node to its value.
#
# @param node [Hash] A word, or a part of one, from shfmt's JSON syntax tree.
# @return [String, nil] The word's text, or nil when the shell would expand something in it.
def resolve_value(node)
  case node
  in { Value: value } then value
  in { Parts: parts }
    texts = parts.map { resolve_value(_1) }
    texts.join unless texts.include?(nil)
  else nil
  end
end

# Finds the subcommand in `git [options] <subcommand>`: the first word after `git` that isn't an
# option or the value of `-C` or `-c`.
#
# @param words [Array<String, nil>] The command's words, starting with `git`.
# @return [String, nil] The subcommand, or nil when there isn't one.
def find_subcommand(words)
  _, subcommand = words.each_cons(2).find do |previous, word|
    !word.to_s.start_with?("-") && !["-C", "-c"].include?(previous)
  end

  subcommand
end

# Resolves each of a simple command's words to its text.
#
# @param simple_command [Hash] A `CallExpr` node from shfmt's JSON syntax tree.
# @return [Array<String, nil>] The words' text, with nil for each word the shell would expand.
def resolve_values(simple_command)
  simple_command[:Args].to_a.map { resolve_value(_1) }
end

# Checks whether a command's words run `git [options] commit`.
#
# @param words [Array<String, nil>] The command's resolved words.
# @return [Boolean] True when the words create a commit.
def git_commit?(words)
  words.first == "git" && find_subcommand(words) == "commit"
end

input = JSON.parse($stdin.read)
command = input.dig("tool_input", "command") || ""
working_directory = input["cwd"] || "."

# Reviewing needs herdr, so outside it there is no user to review anything and no way to record
# one. Blocking there would deny every commit an unattended run makes.
exit 0 unless ENV.key?("HERDR_ENV")

# Parse the command into a syntax tree. There's nothing to check in a command shfmt can't parse, but
# without shfmt at all, nothing that might commit can be checked.
begin
  tree, status = Open3.capture2("shfmt", "--to-json", stdin_data: command)
rescue Errno::ENOENT
  exit 0 unless command.match?(/\bcommit\b/)
  deny("The review hook needs shfmt to check commits. Ask the user to install it with `brew install shfmt`.")
end

exit 0 unless status.success?

statements = JSON.parse(tree, symbolize_names: true)[:Stmts]

# Only gate commands that create a commit; ignore everything else.
commits = extract_commands(statements).select { git_commit?(resolve_values(_1)) }

exit 0 if commits.empty?

# If the user has temporarily disabled the review requirement for this session, allow the commit.
exit 0 if review_disabled?

# Only allow a lone `git commit`, so a chained `cd` can't move it into a repo this hook doesn't check.
unless statements.size == 1 && commits == [statements.first[:Cmd]] && commits.first[:Assigns].to_a.empty?
  deny("Run `git commit` on its own, not chained or nested. Use `git -C <dir>` for another directory.")
end

words = resolve_values(commits.first)

# Amends, fixups and squashes edit existing history rather than adding new work, so leave them
# alone.
exit 0 if words.grep(/\A--(amend|fixup|squash)(=|\z)/).any?

# The commit may target another repo by passing `git -C <dir>`, which git applies in order, each
# relative to the last. Only a `-C` before the subcommand is that flag; after it, `git commit -C
# <commit>` reuses a message.
options = words.take_while { _1 != "commit" }

options.each_with_index do |word, index|
  next unless word == "-C"

  # A path the shell expands, like `"$REPO"`, can't be resolved here.
  deny("Pass `git -C` a literal path.") unless options[index + 1]
  working_directory = File.expand_path(options[index + 1], working_directory)
end

# The commit builds on the target repo's HEAD. Before the first commit there is no HEAD to build
# on, so there's nothing to review.
head = `git -C #{working_directory.shellescape} rev-parse --verify --quiet HEAD 2>/dev/null`.strip
exit 0 if head.empty?

# Allow the commit when the pending work on this base has already been reviewed.
exit 0 if reviewed?(head)

deny("The user has not reviewed these changes. Invoke the ls-interactivity:interactive-review skill, present the changes to the user, and only commit once the user signs off.")
