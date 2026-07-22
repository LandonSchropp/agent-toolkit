#!/usr/bin/env ruby

# frozen_string_literal: true

require "optparse"
require "io/console"

def print_help
  puts <<~HELP
    Usage: confirm.rb --prompt <text> [--affirmative <label>] [--negative <label>] [--output <file>]

    Renders a themed, centered approve/deny prompt in the current pane and blocks
    until the user answers. Exits 0 for the affirmative choice, 1 for the negative
    choice or quit.

    Assumes a pane with a TTY is already available. Call this inline from a
    script that already owns one. To open a fresh herdr tab instead (e.g. when
    invoking directly as an agent action), use interactive-confirm.sh.

    Options:

      --prompt <text>        Question to display (required).
      --affirmative <label>  Label for the affirmative button (default: Approve).
      --negative <label>     Label for the negative button (default: Deny).
      --output <file>        Also write 'approved' or 'denied' here.
      --help                 Show this help message and exit.
  HELP
end

prompt = nil
affirmative = "Approve"
negative = "Deny"
output = nil

parser = OptionParser.new do |opts|
  opts.on("--prompt TEXT") { prompt = _1 }
  opts.on("--affirmative LABEL") { affirmative = _1 }
  opts.on("--negative LABEL") { negative = _1 }
  opts.on("--output FILE") { output = _1 }
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

if prompt.nil? || prompt.empty?
  warn "Error: The --prompt flag is required."
  warn
  print_help
  exit 1
end

# ANSI escape codes
CLEAR_SCREEN = "\e[H\e[2J"
CURSOR_UP = "\e[%dA"
GRAY = "\e[38;5;8m"
RESET = "\e[0m"

# Sizing
BUTTON_PADDING = 3
BUTTON_GAP = 1

# Labels
HELP_TEXT = "←→ toggle • enter submit"

# Pad the shorter label evenly on both sides.
affirmative_pad = [(negative.length - affirmative.length) / 2, 0].max
negative_pad = [(affirmative.length - negative.length) / 2, 0].max
affirmative = "#{' ' * affirmative_pad}#{affirmative}#{' ' * affirmative_pad}"
negative = "#{' ' * negative_pad}#{negative}#{' ' * negative_pad}"

rows, cols = IO.console.winsize

buttons_width = BUTTON_PADDING * 2 + affirmative.length + BUTTON_GAP + BUTTON_PADDING * 2 + negative.length
box_height = 3

# Buttons anchor the shared padding. Gum can't offset one button without
# doubling the inter-button gap.
max_width = [prompt.length, buttons_width, HELP_TEXT.length].max
shared_left = (cols - max_width + 1) / 2
buttons_left = shared_left
prompt_extra_left = (max_width - prompt.length) / 2
help_left = shared_left + (max_width - HELP_TEXT.length) / 2

top = (rows - box_height) / 2

print CLEAR_SCREEN
print "\n" * (top + box_height + 1)
print " " * help_left
print "#{GRAY}#{HELP_TEXT}#{RESET}"
print CURSOR_UP % (box_height + 1)

system(
  "gum", "confirm",
  "--padding", "0 0 0 #{buttons_left}",
  "--no-show-help",
  "--prompt.foreground", "4",
  "--prompt.margin", "0 0 0 #{prompt_extra_left}",
  "--selected.foreground", "0",
  "--selected.background", "7",
  "--selected.margin", "0 #{BUTTON_GAP} 0 0",
  "--unselected.foreground", "7",
  "--unselected.background", "0",
  "--unselected.margin", "0 #{BUTTON_GAP} 0 0",
  "--affirmative", affirmative,
  "--negative", negative,
  prompt
)
result = $?.exitstatus

File.write(output, result.to_s) if output

exit result
