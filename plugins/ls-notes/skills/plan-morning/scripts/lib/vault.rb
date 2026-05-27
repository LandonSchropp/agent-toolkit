# frozen_string_literal: true

require "date"
require "open3"
require_relative "daily_note"

# The Obsidian vault, accessed through the `obsidian` CLI so that notes open in
# the app are read and written through Obsidian rather than behind its back.
class Vault
  # Matches a daily note's filename.
  DAILY_NOTE_FILENAME = /\d{4}-\d{2}-\d{2} - Daily Note\.md\z/

  # The number of previous daily notes to read by default.
  DEFAULT_PREVIOUS_COUNT = 7

  # Reads today's daily note, creating it from the template when it does not yet
  # exist — which is why this goes through `daily:read`.
  #
  # @return [DailyNote] today's daily note
  def find_or_create_todays_daily_note
    DailyNote.new(path: obsidian("daily:path").strip, content: obsidian("daily:read"))
  end

  # Reads the most recent daily notes before today, oldest first. Paths are
  # sorted and capped before any content is read.
  #
  # @param count [Integer] the maximum number of notes to read
  # @return [Array<DailyNote>] the previous daily notes, in chronological order
  def previous_daily_notes(count = DEFAULT_PREVIOUS_COUNT)
    today = Date.today.iso8601

    daily_note_paths
      .select { File.basename(_1) < today }
      .last(count)
      .map { read(_1) }
  end

  # Replaces a note's content through Obsidian.
  #
  # @param note [DailyNote] the note to persist
  # @return [void]
  def write(note)
    system("obsidian", "create", "path=#{note.path}", "content=#{note.content}", "overwrite")
  end

  private

  # @return [Array<String>] every daily note path in the vault, sorted ascending
  def daily_note_paths
    obsidian("files", "folder=Daily Notes").lines(chomp: true).grep(DAILY_NOTE_FILENAME).sort
  end

  # @param path [String] the vault-relative path to read
  # @return [DailyNote] the note at the path
  def read(path)
    DailyNote.new(path:, content: obsidian("read", "path=#{path}"))
  end

  # Runs an obsidian command and returns its stdout.
  #
  # @param arguments [Array<String>] the command name and its arguments
  # @return [String] the command's stdout
  def obsidian(*arguments)
    Open3.capture2("obsidian", *arguments).first
  end
end
