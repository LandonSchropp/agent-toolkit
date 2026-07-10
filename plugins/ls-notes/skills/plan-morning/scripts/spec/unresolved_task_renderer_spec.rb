# frozen_string_literal: true

require_relative "../lib/unresolved_task_renderer"
require_relative "../lib/daily_note"

RSpec.describe UnresolvedTaskRenderer do
  subject(:renderer) { UnresolvedTaskRenderer.new(notes) }

  def daily_note(basename, personal: [], work: [])
    content = "## Tasks\n\n### Personal\n\n#{personal.map { "#{_1}\n" }.join}\n### Work\n\n#{work.map { "#{_1}\n" }.join}"
    DailyNote.new(path: "Daily Notes/2026-01/#{basename}", content:)
  end

  describe "#to_markdown" do
    subject(:markdown) { renderer.to_markdown }

    context "when a note has unresolved tasks under multiple subheaders" do
      let(:notes) do
        [daily_note("2026-01-05 - Daily Note.md", personal: ["- [ ] Write the report"], work: ["- [ ] Review the PR"])]
      end

      it "renders the header, day, and tasks grouped by subheader" do
        expect(markdown).to eq(<<~MARKDOWN)
          # Resolve Tasks

          ## Monday, January 5, 2026

          ### Personal

          - [ ] Write the report

          ### Work

          - [ ] Review the PR
        MARKDOWN
      end
    end

    context "when a note mixes unresolved and forwardable tasks" do
      let(:notes) do
        [daily_note(
          "2026-01-05 - Daily Note.md",
          personal: ["- [ ] Unresolved", "- [/] Partial", "- [>] Forwarded", "- [<] Scheduled", "- [x] Done", "- [-] Cancelled"]
        )]
      end

      it "includes the unresolved task" do
        expect(markdown).to include("- [ ] Unresolved")
      end

      it "excludes a partial task" do
        expect(markdown).not_to include("Partial")
      end

      it "excludes forwarded, scheduled, complete, and cancelled tasks" do
        expect(markdown).not_to match(/Forwarded|Scheduled|Done|Cancelled/)
      end
    end

    context "when several days have unresolved tasks" do
      let(:notes) do
        [
          daily_note("2026-01-05 - Daily Note.md", personal: ["- [ ] Monday task"]),
          daily_note("2026-01-06 - Daily Note.md", personal: ["- [ ] Tuesday task"])
        ]
      end

      it "orders the days as given, oldest first" do
        expect(markdown.index("Monday, January 5")).to be < markdown.index("Tuesday, January 6")
      end
    end

    context "when a note has only forwardable and completed tasks" do
      let(:notes) do
        [
          daily_note("2026-01-05 - Daily Note.md", personal: ["- [/] Rolling"]),
          daily_note("2026-01-06 - Daily Note.md", personal: ["- [ ] Real work"])
        ]
      end

      it "omits the day with nothing to resolve" do
        expect(markdown).not_to include("January 5")
      end

      it "keeps the day that has unresolved tasks" do
        expect(markdown).to include("## Tuesday, January 6, 2026")
      end
    end

    context "when only one subheader has unresolved tasks" do
      let(:notes) do
        [daily_note("2026-01-05 - Daily Note.md", personal: ["- [ ] Personal task"], work: ["- [x] Done work"])]
      end

      it "omits the subheader with nothing to resolve" do
        expect(markdown).not_to include("### Work")
      end
    end
  end

  describe "#empty?" do
    context "when no note has an unresolved task" do
      let(:notes) { [daily_note("2026-01-05 - Daily Note.md", personal: ["- [/] Partial", "- [x] Done"])] }

      it "is empty" do
        expect(renderer).to be_empty
      end
    end

    context "when a note has an unresolved task" do
      let(:notes) { [daily_note("2026-01-05 - Daily Note.md", personal: ["- [ ] Unresolved"])] }

      it "is not empty" do
        expect(renderer).not_to be_empty
      end
    end
  end
end
