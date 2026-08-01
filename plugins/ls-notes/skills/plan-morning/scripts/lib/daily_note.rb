# frozen_string_literal: true

require "date"
require_relative "task"
require_relative "markdown"

# An immutable daily note: its file path and raw content. Derives its date and
# its Tasks-section tasks, and returns new notes when tasks are added or removed.
# Reading and writing the file live outside this object.
DailyNote = Data.define(:path, :content) do
  # Matches a daily note filename and captures its ISO date prefix.
  DAILY_NOTE_REGEX = /\A(\d{4}-\d{2}-\d{2}) - Daily Note\.md\z/

  # The name and level of the section that holds the note's tasks.
  TASKS_SECTION = "Tasks"
  TASKS_LEVEL = 2

  # The header level of the subheaders (Personal, Work) within the Tasks section.
  SUBHEADER_LEVEL = 3

  # Matches a complete task block: a top-level task line, any body content
  # (indented lines and blank separators between them) up to but not including
  # the next top-level task line or a header line (so nested sub-subheaders are
  # not absorbed into the preceding task's body), and the newline that ends it.
  # Consuming that newline keeps blank-line separators intact when a block is
  # rewritten or dropped.
  TASK_BLOCK_REGEX = /^(?:[-+*]|\d+\.) \[.\] [^\n]+(?:\n(?!(?:[-+*]|\d+\.) \[|#)[^\n]*)*\n?/

  # @return [Date, nil] the date parsed from the filename, or nil when the file
  #   is not a daily note
  def date
    match = File.basename(path).match(DAILY_NOTE_REGEX)
    match && Date.iso8601(match[1])
  end

  # @return [Array<Task>] the top-level tasks within the note's Tasks section,
  #   each tagged with the subheader (Personal, Work, ...) it falls under and
  #   carrying its subtasks as children
  # @raise [RuntimeError] when a task precedes the first subheader
  def tasks
    body = tasks_section
    return [] unless body

    orphaned_tasks = parse_tasks(preamble(body), nil)

    raise "#{File.basename(path, '.md')} has tasks that are not under a subheader." unless orphaned_tasks.empty?

    Markdown.header_names(body, level: SUBHEADER_LEVEL).flat_map do |subheader|
      parse_tasks(Markdown.section(body, subheader, SUBHEADER_LEVEL), subheader)
    end
  end

  # @return [Boolean] whether the note has any unresolved (incomplete) task
  def incomplete?
    tasks.any?(&:incomplete?)
  end

  # Appends each task to the end of its own subheader's subsection within the
  # Tasks section. Tasks are rendered verbatim, so marker conversion and
  # de-duplication are the caller's responsibility. Creates the subheader at
  # the end of the Tasks section when the note doesn't already have one.
  #
  # @param tasks [Array<Task>] the tasks to append, each carrying its subheader
  # @return [DailyNote] a new note with the tasks appended
  def append_tasks(tasks)
    return self if tasks.empty?

    updated_content = tasks.group_by(&:subheader).reduce(content) do |current, (subheader, group)|
      current = add_subheader(current, subheader)
      subsection = Markdown.section(current, subheader, SUBHEADER_LEVEL)
      next current if subsection.nil?

      addition = group.map(&:to_markdown).join("\n")
      appended = end_with_blank_line("#{subsection.rstrip}\n#{addition}")
      Markdown.replace_section(current, subheader, SUBHEADER_LEVEL, appended)
    end

    with(content: end_with_newline(updated_content))
  end

  # Removes the given tasks from the Tasks section. A task is removed together
  # with everything nested beneath it, and a subtask is removed without
  # disturbing the rest of its parent's block.
  #
  # @param tasks [Array<Task>] the tasks to remove
  # @return [DailyNote] a new note with the tasks removed
  def remove_tasks(tasks)
    section = tasks_section
    return self if tasks.empty? || section.nil?

    remaining = Markdown.header_names(section, level: SUBHEADER_LEVEL).reduce(section) do |current, subheader|
      subsection = Markdown.section(current, subheader, SUBHEADER_LEVEL)
      next current if subsection.nil?

      removed = rewrite_blocks(subsection, subheader) { _1.remove(tasks) }
      Markdown.replace_section(current, subheader, SUBHEADER_LEVEL, end_with_blank_line(removed))
    end

    with(content: end_with_newline(Markdown.replace_section(content, TASKS_SECTION, TASKS_LEVEL, remaining)))
  end

  private

  # @return [String, nil] the body of the note's Tasks section
  def tasks_section
    Markdown.section(content, TASKS_SECTION, TASKS_LEVEL)
  end

  # @param body [String] the body of the Tasks section
  # @return [String] the part of the section preceding its first subheader
  def preamble(body)
    body[/\A.*?(?=^#{"#" * SUBHEADER_LEVEL} |\z)/m]
  end

  # @param content [String] the content to scan for task blocks
  # @param subheader [String] the subheader to tag each task with
  # @return [Array<Task>] the tasks parsed from the content
  def parse_tasks(content, subheader)
    content.scan(TASK_BLOCK_REGEX).filter_map { Task.parse(_1, subheader) }
  end

  # Runs each of a subsection's task blocks through a transformation, leaving
  # the block's original text alone when the transformation is a no-op so that
  # untouched blocks keep their exact formatting.
  #
  # @param subsection [String] the body of a subheader
  # @param subheader [String] the subheader's name
  # @yieldparam task [Task] the task parsed from a block
  # @yieldreturn [Task, nil] the replacement task, or nil to drop the block
  # @return [String] the body with every block rewritten
  def rewrite_blocks(subsection, subheader)
    subsection.gsub(TASK_BLOCK_REGEX) do |block|
      task = Task.parse(block, subheader)
      next block unless task

      updated = yield(task)
      next "" if updated.nil?

      updated == task ? block : "#{updated.to_markdown}#{block[/\n*\z/]}"
    end
  end

  # Gives a subheader body exactly one blank line between its tasks and whatever
  # follows the subheader, since dropping the last task block takes that
  # separator with it.
  #
  # @param subsection [String] the body of a subheader
  # @return [String] the body to write back
  def end_with_blank_line(subsection)
    subsection.rstrip.empty? ? "\n" : "#{subsection.rstrip}\n\n"
  end

  # Adds a new, empty subheader at the end of the Tasks section when the note
  # doesn't already have one with the given name. Does nothing when the note
  # has no Tasks section to add it to, or when the subheader already exists.
  #
  # @param content [String] the note content to add the subheader to
  # @param subheader [String] the subheader name to ensure exists
  # @return [String] the content, with the subheader added if it was missing
  def add_subheader(content, subheader)
    return content if Markdown.section(content, subheader, SUBHEADER_LEVEL)

    body = Markdown.section(content, TASKS_SECTION, TASKS_LEVEL)
    return content unless body

    updated_body = "#{body.chomp}\n\n#{"#" * SUBHEADER_LEVEL} #{subheader}\n\n"
    Markdown.replace_section(content, TASKS_SECTION, TASKS_LEVEL, updated_body)
  end

  # @param content [String] the note content
  # @return [String] the content ending in exactly one newline, so that a
  #   rewritten trailing section doesn't leave a blank line at the end of file
  def end_with_newline(content)
    content.sub(/\n*\z/, "\n")
  end
end
