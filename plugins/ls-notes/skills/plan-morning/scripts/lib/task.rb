# frozen_string_literal: true

# A single task parsed from a daily note: its marker type, text, the Tasks
# subheader (Personal, Work, ...) it falls under, and its nested subtasks. Tasks
# are immutable value objects; transformations such as converting a forwarded
# task into a to-do return a new instance via +with+.
#
# {#text} is the task's own text only. Subtasks live in {#children}, never
# inside the text, so that a subtask can be inspected and rewritten on its own.
Task = Data.define(:type, :text, :subheader, :children) do
  # Matches a task list item, capturing the indentation, the marker type, and
  # the text. Allows any list bullet (-, +, *, or a number). Requires a space
  # after the checkbox, so a bare "- [ ]" is not treated as a task.
  TASK_REGEX = /\A([ \t]*)(?:[-+*]|\d+\.) \[(.)\] (.*)\z/

  # Matches a complete task block: a top-level task line, any body content
  # (indented lines and blank separators between them) up to but not including
  # the next top-level task line or a header line (so nested sub-subheaders are
  # not absorbed into the preceding task's body), and the newline that ends it.
  # Consuming that newline keeps blank-line separators intact when a block is
  # rewritten or dropped.
  BLOCK_REGEX = /^(?:[-+*]|\d+\.) \[.\] [^\n]+(?:\n(?!(?:[-+*]|\d+\.) \[|#)[^\n]*)*\n?/

  def initialize(type:, text:, subheader:, children: [])
    super
  end

  class << self
    # Parses a task block into a {Task} belonging to the given subheader. The
    # block's first line is the task line; indented task lines below it become
    # {#children}, and any other lines become part of the enclosing task's
    # {#text}.
    #
    # @param text [String] the full task block, including any indented body lines
    # @param subheader [String] the Tasks subheader the task falls under
    # @return [Task, nil] the parsed task, or nil when the first line is not a task
    def parse(text, subheader)
      first_line, *body_lines = text.lines(chomp: true)
      match = first_line && TASK_REGEX.match(first_line)
      return nil unless match

      body, children = split_body(body_lines, subheader)
      new(type: match[2], text: [match[3], *body].join("\n").rstrip, subheader:, children:)
    end

    # Scans arbitrary content for top-level task blocks and parses each one.
    #
    # @param content [String] the content to scan for task blocks
    # @param subheader [String] the subheader to tag each task with
    # @return [Array<Task>] the tasks parsed from the content
    def scan(content, subheader)
      content.scan(BLOCK_REGEX).filter_map { parse(_1, subheader) }
    end

    private

    # Splits a task's body lines into the lines belonging to the task itself and
    # the subtasks nested beneath it. The subtasks are the lines indented the
    # least among the body's task lines; anything above the first of them
    # belongs to the parent, and anything below one belongs to that subtask.
    #
    # @param lines [Array<String>] the body lines, without the task line
    # @param subheader [String] the subheader to tag each subtask with
    # @return [Array(Array<String>, Array<Task>)] the parent's lines and its children
    def split_body(lines, subheader)
      indent = lines.filter_map { indentation(_1) }.min_by(&:length)
      return [lines, []] if indent.nil?

      start = lines.index { indentation(_1) == indent }
      blocks = lines[start..].slice_when { |_, line| indentation(line) == indent }

      [lines.take(start), blocks.filter_map { parse(dedent(_1, indent), subheader) }]
    end

    # @param line [String] the line to inspect
    # @return [String, nil] the line's indentation, or nil when it is not a task
    def indentation(line)
      TASK_REGEX.match(line)&.[](1)
    end

    # @param lines [Array<String>] one subtask's lines, at their original indentation
    # @param indent [String] the indentation the subtask starts at
    # @return [String] the subtask's block, shifted back to column zero
    def dedent(lines, indent)
      lines.join("\n").gsub(/^[ \t]{0,#{indent.length}}/, "")
    end
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
  # of how its body lines may have changed.
  #
  # @return [String]
  def first_line
    text.lines.first&.chomp || text
  end

  # @yieldparam task [Task] the task itself, then each of its descendants
  # @yieldreturn [Boolean] whether the task satisfies the caller
  # @return [Boolean] whether the task or anything beneath it satisfies the block
  def any?(&block)
    block.call(self) || children.any? { _1.any?(&block) }
  end

  # @param other [Task] the task to compare against
  # @return [Boolean] whether both refer to the same task, ignoring their markers,
  #   any differences in body lines, and any emoji decoration
  def matches?(other)
    match_key == other.match_key && subheader == other.subheader
  end

  # Folds another version of this same task into this one, keeping this task's
  # own marker and text and adding only the subtasks it does not already have.
  # Subtasks present in both are merged the same way, recursively.
  #
  # @param other [Task] the other version of this task
  # @return [Task] this task with the other's missing subtasks added
  def merge(other)
    merged = other.children.reduce(children) do |current, child|
      index = current.index { _1.matches?(child) }
      next current + [child] unless index

      current.each_with_index.map { |existing, position| position == index ? existing.merge(child) : existing }
    end

    with(children: merged)
  end

  # Drops the given tasks, and everything beneath them, from the tree.
  #
  # @param tasks [Array<Task>] the tasks to drop
  # @return [Task, nil] the remaining task, or nil when this task was dropped
  def remove(tasks)
    return nil if tasks.include?(self)

    with(children: children.filter_map { _1.remove(tasks) })
  end

  # @return [String] the task rendered as a Markdown list item, with each
  #   subtask indented two spaces beneath it
  def to_markdown
    nested = children.map { _1.to_markdown.gsub(/^(?=.)/, "  ") }
    ["- [#{type}] #{text}", *nested].join("\n")
  end

  protected

  def match_key
    first_line.gsub(/[^[:alnum:]]/, "").downcase
  end
end
