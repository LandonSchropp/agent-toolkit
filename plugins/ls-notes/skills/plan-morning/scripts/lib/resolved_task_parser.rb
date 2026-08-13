# frozen_string_literal: true

require "date"
require_relative "markdown"
require_relative "task"

# Parses plan-morning's edited Yesterday scratch file back into each day's
# edited tasks. Sections other than a day's Tasks section are ignored.
class ResolvedTaskParser
  # @param content [String] the scratch file's content
  def initialize(content)
    @content = content
  end

  # @param date [Date] the day to look up
  # @return [Boolean] whether the file has a section for the day
  def covers?(date)
    tasks_by_date.key?(date)
  end

  # @param date [Date] the day to look up
  # @return [Array<Task>] the day's edited tasks, empty when the file doesn't
  #   cover the day
  def tasks(date)
    tasks_by_date.fetch(date, [])
  end

  private

  def tasks_by_date
    @tasks_by_date ||= Markdown.header_names(@content, level: 2).to_h { [Date.parse(_1), day_tasks(_1)] }
  end

  def day_tasks(header)
    day_body = Markdown.section(@content, header, 2)
    tasks_body = Markdown.section(day_body, "Tasks", 3)
    return [] unless tasks_body

    Markdown.header_names(tasks_body, level: 4).flat_map do |subheader|
      Task.scan(Markdown.section(tasks_body, subheader, 4), subheader)
    end
  end
end
