# frozen_string_literal: true

require_relative "daily_note"

# Renders plan-morning's Yesterday scratch file: every recent daily note
# that still holds an unresolved (- [ ]) task, grouped by day and subheader, so
# the user can resolve them in a single editing pass before forwarding. Only
# unresolved tasks appear — forwardable markers (>, <, /) carry forward on their
# own and need no resolution. Operates on DailyNote values; the caller persists
# the result.
class UnresolvedTaskRenderer
  TITLE = "# Previous Daily Notes"

  TASKS_SECTION = "### Tasks\n\n" \
                 "_These tasks were left unresolved. Mark each one with what happened to it._"

  # @param daily_notes [Array<DailyNote>] the previous notes, oldest first
  def initialize(daily_notes)
    @daily_notes = daily_notes
  end

  # @return [Boolean] whether no note holds an unresolved task
  def empty?
    notes_to_resolve.empty?
  end

  # @return [String] the title followed by each day that has unresolved tasks,
  #   under a weekday-and-date header with the tasks grouped by subheader
  def to_markdown
    "#{[TITLE, *notes_to_resolve.map { day_section(_1) }].join("\n\n")}\n"
  end

  private

  def notes_to_resolve
    @daily_notes.select(&:incomplete?)
  end

  def day_section(note)
    header = "## #{note.date.strftime('%A, %B %-d, %Y')}"
    [header, TASKS_SECTION, *subheader_sections(note)].join("\n\n")
  end

  # Keeps each task block holding an unresolved to-do, whole, so that a nested
  # to-do arrives with its parent for context and nothing the user might edit is
  # missing from the file.
  def subheader_sections(note)
    note.tasks.select { _1.any?(&:incomplete?) }.group_by(&:subheader).map do |subheader, tasks|
      "#### #{subheader}\n\n#{tasks.map(&:to_markdown).join("\n")}"
    end
  end
end
