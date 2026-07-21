# frozen_string_literal: true

require_relative "../lib/task_forwarder"
require_relative "../lib/daily_note"

RSpec.describe TaskForwarder do
  subject(:forwarder) { TaskForwarder.new(today, previous) }

  def daily_note(basename, personal: [], work: [])
    content = "## Tasks\n\n### Personal\n\n#{personal.map { "#{_1}\n" }.join}\n### Work\n\n#{work.map { "#{_1}\n" }.join}"
    DailyNote.new(path: "Daily Notes/2026/2026-05/#{basename}", content:)
  end

  let(:today) { daily_note("2026-05-27 - Daily Note.md") }

  describe "#forward" do
    let(:previous) do
      [
        daily_note(
          "2026-05-26 - Daily Note.md",
          personal: ["- [>] Forward me", "- [<] Schedule me", "- [/] Partial me", "- [x] Done"],
          work: ["- [>] Work item"]
        )
      ]
    end

    let(:today_result) { forwarder.forward.find { File.basename(_1.path) == "2026-05-27 - Daily Note.md" } }
    let(:source_result) { forwarder.forward.find { File.basename(_1.path) == "2026-05-26 - Daily Note.md" } }
    let(:todays_personal) { Markdown.section(today_result.content, "Personal", 3) }

    it "forwards a forwarded task as a to-do" do
      expect(todays_personal).to include("- [ ] Forward me")
    end

    it "forwards a partial task as a to-do" do
      expect(todays_personal).to include("- [ ] Partial me")
    end

    it "forwards a scheduled task, keeping its marker" do
      expect(todays_personal).to include("- [<] Schedule me")
    end

    it "routes a work task under the Work subheader" do
      expect(Markdown.section(today_result.content, "Work", 3)).to include("- [ ] Work item")
    end

    it "ignores completed tasks" do
      expect(today_result.content).not_to include("Done")
    end

    it "removes the scheduled task from its source" do
      expect(source_result.content).not_to include("Schedule me")
    end

    it "leaves the forwarded task on its source" do
      expect(source_result.content).to include("- [>] Forward me")
    end

    context "when today already has the task" do
      let(:today) { daily_note("2026-05-27 - Daily Note.md", personal: ["- [ ] Forward me"]) }

      it "does not add it twice" do
        expect(todays_personal.scan("Forward me").length).to eq(1)
      end
    end

    context "when a task is completed in a later previous note" do
      let(:previous) do
        [
          daily_note("2026-05-24 - Daily Note.md", personal: ["- [/] Finish the report"]),
          daily_note("2026-05-26 - Daily Note.md", personal: ["- [x] Finish the report"])
        ]
      end

      it "does not forward the task" do
        expect(today_result.content).not_to include("Finish the report")
      end
    end

    context "when the same task appears as forwardable in multiple previous notes" do
      let(:previous) do
        [
          daily_note("2026-05-24 - Daily Note.md", personal: ["- [>] Write the docs"]),
          daily_note("2026-05-26 - Daily Note.md", personal: ["- [/] Write the docs"])
        ]
      end

      it "forwards the task only once" do
        expect(today_result.content.scan("Write the docs").length).to eq(1)
      end

      it "uses the latest marker when forwarding" do
        expect(todays_personal).to include("- [ ] Write the docs")
      end
    end

    context "when a scheduled task appears in multiple previous notes" do
      let(:previous) do
        [
          daily_note("2026-05-24 - Daily Note.md", personal: ["- [<] Roll me forward"]),
          daily_note("2026-05-26 - Daily Note.md", personal: ["- [<] Roll me forward"])
        ]
      end

      it "removes the scheduled task from all source notes" do
        results = forwarder.forward
        previous.each do |note|
          result = results.find { _1.path == note.path }
          expect(result&.content).not_to include("Roll me forward")
        end
      end

      it "forwards the task only once" do
        expect(today_result.content.scan("Roll me forward").length).to eq(1)
      end
    end

    context "when a scheduled task's subheader does not exist in today's note" do
      let(:previous) do
        [
          DailyNote.new(
            path: "Daily Notes/2026/2026-05/2026-05-26 - Daily Note.md",
            content: "## Tasks\n\n### Personal\n\n### Content\n\n- [<] Read the article\n"
          )
        ]
      end

      it "creates the subheader in today's note and forwards the task there" do
        expect(Markdown.section(today_result.content, "Content", 3)).to include("- [<] Read the article")
      end

      it "removes the task from its source" do
        expect(source_result.content).not_to include("Read the article")
      end
    end

    context "when a previous note has an incomplete task" do
      let(:previous) do
        [
          daily_note("2026-05-25 - Daily Note.md", personal: ["- [x] Done"]),
          daily_note("2026-05-26 - Daily Note.md", personal: ["- [ ] Unresolved"])
        ]
      end

      it "raises, naming the offending note" do
        expect { forwarder.forward }
          .to raise_error(TaskForwarder::IncompleteTasksError, /2026-05-26 - Daily Note/)
      end
    end
  end
end
