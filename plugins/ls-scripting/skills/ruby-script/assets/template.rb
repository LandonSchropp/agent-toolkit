#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"

def print_help
  puts <<~HELP
    Usage: script-name [options]

    Description of what the script does.

    Options:

      --required <value>    Description of required flag.
      --optional <value>    Description of optional flag.
      --help                Show this help message and exit.
  HELP
end

required_flag = nil
optional_flag = nil

parser = OptionParser.new do |opts|
  opts.on("--required VALUE") { required_flag = _1 }
  opts.on("--optional VALUE") { optional_flag = _1 }
  opts.on("--help") do
    print_help
    exit 0
  end
end

begin
  parser.parse!
rescue OptionParser::InvalidOption => e
  warn "Error: The option #{e.args.first} is invalid."
  warn
  print_help
  exit 1
end

# Validate required arguments
if required_flag.nil? || required_flag.empty?
  warn "Error: The --required flag is required."
  warn
  print_help
  exit 1
end

# TODO: Implement script
