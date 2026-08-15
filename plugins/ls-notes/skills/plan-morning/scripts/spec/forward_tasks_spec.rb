# frozen_string_literal: true

require "date"
require_relative "../lib/vault"
require_relative "../lib/daily_note"

RSpec.describe "forward-tasks" do
  # Loads the script as a one-shot in this process so RSpec stubs apply.
  # Returns the status the script exited with, or 0 when it ran clean.
  def run_script
    load File.expand_path("../forward-tasks.rb", __dir__)
    0
  rescue SystemExit => system_exit
    system_exit.status
  end

  # Undefines the constants the script sets, so reloading it doesn't warn.
  after { Object.send(:remove_const, :SCRATCH_PATH) if Object.const_defined?(:SCRATCH_PATH) }

  # A date in the past, so the real scratch file these write can't collide with
  # a plan-morning run happening today.
  let(:date) { Date.new(2026, 1, 2) }
  let(:scratch_path) { "/tmp/plan-morning-2026-01-02-today.md" }

  let(:vault) { instance_double(Vault) }

  # The notes the script wrote back, in the order it wrote them.
  let(:written_notes) { [] }

  let(:todays_note) do
    DailyNote.new(path: "2026-01-02 - Daily Note.md", content: "## Tasks\n\n### Personal\n\n### Work\n\n")
  end

  let(:yesterdays_note) do
    DailyNote.new(path: "2026-01-01 - Daily Note.md", content: <<~MARKDOWN)
      ## Tasks

      ### Personal

      - [>] Forward me
      - [<] Roll me forward
      - [x] Done

      ### Work
    MARKDOWN
  end

  let(:scratch_content) { "## Tasks\n\n### Personal\n\n### Work\n\n" }

  before do
    allow(Date).to receive(:today).and_return(date)
    File.write(scratch_path, scratch_content)

    allow(Vault).to receive(:new).and_return(vault)
    allow(vault).to receive(:find_or_create_todays_daily_note).and_return(todays_note)
    allow(vault).to receive(:previous_daily_notes).and_return([yesterdays_note])
    allow(vault).to receive(:write) { |note| written_notes << note }
  end

  after { File.delete(scratch_path) if File.exist?(scratch_path) }

  def written(path) = written_notes.find { _1.path == path }

  it "forwards a forwarded task into today's note as a to-do" do
    run_script
    expect(written("2026-01-02 - Daily Note.md").content).to include("- [ ] Forward me")
  end

  it "forwards a scheduled task into today's note, keeping its marker" do
    run_script
    expect(written("2026-01-02 - Daily Note.md").content).to include("- [<] Roll me forward")
  end

  it "leaves a completed task behind" do
    run_script
    expect(written("2026-01-02 - Daily Note.md").content).not_to include("Done")
  end

  it "removes the scheduled task from its source note" do
    run_script
    expect(written("2026-01-01 - Daily Note.md").content).not_to include("Roll me forward")
  end

  it "writes the forwarded tasks into the scratch file on disk" do
    run_script
    expect(File.read(scratch_path)).to include("- [ ] Forward me").and include("- [<] Roll me forward")
  end

  context "when a previous note still holds an unresolved task" do
    let(:yesterdays_note) do
      DailyNote.new(path: "2026-01-01 - Daily Note.md", content: "## Tasks\n\n### Personal\n\n- [ ] Unresolved\n")
    end

    it "exits 1 and names the note on stderr" do
      exit_code = nil
      expect { exit_code = run_script }.to output(/2026-01-01 - Daily Note/).to_stderr
      expect(exit_code).to eq(1)
    end

    it "leaves the scratch file alone" do
      expect { run_script }.to output.to_stderr
      expect(File.read(scratch_path)).to eq(scratch_content)
    end
  end

  context "when the scratch file is missing" do
    before { File.delete(scratch_path) }

    it "fails before writing any note, so a bad path can't half-apply the pass" do
      expect { run_script }.to raise_error(Errno::ENOENT)
      expect(written_notes).to be_empty
    end
  end
end
