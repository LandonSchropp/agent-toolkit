# frozen_string_literal: true

# A single task parsed from a daily note: its marker type, text, and the Tasks
# subheader (Personal, Work, ...) it falls under. Tasks are immutable value
# objects; transformations such as converting a forwarded task into a to-do
# return a new instance via +with+.
Task = Data.define(:type, :text, :subheader) do
  # Matches a task list item, capturing the marker type and the text. Allows
  # leading indentation and any list bullet (-, +, *, or a number). Requires a
  # space after the checkbox, so a bare "- [ ]" is not treated as a task.
  TASK_REGEX = /\A[ \t]*(?:[-+*]|\d+\.) \[(.)\] (.*)\z/

  # Parses a line into a {Task} belonging to the given subheader.
  #
  # @param line [String] the line to parse
  # @param subheader [String] the Tasks subheader the task falls under
  # @return [Task, nil] the parsed task, or nil when the line is not a task
  def self.parse(line, subheader)
    match = TASK_REGEX.match(line)
    return nil unless match

    new(type: match[1], text: match[2], subheader:)
  end

  # @return [Boolean] whether the task is marked to be forwarded (">")
  def forwarded?
    type == ">"
  end

  # @return [Boolean] whether the task is scheduled to roll forward ("<")
  def scheduled?
    type == "<"
  end

  # @return [Boolean] whether the task is complete ("x")
  def complete?
    type == "x"
  end

  # @return [Boolean] whether the task is an unaddressed to-do (" ")
  def incomplete?
    type == " "
  end

  # @return [Boolean] whether the task is partially complete ("/")
  def partial?
    type == "/"
  end

  # @return [Boolean] whether the task is cancelled ("-")
  def cancelled?
    type == "-"
  end

  # @return [Boolean] whether the task should be carried into the next daily note
  def forwardable?
    forwarded? || scheduled? || partial?
  end

  # @param other [Task] the task to compare against
  # @return [Boolean] whether both refer to the same task, ignoring their markers
  def matches?(other)
    text == other.text && subheader == other.subheader
  end

  # @return [String] the task rendered as a Markdown list item
  def to_markdown
    "- [#{type}] #{text}"
  end
end
