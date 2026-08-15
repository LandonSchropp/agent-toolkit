# frozen_string_literal: true

require "date"

RSpec.describe "plan-morning" do
  # Loads the script as a one-shot in this process so RSpec stubs apply.
  # Returns the status the script exited with, or 0 when it ran clean.
  def run_script
    load File.expand_path("../plan-morning.rb", __dir__)
    0
  rescue SystemExit => system_exit
    system_exit.status
  end

  # Undefines the constants the script sets, so reloading it doesn't warn.
  after do
    %i[DATE YESTERDAY TODAY STANDUP LOG APPLY_YESTERDAY_SCRIPT FORWARD_TASKS_SCRIPT].each do
      Object.send(:remove_const, _1) if Object.const_defined?(_1)
    end
  end

  let(:scripts_directory) { File.expand_path("..", __dir__) }
  let(:yesterday) { "/tmp/plan-morning-2026-01-02-yesterday.md" }
  let(:today) { "/tmp/plan-morning-2026-01-02-today.md" }
  let(:standup) { "/tmp/plan-morning-2026-01-02-standup.md" }
  let(:log) { "/tmp/plan-morning-2026-01-02.log" }
  let(:existing_paths) { [yesterday, today, standup] }

  # Each step the script runs, in order, as a single readable string.
  let(:steps) { [] }

  # The redirect options each step was given, in the same order as `steps`.
  let(:redirects) { [] }

  before do
    allow(Date).to receive(:today).and_return(Date.new(2026, 1, 2))
    allow(File).to receive(:exist?) { |path| existing_paths.include?(path) }
    allow_any_instance_of(Object).to receive(:system) do |_receiver, *arguments|
      steps << arguments.grep_v(Hash).join(" ")
      redirects << arguments.grep(Hash).first
      true
    end
  end

  it "runs the pass's steps in order" do
    run_script

    expect(steps).to eq(
      [
        "nvim -- #{yesterday}",
        "#{scripts_directory}/apply-yesterday.rb",
        "#{scripts_directory}/forward-tasks.rb",
        "nvim -- #{today}",
        "nvim -- #{standup}"
      ]
    )
  end

  it "appends both scripts' output to the log rather than to the tab" do
    run_script
    expect(redirects.compact.map { _1.slice(:out, :err) }.reject(&:empty?))
      .to eq([{ out: [log, "a"], err: %i[child out] }] * 2)
  end

  it "raises on any step that fails, rather than carrying on" do
    run_script
    expect(redirects.compact).to all(include(exception: true))
  end

  context "when a step fails" do
    before do
      allow_any_instance_of(Object).to receive(:system) do |_receiver, *arguments|
        steps << arguments.grep_v(Hash).join(" ")
        raise "Command failed" if arguments.first.end_with?("apply-yesterday.rb")

        true
      end
    end

    it "stops there, so the day isn't planned from a half-applied note" do
      expect { run_script }.to raise_error(/Command failed/)
      expect(steps).not_to include("nvim -- #{today}")
    end
  end

  context "when the standup skill isn't installed, so Phase 1 built no standup file" do
    let(:existing_paths) { [yesterday, today] }

    it "runs every other step" do
      run_script
      expect(steps.length).to eq(4)
    end

    it "does not open a window on a file that doesn't exist" do
      run_script
      expect(steps).not_to include("nvim -- #{standup}")
    end
  end

  context "when a required scratch file is missing" do
    let(:existing_paths) { [yesterday] }

    it "exits 1 without running anything" do
      exit_code = nil
      expect { exit_code = run_script }.to output(/Missing plan-morning scratch files/).to_stderr
      expect(exit_code).to eq(1)
      expect(steps).to be_empty
    end
  end
end
