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

  describe "with --help" do
    it "prints usage and exits 0" do
      exit_code = nil
      expect { exit_code = run_script("--help") }.to output(/Usage: forward-tasks/).to_stdout
      expect(exit_code).to eq(0)
    end
  end

  describe "with an unknown option" do
    it "prints an error and the usage, then exits 1" do
      exit_code = nil
      expect { exit_code = run_script("--bogus") }
        .to output(/Error: The option --bogus is invalid/).to_stderr
        .and output(/Usage:/).to_stdout
      expect(exit_code).to eq(1)
    end
  end

  describe "with no arguments" do
    let(:vault) { instance_double(Vault) }
    let(:today) { instance_double(DailyNote) }
    let(:previous) { [instance_double(DailyNote)] }
    let(:forwarder) { instance_double(TaskForwarder) }

    before do
      allow(Vault).to receive(:new).and_return(vault)
      allow(vault).to receive(:find_or_create_todays_daily_note).and_return(today)
      allow(vault).to receive(:previous_daily_notes).and_return(previous)
      allow(vault).to receive(:write)
      allow(TaskForwarder).to receive(:new).with(today, previous).and_return(forwarder)
    end

    context "when forwarding succeeds" do
      let(:forwarded_notes) { [today, instance_double(DailyNote)] }

      before { allow(forwarder).to receive(:forward).and_return(forwarded_notes) }

      it "exits 0" do
        expect(run_script).to eq(0)
      end

      it "writes each forwarded note through the vault" do
        run_script
        expect(vault).to have_received(:write).exactly(forwarded_notes.length).times
      end
    end

    context "when a previous note still has incomplete tasks" do
      let(:error) { TaskForwarder::IncompleteTasksError.new([]) }

      before { allow(forwarder).to receive(:forward).and_raise(error) }

      it "exits 1 and writes the error to stderr" do
        exit_code = nil
        expect { exit_code = run_script }.to output(/incomplete tasks/).to_stderr
        expect(exit_code).to eq(1)
      end
    end
  end
end
