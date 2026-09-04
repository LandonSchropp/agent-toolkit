# frozen_string_literal: true

require "date"

RSpec.describe "sync-standup" do
  # Loads the script as a one-shot in this process so RSpec stubs apply.
  # Returns the status the script exited with, or 0 when it ran clean.
  def run_script
    load File.expand_path("../sync-standup.rb", __dir__)
    0
  rescue SystemExit => system_exit
    system_exit.status
  end

  # Undefines the constants the script sets, so reloading it doesn't warn.
  after do
    %i[TODAY_PATH STANDUP_PATH REFERENCE_PREFIX COMMENT_REGEX].each do
      Object.send(:remove_const, _1) if Object.const_defined?(_1)
    end
  end

  # A date in the past, so the real scratch files these write can't collide
  # with a plan-morning run happening today.
  let(:date) { Date.new(2026, 1, 2) }
  let(:today_path) { "/tmp/plan-morning-2026-01-02-today.md" }
  let(:standup_path) { "/tmp/plan-morning-2026-01-02-standup.md" }

  let(:today_content) do
    <<~MARKDOWN
      # Today

      ## Tasks

      _Add, edit, and remove tasks to plan today._

      ### Personal

      - [ ] Update the README.md

      ### Work

      - [ ] Update/merge open pull requests
        - [ ] [WIDGETS: Add pagination to widget list](https://github.com/example-org/widget-service/pull/42) 💬
    MARKDOWN
  end

  let(:standup_content) do
    <<~MARKDOWN
      # Daily Standup

      ## Yesterday

      ## Today

      <!-- Work tasks from today's daily note (reference only — not included in standup):
      - [ ] Stale task from before Today was edited
      -->

      ## Blockers

      ## Feeling
    MARKDOWN
  end

  before do
    allow(Date).to receive(:today).and_return(date)
    File.write(today_path, today_content)
    File.write(standup_path, standup_content)
  end

  after do
    File.delete(today_path) if File.exist?(today_path)
    File.delete(standup_path) if File.exist?(standup_path)
  end

  it "replaces the stale reference block with the Today file's current Work tasks" do
    run_script
    expect(File.read(standup_path))
      .to include("- [ ] Update/merge open pull requests").and include("- [ ] [WIDGETS: Add pagination to widget list]")
  end

  it "drops the tasks that no longer belong there" do
    run_script
    expect(File.read(standup_path)).not_to include("Stale task from before Today was edited")
  end

  it "leaves the Personal tasks out, since the reference is Work tasks only" do
    run_script
    expect(File.read(standup_path)).not_to include("Update the README.md")
  end

  it "leaves the rest of the standup file untouched" do
    run_script
    expect(File.read(standup_path)).to include("## Yesterday").and include("## Blockers").and include("## Feeling")
  end

  context "when Today has no Work tasks" do
    let(:today_content) { "# Today\n\n## Tasks\n\n### Personal\n\n### Work\n\n" }

    it "says so instead of listing any" do
      run_script
      expect(File.read(standup_path)).to include("(reference only — not included in standup): none")
    end
  end
end
