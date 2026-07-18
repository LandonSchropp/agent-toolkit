#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"

def print_help
  puts <<~HELP
    Usage: script-name [options]

    Description of what the script does.

    Options:

      --first <value>     Description of the first flag.
      --second <value>    Description of the second flag.
      --help              Show this help message and exit.
  HELP
end

first = nil
second = nil

parser = OptionParser.new do |opts|
  opts.on("--first VALUE") { first = _1 }
  opts.on("--second VALUE") { second = _1 }
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
if first.nil? || first.empty?
  warn "Error: The --first flag is required."
  warn
  print_help
  exit 1
end

if second.nil? || second.empty?
  warn "Error: The --second flag is required."
  warn
  print_help
  exit 1
end

# TODO: Implement script
