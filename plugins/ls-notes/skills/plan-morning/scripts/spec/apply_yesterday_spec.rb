# frozen_string_literal: true

require "date"
require_relative "../lib/vault"
require_relative "../lib/daily_note"

RSpec.describe "apply-yesterday" do
  # Loads the script as a one-shot in this process so RSpec stubs apply.
  def run_script
    load File.expand_path("../apply-yesterday.rb", __dir__)
  end

  # Undefines the constants the script sets, so reloading it doesn't warn.
  after { Object.send(:remove_const, :SCRATCH_PATH) if Object.const_defined?(:SCRATCH_PATH) }

  # A date in the past, so the real scratch file these write can't collide with
  # a plan-morning run happening today.
  let(:date) { Date.new(2026, 1, 2) }
  let(:scratch_path) { "/tmp/plan-morning-2026-01-02-yesterday.md" }

  let(:vault) { instance_double(Vault) }

  # The notes the script wrote back, in the order it wrote them.
  let(:written_notes) { [] }

  let(:yesterdays_note) do
    DailyNote.new(path: "2026-01-01 - Daily Note.md", content: <<~MARKDOWN)
      ## Tasks

      ### Personal

      - [ ] Kept task
      - [ ] Deleted task
      - [x] Done task
    MARKDOWN
  end

  let(:scratch_content) do
    <<~MARKDOWN
      # Previous Daily Notes

      ## Thursday, January 1, 2026 (Yesterday)

      ### Tasks

      #### Personal

      - [x] Kept task
      - [ ] Added task
    MARKDOWN
  end

  let(:previous_daily_notes) { [yesterdays_note] }

  before do
    allow(Date).to receive(:today).and_return(date)
    File.write(scratch_path, scratch_content)

    allow(Vault).to receive(:new).and_return(vault)
    allow(vault).to receive(:previous_daily_notes).and_return(previous_daily_notes)
    allow(vault).to receive(:write) { |note| written_notes << note }
  end

  after { File.delete(scratch_path) if File.exist?(scratch_path) }

  it "updates a task whose marker the user changed" do
    run_script
    expect(written_notes.first.content).to include("- [x] Kept task")
  end

  it "deletes a task the user removed from the file" do
    run_script
    expect(written_notes.first.content).not_to include("Deleted task")
  end

  it "creates a task the user added to the file" do
    run_script
    expect(written_notes.first.content).to include("- [ ] Added task")
  end

  it "leaves a resolved task the file never mentions alone" do
    run_script
    expect(written_notes.first.content).to include("- [x] Done task")
  end

  context "when a note's day the file doesn't cover" do
    let(:previous_daily_notes) { [yesterdays_note, DailyNote.new(path: "2025-12-30 - Daily Note.md", content: <<~MARKDOWN)] }
      ## Tasks

      ### Personal

      - [ ] Untouched task
    MARKDOWN

    it "writes only the covered note" do
      run_script
      expect(written_notes.map(&:path)).to eq(["2026-01-01 - Daily Note.md"])
    end
  end

  context "when the file leaves the note unchanged" do
    let(:scratch_content) do
      <<~MARKDOWN
        # Previous Daily Notes

        ## Thursday, January 1, 2026 (Yesterday)

        ### Tasks

        #### Personal

        - [ ] Kept task
        - [ ] Deleted task
      MARKDOWN
    end

    it "does not write the note" do
      run_script
      expect(written_notes).to be_empty
    end
  end

  context "when the scratch file is missing" do
    before { File.delete(scratch_path) }

    it "raises rather than reporting success, so the pass stops here" do
      expect { run_script }.to raise_error(Errno::ENOENT)
    end
  end
end
