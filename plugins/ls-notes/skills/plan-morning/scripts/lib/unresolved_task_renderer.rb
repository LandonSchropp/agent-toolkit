# frozen_string_literal: true

require_relative "daily_note"

# Renders the scratch file for Step 1 of plan-morning: every recent daily note
# that still holds an unresolved (- [ ]) task, grouped by day and subheader, so
# the user can resolve them in a single editing pass before forwarding. Only
# unresolved tasks appear — forwardable markers (>, <, /) carry forward on their
# own and need no resolution. Operates on DailyNote values; the caller persists
# the result.
class UnresolvedTaskRenderer
  # The file's top-level header.
  HEADER = "# Resolve Tasks"

  # @param daily_notes [Array<DailyNote>] the previous notes, oldest first
  def initialize(daily_notes)
    @daily_notes = daily_notes
  end

  # @return [Boolean] whether no note holds an unresolved task
  def empty?
    notes_to_resolve.empty?
  end

  # @return [String] the header followed by each day that has unresolved tasks,
  #   under a weekday-and-date header with the tasks grouped by subheader
  def to_markdown
    "#{[HEADER, *notes_to_resolve.map { day_section(_1) }].join("\n\n")}\n"
  end

  private

  def notes_to_resolve
    @daily_notes.select(&:incomplete?)
  end

  def day_section(note)
    header = "## #{note.date.strftime('%A, %B %-d, %Y')}"
    [header, *subheader_sections(note)].join("\n\n")
  end

  def subheader_sections(note)
    note.tasks.select(&:incomplete?).group_by(&:subheader).map do |subheader, tasks|
      "### #{subheader}\n\n#{tasks.map(&:to_markdown).join("\n")}"
    end
  end
end
