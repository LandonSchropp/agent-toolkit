# frozen_string_literal: true

require_relative "../lib/vault"
require_relative "../lib/task_forwarder"

RSpec.describe "forward-tasks" do
  # Loads the script as a one-shot in this process so RSpec stubs apply.
  # SystemExit raised by exit(...) inside the script is rescued and its status
  # returned; a clean run returns 0. ARGV is stubbed for the example so the
  # script sees the test args without mutating the real ARGV.
  def run_script(*arguments)
    stub_const("ARGV", arguments)
    load File.expand_path("../forward-tasks.rb", __dir__)
    0
  rescue SystemExit => system_exit
    system_exit.status
  end

  describe "with no scratch file argument" do
    it "prints the usage to stderr and exits 1" do
      exit_code = nil
      expect { exit_code = run_script }.to output(/Usage: forward-tasks/).to_stderr
      expect(exit_code).to eq(1)
    end
  end

  describe "with a scratch file path" do
    let(:vault) { instance_double(Vault) }
    let(:today) { instance_double(DailyNote) }
    let(:previous) { [instance_double(DailyNote)] }
    let(:forwarder) { instance_double(TaskForwarder) }
    let(:forwarded_tasks) { [instance_double(Task)] }
    let(:scratch_path) { "/tmp/plan-morning-today-2026-01-02.md" }
    let(:scratch_note) { instance_double(DailyNote) }
    let(:updated_scratch_note) { instance_double(DailyNote, content: "scratch content with forwarded tasks") }

    before do
      allow(Vault).to receive(:new).and_return(vault)
      allow(vault).to receive(:find_or_create_todays_daily_note).and_return(today)
      allow(vault).to receive(:previous_daily_notes).and_return(previous)
      allow(vault).to receive(:write)
      allow(TaskForwarder).to receive(:new).with(today, previous).and_return(forwarder)
      allow(forwarder).to receive(:forwarded_tasks).and_return(forwarded_tasks)
      allow(File).to receive(:read).with(scratch_path).and_return("scratch content")
      allow(DailyNote).to receive(:new).with(path: scratch_path, content: "scratch content").and_return(scratch_note)
      allow(scratch_note).to receive(:create_tasks).with(forwarded_tasks).and_return(updated_scratch_note)
      allow(File).to receive(:write)
    end

    context "when forwarding succeeds" do
      let(:forwarded_notes) { [today, instance_double(DailyNote)] }

      before { allow(forwarder).to receive(:forward).and_return(forwarded_notes) }

      it "exits 0" do
        expect(run_script(scratch_path)).to eq(0)
      end

      it "writes each forwarded note through the vault" do
        run_script(scratch_path)
        expect(vault).to have_received(:write).exactly(forwarded_notes.length).times
      end

      it "creates the forwarded tasks in the scratch file" do
        run_script(scratch_path)
        expect(File).to have_received(:write).with(scratch_path, "scratch content with forwarded tasks")
      end
    end

    context "when a previous note still has incomplete tasks" do
      let(:error) { TaskForwarder::IncompleteTasksError.new([]) }

      before { allow(forwarder).to receive(:forward).and_raise(error) }

      it "exits 1 and writes the error to stderr" do
        exit_code = nil
        expect { exit_code = run_script(scratch_path) }.to output(/incomplete tasks/).to_stderr
        expect(exit_code).to eq(1)
      end

      it "leaves the scratch file alone" do
        expect { run_script(scratch_path) }.to output.to_stderr
        expect(File).not_to have_received(:write)
      end
    end

    context "when the scratch file does not exist" do
      before { allow(File).to receive(:read).with(scratch_path).and_raise(Errno::ENOENT) }

      it "does not write any note, so a bad path fails before the notes change" do
        expect { run_script(scratch_path) }.to raise_error(Errno::ENOENT)
        expect(vault).not_to have_received(:write)
      end
    end
  end
end
