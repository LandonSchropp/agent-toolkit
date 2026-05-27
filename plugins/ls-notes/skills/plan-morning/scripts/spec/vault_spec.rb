# frozen_string_literal: true

require "open3"
require_relative "../lib/vault"

RSpec.describe Vault do
  subject(:vault) { Vault.new }

  def capture_stub(content)
    [content, nil]
  end

  describe "#find_or_create_todays_daily_note" do
    before do
      allow(Open3).to receive(:capture2).with("obsidian", "daily:read")
        .and_return(capture_stub("today's content\n"))
      allow(Open3).to receive(:capture2).with("obsidian", "daily:path")
        .and_return(capture_stub("Daily Notes/2026/2026-05/2026-05-27 - Daily Note.md\n"))
    end

    it "reads today's content" do
      expect(vault.find_or_create_todays_daily_note.content).to eq("today's content\n")
    end

    it "reads today's path" do
      expect(vault.find_or_create_todays_daily_note.path)
        .to eq("Daily Notes/2026/2026-05/2026-05-27 - Daily Note.md")
    end
  end

  describe "#previous_daily_notes" do
    let(:listing) do
      <<~FILES
        Daily Notes/2026/2026-05/2026-05-15 - Daily Note.md
        Daily Notes/2026/2026-05/2026-05-22 - Daily Note.md
        Daily Notes/2026/2026-05/2026-05-26 - Daily Note.md
        Daily Notes/2026/2026-05/2026-05-27 - Daily Note.md
        Daily Notes/Daily Notes.base
      FILES
    end

    before do
      allow(Date).to receive(:today).and_return(Date.new(2026, 5, 27))
      allow(Open3).to receive(:capture2).with("obsidian", "files", "folder=Daily Notes")
        .and_return(capture_stub(listing))
      allow(Open3).to receive(:capture2).with("obsidian", "read", anything) do |*arguments|
        capture_stub("body of #{arguments.last.delete_prefix('path=')}")
      end
    end

    it "returns the notes before today, oldest first" do
      expect(vault.previous_daily_notes.map { File.basename(_1.path) })
        .to eq(["2026-05-15 - Daily Note.md", "2026-05-22 - Daily Note.md", "2026-05-26 - Daily Note.md"])
    end

    it "caps at the requested count, keeping the most recent" do
      expect(vault.previous_daily_notes(2).map { File.basename(_1.path) })
        .to eq(["2026-05-22 - Daily Note.md", "2026-05-26 - Daily Note.md"])
    end

    it "reads each note's content" do
      expect(vault.previous_daily_notes(1).first.content)
        .to eq("body of Daily Notes/2026/2026-05/2026-05-26 - Daily Note.md")
    end
  end

  describe "#write" do
    subject(:note) { DailyNote.new(path: "Daily Notes/2026/2026-05/2026-05-27 - Daily Note.md", content: "updated") }

    it "replaces the note's content through obsidian" do
      expect(vault).to receive(:system)
        .with("obsidian", "create", "path=#{note.path}", "content=updated", "overwrite")
      vault.write(note)
    end
  end
end
