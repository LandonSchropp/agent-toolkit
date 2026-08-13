# frozen_string_literal: true

require "date"
require_relative "task"
require_relative "markdown"

# An immutable daily note: its file path and raw content. Derives its date and
# its Tasks-section tasks, and returns new notes when tasks are created,
# updated, or deleted. Reading and writing the file live outside this object.
DailyNote = Data.define(:path, :content) do
  # Matches a daily note filename and captures its ISO date prefix.
  DAILY_NOTE_REGEX = /\A(\d{4}-\d{2}-\d{2}) - Daily Note\.md\z/

  # The name and level of the section that holds the note's tasks.
  TASKS_SECTION = "Tasks"
  TASKS_LEVEL = 2

  # The header level of the subheaders (Personal, Work) within the Tasks section.
  SUBHEADER_LEVEL = 3

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

    orphaned_tasks = Task.scan(preamble(body), nil)

    raise "#{File.basename(path, '.md')} has tasks that are not under a subheader." unless orphaned_tasks.empty?

    Markdown.header_names(body, level: SUBHEADER_LEVEL).flat_map do |subheader|
      Task.scan(Markdown.section(body, subheader, SUBHEADER_LEVEL), subheader)
    end
  end

  # @return [Boolean] whether the note has any unresolved (incomplete) task, at
  #   any nesting depth
  def incomplete?
    tasks.any? { _1.any?(&:incomplete?) }
  end

  # Creates whatever the note is missing from the given tasks: a task the note
  # doesn't have is appended under its own subheader, and a task the note
  # already has keeps its own marker and gains only its missing subtasks. Tasks
  # are rendered verbatim, so marker conversion is the caller's responsibility.
  # Creates the subheader at the end of the Tasks section when the note doesn't
  # already have one.
  #
  # @param tasks [Array<Task>] the tasks to create, each carrying its subheader
  # @return [DailyNote] a new note with the tasks created
  def create_tasks(tasks)
    return self if tasks.empty?

    updated_content = tasks.group_by(&:subheader).reduce(content) do |current, (subheader, group)|
      current = add_subheader(current, subheader)
      subsection = Markdown.section(current, subheader, SUBHEADER_LEVEL)
      next current if subsection.nil?

      Markdown.replace_section(current, subheader, SUBHEADER_LEVEL, merge_into(subsection, group, subheader))
    end

    with(content: end_with_newline(updated_content))
  end

  # Deletes the given tasks from the Tasks section. A task is deleted together
  # with everything nested beneath it, and a subtask is deleted without
  # disturbing the rest of its parent's block.
  #
  # @param tasks [Array<Task>] the tasks to delete
  # @return [DailyNote] a new note with the tasks deleted
  def delete_tasks(tasks)
    return self if tasks.empty?

    rewrite_tasks { _1.remove(tasks) }
  end

  # Replaces each of the note's tasks with its matching counterpart from the
  # given tasks, in place. Tasks with no counterpart, and given tasks matching
  # nothing in the note, are left alone.
  #
  # @param tasks [Array<Task>] the replacement tasks, each carrying its subheader
  # @return [DailyNote] a new note with the matching tasks replaced
  def update_tasks(tasks)
    return self if tasks.empty?

    rewrite_tasks { |task| tasks.find { _1.matches?(task) } || task }
  end

  private

  # Runs every top-level task in the Tasks section through a transformation,
  # subheader by subheader, writing the result back into the note.
  #
  # @yieldparam task [Task] each top-level task, carrying its subheader
  # @yieldreturn [Task, nil] the replacement task, or nil to drop it
  # @return [DailyNote] a new note with every task rewritten
  def rewrite_tasks(&block)
    section = tasks_section
    return self if section.nil?

    remaining = Markdown.header_names(section, level: SUBHEADER_LEVEL).reduce(section) do |current, subheader|
      subsection = Markdown.section(current, subheader, SUBHEADER_LEVEL)
      next current if subsection.nil?

      rewritten = rewrite_blocks(subsection, subheader, &block)
      Markdown.replace_section(current, subheader, SUBHEADER_LEVEL, end_with_blank_line(rewritten))
    end

    with(content: end_with_newline(Markdown.replace_section(content, TASKS_SECTION, TASKS_LEVEL, remaining)))
  end

  # @return [String, nil] the body of the note's Tasks section
  def tasks_section
    Markdown.section(content, TASKS_SECTION, TASKS_LEVEL)
  end

  # @param body [String] the body of the Tasks section
  # @return [String] the part of the section preceding its first subheader
  def preamble(body)
    body[/\A.*?(?=^#{"#" * SUBHEADER_LEVEL} |\z)/m]
  end

  # @param subsection [String] the body of a subheader
  # @param tasks [Array<Task>] the tasks to merge into it
  # @param subheader [String] the subheader's name
  # @return [String] the body with the tasks merged in
  def merge_into(subsection, tasks, subheader)
    remaining = tasks.dup

    merged = rewrite_blocks(subsection, subheader) do |task|
      index = remaining.index { task.matches?(_1) }
      index ? task.merge(remaining.delete_at(index)) : task
    end

    merged = "#{merged.rstrip}\n#{remaining.map(&:to_markdown).join("\n")}" unless remaining.empty?
    end_with_blank_line(merged)
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
    subsection.gsub(BLOCK_REGEX) do |block|
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
