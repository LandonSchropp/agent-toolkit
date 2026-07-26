# frozen_string_literal: true

require_relative "task"

# Forwards tasks from previous daily notes into today's note. Forwarded and
# partial tasks become to-dos; scheduled tasks keep their marker and are removed
# from their source. Work tasks stay put on weekends. Operates on DailyNote
# values — the caller persists the result.
class TaskForwarder
  # The subheader whose tasks are left alone when today is a weekend.
  WORK_SUBHEADER = "Work"

  # Raised when a previous note still holds an incomplete task, which must be
  # resolved before forwarding can proceed. Carries the offending notes.
  class IncompleteTasksError < StandardError
    # @param notes [Array<DailyNote>] the notes with incomplete tasks
    def initialize(notes)
      super(<<~MESSAGE.chomp)
        The following notes contain incomplete tasks. Every task must be resolved before tasks can be forwarded:

        #{notes.map { "- #{File.basename(_1.path, '.md')}" }.join("\n")}
      MESSAGE
    end
  end

  # @param todays_daily_note [DailyNote] today's daily note
  # @param previous_daily_notes [Array<DailyNote>] the notes to forward from
  def initialize(todays_daily_note, previous_daily_notes)
    @todays_daily_note = todays_daily_note
    @previous_daily_notes = previous_daily_notes
  end

  # @return [Array<DailyNote>] the notes to persist: today with the forwarded
  #   tasks appended, plus each source note with its scheduled tasks removed
  # @raise [IncompleteTasksError] when a previous note has an incomplete task
  def forward
    incomplete_daily_notes = @previous_daily_notes.select { candidate_tasks(_1).any?(&:incomplete?) }
    raise IncompleteTasksError, incomplete_daily_notes unless incomplete_daily_notes.empty?

    [@todays_daily_note.append_tasks(tasks_to_forward), *sources_without_scheduled_tasks]
  end

  private

  def tasks_to_forward
    present_tasks = @todays_daily_note.tasks

    forwarded_tasks.reduce([]) do |accumulator, task|
      (present_tasks + accumulator).any? { _1.matches?(task) } ? accumulator : accumulator + [task]
    end
  end

  def forwarded_tasks
    @previous_daily_notes
      .flat_map { candidate_tasks(_1) }
      .reduce({}) { |registry, task| registry.merge([task.subheader, task.first_line] => task) }
      .values
      .select(&:forwardable?)
      .map { carry_forward(_1) }
  end

  def sources_without_scheduled_tasks
    @previous_daily_notes.filter_map do |note|
      scheduled_tasks = candidate_tasks(note).select(&:scheduled?)
      note.remove_tasks(scheduled_tasks) unless scheduled_tasks.empty?
    end
  end

  # @param note [DailyNote] the note to take tasks from
  # @return [Array<Task>] the note's tasks that today is eligible to take
  def candidate_tasks(note)
    weekend? ? note.tasks.reject { _1.subheader == WORK_SUBHEADER } : note.tasks
  end

  # @return [Boolean] whether today's note falls on a Saturday or Sunday
  def weekend?
    date = @todays_daily_note.date
    return false unless date

    date.saturday? || date.sunday?
  end

  # Carries a task into today's note: scheduled tasks keep their marker so they
  # keep rolling; everything else becomes a fresh to-do.
  #
  # @param task [Task] the task to carry forward
  # @return [Task] the task as it should appear in today's note
  def carry_forward(task)
    task.scheduled? ? task : task.with(type: " ")
  end
end
