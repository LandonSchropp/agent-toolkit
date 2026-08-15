# frozen_string_literal: true

require "date"
require_relative "../lib/vault"
require_relative "../lib/daily_note"

RSpec.describe "resolve-tasks" do
  # Loads the script as a one-shot in this process so RSpec stubs apply.
  def run_script
    load File.expand_path("../resolve-tasks.rb", __dir__)
  end

  # Undefines the constants the script sets, so reloading it doesn't warn.
  after { Object.send(:remove_const, :SCRATCH_PATH) if Object.const_defined?(:SCRATCH_PATH) }

  # A date in the past, so the real scratch file these write can't collide with
  # a plan-morning run happening today.
  let(:date) { Date.new(2026, 1, 2) }
  let(:scratch_path) { "/tmp/plan-morning-2026-01-02-yesterday.md" }

  let(:vault) { instance_double(Vault) }

  let(:yesterdays_note) do
    DailyNote.new(path: "2026-01-01 - Daily Note.md", content: <<~MARKDOWN)
      ## Tasks

      ### Personal

      - [ ] Unresolved task
      - [x] Done task
    MARKDOWN
  end

  let(:previous_daily_notes) { [yesterdays_note] }

  before do
    allow(Date).to receive(:today).and_return(date)
    allow(Vault).to receive(:new).and_return(vault)
    allow(vault).to receive(:previous_daily_notes).and_return(previous_daily_notes)
  end

  after { File.delete(scratch_path) if File.exist?(scratch_path) }

  it "writes the unresolved tasks to the Yesterday scratch path" do
    expect { run_script }.to output.to_stdout
    expect(File.read(scratch_path)).to include("- [ ] Unresolved task")
  end

  it "leaves out the tasks that are already resolved" do
    expect { run_script }.to output.to_stdout
    expect(File.read(scratch_path)).not_to include("Done task")
  end

  it "groups the tasks under their day" do
    expect { run_script }.to output.to_stdout
    expect(File.read(scratch_path)).to include("## Thursday, January 1, 2026 (Yesterday)")
  end

  context "when no unresolved tasks remain" do
    let(:previous_daily_notes) do
      [DailyNote.new(path: "2026-01-01 - Daily Note.md", content: "## Tasks\n\n### Personal\n\n- [x] Done task\n")]
    end

    it "writes no file" do
      expect { run_script }.to output.to_stdout
      expect(File.exist?(scratch_path)).to be(false)
    end

    it "reports that nothing needs resolving" do
      expect { run_script }.to output(/No unresolved tasks/).to_stdout
    end
  end
end
