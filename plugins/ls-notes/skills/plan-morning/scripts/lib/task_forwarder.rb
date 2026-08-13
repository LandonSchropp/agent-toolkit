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
  #   tasks merged in, plus each source note with its scheduled tasks removed
  # @raise [IncompleteTasksError] when a previous note has an incomplete task
  def forward
    incomplete_daily_notes = @previous_daily_notes.select { |note| candidate_tasks(note).any? { _1.any?(&:incomplete?) } }
    raise IncompleteTasksError, incomplete_daily_notes unless incomplete_daily_notes.empty?

    result = @todays_daily_note.create_tasks(forwarded_tasks)

    [result, *sources_without_forwarded_tasks(result.tasks)]
  end

  # Every forwardable task across the previous notes, as it should appear in
  # today's note. A task appearing on more than one day is forwarded once: the
  # most recent version of it wins, and the older versions contribute any
  # subtasks it no longer lists.
  #
  # @return [Array<Task>] the tasks {#forward} creates in today's note
  def forwarded_tasks
    @previous_daily_notes
      .flat_map { candidate_tasks(_1) }
      .group_by { [_1.subheader, _1.first_line] }
      .values
      .filter_map { carry_forward(_1.reverse.reduce { |newer, older| newer.merge(older) }) }
  end

  private

  # Removes each source note's scheduled tasks, but only the ones that made it
  # into today's note, so that nothing is ever dropped without being written
  # somewhere first.
  #
  # @param present_tasks [Array<Task>] today's top-level tasks
  # @return [Array<DailyNote>] the source notes that changed
  def sources_without_forwarded_tasks(present_tasks)
    @previous_daily_notes.filter_map do |note|
      removable_tasks = candidate_tasks(note).flat_map { removable(_1, present_tasks) }
      note.delete_tasks(removable_tasks) unless removable_tasks.empty?
    end
  end

  # @param task [Task] the task to inspect, along with everything beneath it
  # @param present_tasks [Array<Task>] today's top-level tasks
  # @return [Array<Task>] the tasks whose source copy can be dropped
  def removable(task, present_tasks)
    return [task] if task.scheduled? && present_tasks.any? { |present| present.any? { _1.matches?(task) } }

    task.children.flat_map { removable(_1, present_tasks) }
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

  # Carries a task into today's note, keeping only the branches that still have
  # work in them. Scheduled tasks keep their marker so they keep rolling;
  # everything else becomes a fresh to-do, including a resolved task that has to
  # come along as a container for a forwardable subtask.
  #
  # @param task [Task] the task to carry forward
  # @return [Task, nil] the task as it should appear in today's note, or nil
  #   when neither it nor anything beneath it is forwardable
  def carry_forward(task)
    children = task.children.filter_map { carry_forward(_1) }
    return nil unless task.forwardable? || children.any?

    task.with(type: task.scheduled? ? task.type : " ", children:)
  end
end
