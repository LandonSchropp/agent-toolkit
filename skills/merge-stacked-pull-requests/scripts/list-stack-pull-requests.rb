#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "json"

def print_help
  puts <<~HELP
    Usage: list-stack-pull-requests.rb [options]

    List open pull requests in the git-town stack rooted at the given branch,
    in merge order (the given branch first, its descendants after).
    Outputs one line per pull request: number, title, and URL.

    Options:

      --branch <name>   Root of the stack to list.
      --help            Show this help message and exit.
  HELP
end

branch = nil

parser = OptionParser.new do |opts|
  opts.on("--branch VALUE") { branch = _1 }
  opts.on("--help") do
    print_help
    exit 0
  end
end

begin
  parser.parse!
rescue OptionParser::InvalidOption => e
  warn "Error: #{e.message}"
  warn
  print_help
  exit 1
end

if branch.nil? || branch.empty?
  warn "Error: --branch is required."
  warn
  print_help
  exit 1
end

# Build a child map from git-town lineage stored in .git/config.
children = `git config --get-regexp 'git-town-branch\\..*\\.parent'`
  .each_line
  .reduce(Hash.new { _1[_2] = [] }) do |hash, line|
    key, parent = line.split
    hash[parent] << key[/git-town-branch\.(.+)\.parent/, 1]
    hash
  end

# Recursively collect the root branch and all its descendants.
def collect_stack(branch, children)
  [branch] + children[branch].flat_map { collect_stack(_1, children) }
end

stack_branches = collect_stack(branch, children)

# Look up the open pull request for each branch and print it.
stack_branches.each do |stack_branch|
  pull_requests = JSON.parse(`gh pr list --head #{stack_branch} --state open --json number,title,url`)
  pull_requests.each { puts "##{_1["number"]} #{_1["title"]} — #{_1["url"]}" }
end
