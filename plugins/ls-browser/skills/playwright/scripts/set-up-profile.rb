#!/usr/bin/env ruby

# frozen_string_literal: true

require "optparse"
require "fileutils"
require "json"

PROFILES = File.join(Dir.home, ".local", "share", "agent-toolkit", "playwright")

def print_help
  puts <<~HELP
    Usage: set-up-profile.rb --profile <name>

    Creates a Chrome profile for playwright-cli with Chrome's own password manager
    turned off. Install 1Password in the profile by hand before signing in to a site.

    Options:

      --profile <name>    Name of the profile to create (required).
      --help              Show this help message and exit.
  HELP
end

profile = nil

parser = OptionParser.new do |opts|
  opts.on("--profile NAME") { profile = _1 }
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

if profile.nil? || profile.empty?
  warn "Error: The --profile flag is required."
  warn
  print_help
  exit 1
end

unless profile.match?(/\A[a-z0-9-]+\z/i)
  warn "Error: The profile name '#{profile}' may only contain letters, numbers and dashes."
  exit 1
end

path = File.join(PROFILES, profile)

if Dir.exist?(path)
  warn "Error: The profile '#{profile}' already exists at #{path}."
  exit 1
end

FileUtils.mkdir_p(File.join(path, "Default"))

# Chrome fills in the rest of Preferences the first time it starts.
File.write(File.join(path, "Default", "Preferences"), JSON.generate(
  "credentials_enable_service" => false,
  "credentials_enable_autosignin" => false,
  "profile" => { "password_manager_enabled" => false }
))

puts "Created the '#{profile}' profile at '#{path}'."
