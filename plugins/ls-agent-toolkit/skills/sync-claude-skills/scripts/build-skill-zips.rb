#!/usr/bin/env ruby

# frozen_string_literal: true

require "fileutils"
require "open3"
require "optparse"
require "tmpdir"

SKILLS = {
  File.expand_path("~/Development/agent-toolkit") => %w[
    plugins/ls-agent/skills/delegate
    plugins/ls-browser/skills/browser
    plugins/ls-interactivity/skills/interactive-command
    plugins/ls-interactivity/skills/interactive-edit
    plugins/ls-notes/skills/daily-note
    plugins/ls-notes/skills/note
    plugins/ls-notes/skills/project
  ],
  File.expand_path("~/Development/personal-agent-toolkit") => %w[
    plugins/ls-assistant/skills/*
    plugins/ls-health/skills/*
    plugins/ls-scheduling/skills/*
    plugins/ls-ynab/skills/*
  ]
}.freeze

# Uploaded skills lose their plugin prefix, so `<plugin>:<skill>` becomes `<skill>`.
PLUGIN_PREFIX = /\bls-[a-z0-9-]+:(?=[a-z])/

def print_help
  puts <<~HELP
    Usage: build-skill-zips.rb --output <directory> [--since <commit>]

    Builds one zip per skill uploaded to claude.ai, from the committed content on main, and prints
    each zip's path.

    Options:

      --output <directory>  The directory to write the zips to.
      --since <commit>      Only build the skills that changed on main since this commit SHA.
      --help                Show this help message and exit.
  HELP
end

def git(repository, *arguments)
  stdout, status = Open3.capture2("git", "-C", repository, *arguments)
  raise "git #{arguments.join(" ")} failed in #{repository}" unless status.success?

  stdout
end

def commit?(repository, commit)
  git(repository, "rev-parse", "--verify", "--quiet", "#{commit}^{commit}")
  true
rescue RuntimeError
  false
end

def skill_directories(repository, patterns)
  git(repository, "ls-tree", "-r", "--name-only", "main", "plugins")
    .lines(chomp: true)
    .filter { File.basename(_1) == "SKILL.md" }
    .map { File.dirname(_1) }
    .filter { |directory| patterns.any? { File.fnmatch(_1, directory) } }
end

def build_zip(repository, skill_directory, output)
  name = File.basename(skill_directory)
  zip = File.join(output, "#{name}.zip")

  Dir.mktmpdir do |staging|
    git(repository, "ls-tree", "-r", "-z", "main", "#{skill_directory}/").split("\0").each do |entry|
      metadata, path = entry.split("\t", 2)
      mode, _type, object = metadata.split(" ")
      destination = File.join(staging, name, path.delete_prefix("#{skill_directory}/"))
      content = git(repository, "cat-file", "blob", object)
      content = content.gsub(PLUGIN_PREFIX, "") if content.valid_encoding?

      FileUtils.mkdir_p(File.dirname(destination))
      File.binwrite(destination, content)
      FileUtils.chmod(mode == "100755" ? 0o755 : 0o644, destination)
    end

    FileUtils.rm_f(zip)
    system("zip", "--quiet", "--recurse-paths", zip, name, chdir: staging, exception: true)
  end

  zip
end

output = nil
since = nil

parser = OptionParser.new do |opts|
  opts.on("--output DIRECTORY") { output = _1 }
  opts.on("--since COMMIT") { since = _1 }
  opts.on("--help") do
    print_help
    exit 0
  end
end

begin
  parser.parse!
rescue OptionParser::InvalidOption => e
  warn "Error: The option #{e.args.first} is invalid."
  warn ""
  print_help
  exit 1
end

if output.nil? || output.empty?
  warn "Error: The --output flag is required."
  warn ""
  print_help
  exit 1
end

skills = SKILLS.flat_map do |repository, patterns|
  skill_directories(repository, patterns).map { [repository, _1] }
end

skills.group_by { File.basename(_2) }.each do |name, matches|
  next if matches.one?

  warn "Error: More than one skill is named #{name}: #{matches.map { File.join(*_1) }.join(", ")}."
  exit 1
end

unless since.nil?
  repositories = SKILLS.keys.filter { commit?(_1, since) }

  if repositories.empty?
    warn "Error: The commit #{since} is not in either repository."
    exit 1
  end

  skills = skills.filter do |repository, directory|
    repositories.include?(repository) && !git(repository, "diff", "--name-only", since, "main", "--", directory).empty?
  end
end

output = File.expand_path(output)
FileUtils.mkdir_p(output)
skills.each { puts build_zip(_1, _2, output) }
