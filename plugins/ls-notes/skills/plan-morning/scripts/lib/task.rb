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

  # Parses a task block into a {Task} belonging to the given subheader. The
  # text is a string whose first line is the task line; any following indented
  # lines (including blank separators between them) are the body and are stored
  # as part of {#text}.
  #
  # @param text [String] the full task block, including any indented body lines
  # @param subheader [String] the Tasks subheader the task falls under
  # @return [Task, nil] the parsed task, or nil when the first line is not a task
  def self.parse(text, subheader)
    first_line, *body_lines = text.lines(chomp: true)
    match = TASK_REGEX.match(first_line)
    return nil unless match

    text = [match[2], *body_lines].join("\n").rstrip
    new(type: match[1], text:, subheader:)
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

  # The first line of {#text}, used to identify the task across days regardless
  # of how body lines may have changed.
  #
  # @return [String]
  def first_line
    text.lines.first&.chomp || text
  end

  # @param other [Task] the task to compare against
  # @return [Boolean] whether both refer to the same task, ignoring their markers,
  #   any differences in body lines, and any emoji decoration
  def matches?(other)
    match_key == other.match_key && subheader == other.subheader
  end

  # @return [String] the task rendered as a Markdown list item
  def to_markdown
    "- [#{type}] #{text}"
  end

  protected

  def match_key
    first_line.gsub(/[^[:alnum:]]/, "").downcase
  end
end
