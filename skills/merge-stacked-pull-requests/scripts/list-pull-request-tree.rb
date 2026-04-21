#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "json"

def print_help
  puts <<~HELP
    Usage: list-pull-request-tree.rb [options]

    List open pull requests in the git-town tree containing the given branch,
    in merge order (oldest ancestor first, descendants after).
    Outputs one line per pull request per branch, indented to reflect the tree hierarchy.

    Options:

      --branch <name>   Any branch in the tree.
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

Tree = Struct.new(:branch, :pull_request, :children)

default_branch = `git default-branch`.strip

# Build a child map from git-town lineage stored in .git/config.
children = `git config --get-regexp 'git-town-branch\\..*\\.parent'`
  .each_line
  .reduce(Hash.new { _1[_2] = [] }) do |hash, line|
    key, parent = line.split
    hash[parent] << key[/git-town-branch\.(.+)\.parent/, 1]
    hash
  end

# Returns the open pull request for the branch, or nil if none exists.
def fetch_pull_request(branch)
  JSON.parse(`gh pr list --head #{branch} --state open --json number,title,url`).first
end

# Recursively builds a tree of the given branch and all its descendants.
def find_descendants(branch, children)
  Tree.new(branch, fetch_pull_request(branch), children[branch].map { find_descendants(_1, children) })
end

# Recursively wraps the subtree in ancestor nodes, walking up until the default branch.
def find_ancestors(branch, default_branch, subtree)
  parent = `git config git-town-branch.#{branch}.parent 2>/dev/null`.strip
  return subtree if parent.empty? || parent == default_branch
  find_ancestors(parent, default_branch, Tree.new(parent, fetch_pull_request(parent), [subtree]))
end

# Print the tree with indentation.
def print_tree(node, depth = 0)
  label = if node.pull_request
    "##{node.pull_request["number"]} #{node.pull_request["title"]}"
  else
    "<No Pull Request>"
  end
  puts "  " * depth + "#{node.branch} — #{label}"
  node.children.each { print_tree(_1, depth + 1) }
end

tree = find_ancestors(branch, default_branch, find_descendants(branch, children))
print_tree(tree)
