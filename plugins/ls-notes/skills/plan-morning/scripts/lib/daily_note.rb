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

  # Matches a complete task block: a top-level task line followed by any body
  # content (indented lines and blank separators between them) up to but not
  # including the next top-level task line or a header line (so nested
  # sub-subheaders are not absorbed into the preceding task's body).
  TASK_BLOCK_REGEX = /^(?:[-+*]|\d+\.) \[.\] [^\n]+(?:\n(?!(?:[-+*]|\d+\.) \[|#)[^\n]*)*/

  # @return [Date, nil] the date parsed from the filename, or nil when the file
  #   is not a daily note
  def date
    match = File.basename(path).match(DAILY_NOTE_REGEX)
    match && Date.iso8601(match[1])
  end

  # @return [Array<Task>] the tasks within the note's Tasks section, each tagged
  #   with the subheader (Personal, Work, ...) it falls under
  def tasks
    body = tasks_section
    return [] unless body

    Markdown.header_names(body, level: SUBHEADER_LEVEL).flat_map do |subheader|
      Markdown.section(body, subheader, SUBHEADER_LEVEL)
        .scan(TASK_BLOCK_REGEX)
        .filter_map { Task.parse(_1, subheader) }
    end
  end

  # @return [Boolean] whether the note has any unresolved (incomplete) task
  def incomplete?
    tasks.any?(&:incomplete?)
  end

  # Appends each task to the end of its own subheader's subsection within the
  # Tasks section. Tasks are rendered verbatim, so marker conversion and
  # de-duplication are the caller's responsibility. Each subheader is assumed to
  # exist; the caller skips notes that lack one.
  #
  # @param tasks [Array<Task>] the tasks to append, each carrying its subheader
  # @return [DailyNote] a new note with the tasks appended
  def append_tasks(tasks)
    return self if tasks.empty?

    updated_content = tasks.group_by(&:subheader).reduce(content) do |current, (subheader, group)|
      subsection = Markdown.section(current, subheader, SUBHEADER_LEVEL)
      next current if subsection.nil?

      addition = group.map(&:to_markdown).join("\n")
      appended = subsection.sub(/\n*\z/) { "\n#{addition}#{_1}" }
      Markdown.replace_section(current, subheader, SUBHEADER_LEVEL, appended)
    end

    with(content: updated_content)
  end

  # Removes the given tasks from the Tasks section, matching each task's full
  # rendered block (including any indented body lines) so that sub-task content
  # is removed together with its parent.
  #
  # @param tasks [Array<Task>] the tasks to remove
  # @return [DailyNote] a new note with the tasks removed
  def remove_tasks(tasks)
    section = tasks_section
    return self if tasks.empty? || section.nil?

    remaining = tasks.reduce(section) do |current, task|
      current.sub(/#{Regexp.escape(task.to_markdown)}\n?/, "")
    end

    with(content: Markdown.replace_section(content, TASKS_SECTION, TASKS_LEVEL, remaining))
  end

  private

  # @return [String, nil] the body of the note's Tasks section
  def tasks_section
    Markdown.section(content, TASKS_SECTION, TASKS_LEVEL)
  end
end
