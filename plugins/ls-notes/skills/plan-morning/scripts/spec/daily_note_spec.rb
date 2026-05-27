# frozen_string_literal: true

require_relative "../lib/daily_note"

RSpec.describe DailyNote do
  subject(:note) { DailyNote.new(path:, content:) }

  let(:path) { "2026-05-22 - Daily Note.md" }

  let(:content) do
    <<~MARKDOWN
      ---
      date: 2026-05-22
      ---

      ## :LiCheckCircle2: Tasks

      ### Personal

      - [>] Forward me
      - [ ] Do me

      ### Work

      - [x] Shipped it

      ## :LiPen: Journal

      - [ ] Not a task to forward
    MARKDOWN
  end

  describe "#date" do
    context "when the file is a daily note" do
      it "parses the date from the filename" do
        expect(note.date).to eq(Date.new(2026, 5, 22))
      end
    end

    context "when the file is not a daily note" do
      let(:path) { "Some Note.md" }

      it { expect(note.date).to be_nil }
    end
  end

  describe "#tasks" do
    it "parses the tasks within the Tasks section" do
      expect(note.tasks.map(&:text)).to eq(["Forward me", "Do me", "Shipped it"])
    end

    it "tags each task with its subheader" do
      expect(note.tasks.map(&:subheader)).to eq(["Personal", "Personal", "Work"])
    end

    it "ignores tasks outside the Tasks section" do
      expect(note.tasks.map(&:text)).not_to include("Not a task to forward")
    end
  end

  describe "#incomplete?" do
    context "when a task is incomplete" do
      let(:content) do
        <<~MARKDOWN
          ## :LiCheckCircle2: Tasks

          ### Personal

          - [ ] To do
          - [x] Complete
          - [>] Forwarded
          - [<] Scheduled
          - [/] Partial
          - [-] Cancelled
        MARKDOWN
      end

      it { expect(note).to be_incomplete }
    end

    context "when every task is resolved" do
      let(:content) do
        <<~MARKDOWN
          ## :LiCheckCircle2: Tasks

          ### Personal

          - [x] Complete
          - [>] Forwarded
          - [<] Scheduled
          - [/] Partial
          - [-] Cancelled
        MARKDOWN
      end

      it { expect(note).not_to be_incomplete }
    end
  end

  describe "#append_tasks" do
    subject(:updated) { note.append_tasks(tasks) }

    let(:tasks) do
      [
        Task.new(type: " ", text: "New personal", subheader: "Personal"),
        Task.new(type: " ", text: "New work", subheader: "Work")
      ]
    end

    it "appends a task under its own subheader" do
      expect(Markdown.section(updated.content, "Personal", 3)).to include("- [ ] New personal")
    end

    it "routes a task to a different subheader" do
      expect(Markdown.section(updated.content, "Work", 3)).to include("- [ ] New work")
    end

    it "appends after the existing tasks in the subheader" do
      personal = Markdown.section(updated.content, "Personal", 3)
      expect(personal.index("New personal")).to be > personal.index("Do me")
    end

    it "does not modify the original note" do
      expect { note.append_tasks(tasks) }.not_to change(note, :content)
    end

    context "when the target subheader is empty" do
      let(:content) { "---\ndate: 2026-05-22\n---\n\n## Tasks\n\n### Personal\n\n### Work\n\n- [ ] Daily\n" }

      let(:tasks) { [Task.new(type: " ", text: "First personal", subheader: "Personal")] }

      it "adds the task under that subheader, not elsewhere" do
        expect(Markdown.section(updated.content, "Personal", 3)).to include("- [ ] First personal")
      end

      it "does not insert the task before the Tasks section" do
        expect(updated.content).to start_with("---\ndate: 2026-05-22\n---\n\n## Tasks")
      end
    end
  end

  describe "#remove_tasks" do
    subject(:updated) { note.remove_tasks([forward]) }

    let(:forward) { note.tasks.find { |task| task.text == "Forward me" } }

    it "removes the task" do
      expect(updated.content).not_to include("Forward me")
    end

    it "keeps the other tasks" do
      expect(updated.content).to include("- [ ] Do me")
    end
  end
end
