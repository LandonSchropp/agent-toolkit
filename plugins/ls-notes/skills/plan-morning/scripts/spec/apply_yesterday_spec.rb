# frozen_string_literal: true

require_relative "../lib/vault"
require_relative "../lib/resolved_task_parser"

RSpec.describe "apply-yesterday" do
  # Loads the script as a one-shot in this process so RSpec stubs apply.
  # SystemExit raised by exit(...) inside the script is rescued and its status
  # returned; a clean run returns 0. ARGV is stubbed for the example so the
  # script sees the test args without mutating the real ARGV.
  def run_script(*arguments)
    stub_const("ARGV", arguments)
    load File.expand_path("../apply-yesterday.rb", __dir__)
    0
  rescue SystemExit => system_exit
    system_exit.status
  end

  describe "with no scratch file argument" do
    it "prints the usage to stderr and exits 1" do
      exit_code = nil
      expect { exit_code = run_script }.to output(/Usage: apply-yesterday/).to_stderr
      expect(exit_code).to eq(1)
    end
  end

  describe "with a scratch file path" do
    let(:scratch_path) { "/tmp/plan-morning-yesterday-2026-01-02.md" }
    let(:vault) { instance_double(Vault) }
    let(:kept_task) { Task.parse("- [ ] Kept task", "Personal") }
    let(:deleted_task) { Task.parse("- [ ] Deleted task", "Personal") }
    let(:done_task) { Task.parse("- [x] Done task", "Personal") }
    let(:created_task) { Task.parse("- [ ] Added task", "Personal") }
    let(:edited_tasks) { [Task.parse("- [x] Kept task", "Personal"), created_task] }
    let(:matching_note) do
      instance_double(DailyNote, date: Date.new(2026, 1, 1), tasks: [kept_task, deleted_task, done_task])
    end
    let(:other_note) { instance_double(DailyNote, date: Date.new(2026, 1, 2), tasks: [kept_task]) }
    let(:created_note) { instance_double(DailyNote) }
    let(:updated_note) { instance_double(DailyNote) }
    let(:final_note) { instance_double(DailyNote) }

    before do
      allow(File).to receive(:read).with(scratch_path).and_return("scratch file content")
      parser = instance_double(ResolvedTaskParser)
      allow(parser).to receive(:covers?).and_return(false)
      allow(parser).to receive(:covers?).with(Date.new(2026, 1, 1)).and_return(true)
      allow(parser).to receive(:tasks).with(Date.new(2026, 1, 1)).and_return(edited_tasks)
      allow(ResolvedTaskParser).to receive(:new).with("scratch file content").and_return(parser)
      allow(Vault).to receive(:new).and_return(vault)
      allow(vault).to receive(:previous_daily_notes).and_return([matching_note, other_note])
      allow(matching_note).to receive(:create_tasks).and_return(created_note)
      allow(created_note).to receive(:update_tasks).with(edited_tasks).and_return(updated_note)
      allow(updated_note).to receive(:delete_tasks).and_return(final_note)
      allow(vault).to receive(:write)
    end

    it "creates the tasks the note doesn't have" do
      run_script(scratch_path)
      expect(matching_note).to have_received(:create_tasks).with([created_task])
    end

    it "updates the note's tasks with the edited versions" do
      run_script(scratch_path)
      expect(created_note).to have_received(:update_tasks).with(edited_tasks)
    end

    it "deletes the incomplete tasks the user removed from the file" do
      run_script(scratch_path)
      expect(updated_note).to have_received(:delete_tasks).with([deleted_task])
    end

    it "writes the note back through the vault" do
      run_script(scratch_path)
      expect(vault).to have_received(:write).with(final_note)
    end

    it "leaves a note whose day the file does not cover alone, even with incomplete tasks" do
      run_script(scratch_path)
      expect(vault).to have_received(:write).once.with(final_note)
    end

    it "exits 0" do
      expect(run_script(scratch_path)).to eq(0)
    end

    context "when a covered note comes back unchanged" do
      before do
        allow(matching_note).to receive(:create_tasks).and_return(matching_note)
        allow(matching_note).to receive(:update_tasks).and_return(matching_note)
        allow(matching_note).to receive(:delete_tasks).and_return(matching_note)
      end

      it "does not write the note" do
        run_script(scratch_path)
        expect(vault).not_to have_received(:write)
      end
    end

    context "when the user deleted every task for a day" do
      let(:edited_tasks) { [] }

      before { allow(created_note).to receive(:update_tasks).with([]).and_return(updated_note) }

      it "deletes every incomplete task" do
        run_script(scratch_path)
        expect(updated_note).to have_received(:delete_tasks).with([kept_task, deleted_task])
      end
    end
  end

  describe "with a real note and scratch file" do
    let(:scratch_path) { "/tmp/plan-morning-yesterday-2026-01-02.md" }
    let(:vault) { instance_double(Vault) }

    let(:note) do
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

    before do
      allow(File).to receive(:read).with(scratch_path).and_return(scratch_content)
      allow(Vault).to receive(:new).and_return(vault)
      allow(vault).to receive(:previous_daily_notes).and_return([note])
      allow(vault).to receive(:write)
    end

    it "applies the marker change, the deletion, and the addition to the note's content" do
      run_script(scratch_path)

      expect(vault).to have_received(:write) do |written|
        expect(written.content).to include("- [x] Kept task")
        expect(written.content).not_to include("Deleted task")
        expect(written.content).to include("- [ ] Added task")
      end
    end
  end
end
