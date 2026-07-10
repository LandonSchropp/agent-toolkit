# frozen_string_literal: true

require_relative "../lib/vault"
require_relative "../lib/unresolved_task_renderer"

RSpec.describe "resolve-tasks" do
  # Loads the script as a one-shot in this process so RSpec stubs apply.
  # SystemExit raised by exit(...) inside the script is rescued and its status
  # returned; a clean run returns 0. ARGV is stubbed for the example so the
  # script sees the test args without mutating the real ARGV.
  def run_script(*arguments)
    stub_const("ARGV", arguments)
    load File.expand_path("../resolve-tasks.rb", __dir__)
    0
  rescue SystemExit => system_exit
    system_exit.status
  end

  describe "with --help" do
    it "prints usage and exits 0" do
      exit_code = nil
      expect { exit_code = run_script("--help") }.to output(/Usage: resolve-tasks/).to_stdout
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
    let(:previous) { [instance_double(DailyNote)] }
    let(:renderer) { instance_double(UnresolvedTaskRenderer) }
    let(:scratch_path) { "/tmp/plan-morning.md" }

    before do
      allow(Vault).to receive(:new).and_return(vault)
      allow(vault).to receive(:previous_daily_notes).and_return(previous)
      allow(UnresolvedTaskRenderer).to receive(:new).with(previous).and_return(renderer)
      allow(File).to receive(:write)
    end

    context "when there are unresolved tasks" do
      before do
        allow(renderer).to receive(:empty?).and_return(false)
        allow(renderer).to receive(:to_markdown).and_return("# Resolve Tasks\n")
      end

      it "writes the rendered file to the scratch path" do
        expect { run_script }.to output.to_stdout
        expect(File).to have_received(:write).with(scratch_path, "# Resolve Tasks\n")
      end

      it "exits 0" do
        exit_code = nil
        expect { exit_code = run_script }.to output.to_stdout
        expect(exit_code).to eq(0)
      end
    end

    context "when there are no unresolved tasks" do
      before { allow(renderer).to receive(:empty?).and_return(true) }

      it "does not write a file" do
        expect { run_script }.to output.to_stdout
        expect(File).not_to have_received(:write)
      end

      it "reports that nothing needs resolving" do
        expect { run_script }.to output(/No unresolved tasks/).to_stdout
      end
    end
  end
end
