# frozen_string_literal: true

require_relative "../lib/task"

RSpec.describe Task do
  describe ".parse" do
    subject(:task) { Task.parse(line, "Personal") }

    context "when the line is a forwarded task" do
      let(:line) { "- [>] Review the pull request" }

      it "has the forwarded type" do
        expect(task.type).to eq(">")
      end

      it "extracts the text" do
        expect(task.text).to eq("Review the pull request")
      end

      it "belongs to the given subheader" do
        expect(task.subheader).to eq("Personal")
      end
    end

    context "when the line is a scheduled task" do
      let(:line) { "- [<] Pay the rent" }

      it "has the scheduled type" do
        expect(task.type).to eq("<")
      end
    end

    context "when the line is a completed task" do
      let(:line) { "- [x] Ship the feature" }

      it "has the completed type" do
        expect(task.type).to eq("x")
      end
    end

    context "when the line is an incomplete task" do
      let(:line) { "- [ ] Buy groceries" }

      it "has the incomplete type" do
        expect(task.type).to eq(" ")
      end

      it "extracts the text" do
        expect(task.text).to eq("Buy groceries")
      end
    end

    context "when the line is a partial task" do
      let(:line) { "- [/] Draft the proposal" }

      it "has the partial type" do
        expect(task.type).to eq("/")
      end
    end

    context "when the line is a cancelled task" do
      let(:line) { "- [-] Abandon the idea" }

      it "has the cancelled type" do
        expect(task.type).to eq("-")
      end
    end

    context "when the task is indented" do
      let(:line) { "  - [>] A nested task" }

      it "extracts the text without the indentation" do
        expect(task.text).to eq("A nested task")
      end
    end

    context "when the task uses a numbered bullet" do
      let(:line) { "1. [x] The first item" }

      it "extracts the text" do
        expect(task.text).to eq("The first item")
      end
    end

    context "when the task uses an asterisk bullet" do
      let(:line) { "* [ ] A starred item" }

      it "has the incomplete type" do
        expect(task.type).to eq(" ")
      end
    end

    context "when the line is a plain list item" do
      let(:line) { "- Just a bullet" }

      it { is_expected.to be_nil }
    end

    context "when the line is prose" do
      let(:line) { "This is a sentence." }

      it { is_expected.to be_nil }
    end

    context "when the line is empty" do
      let(:line) { "" }

      it { is_expected.to be_nil }
    end

    context "when the checkbox has no trailing space" do
      let(:line) { "- [ ]" }

      it { is_expected.to be_nil }
    end
  end

  describe "#forwarded?" do
    subject(:task) { Task.new(type:, text: "A task", subheader: "Personal") }

    context "when the type is a forward marker" do
      let(:type) { ">" }

      it { is_expected.to be_forwarded }
    end

    context "when the type is not a forward marker" do
      let(:type) { "x" }

      it { is_expected.not_to be_forwarded }
    end
  end

  describe "#scheduled?" do
    subject(:task) { Task.new(type:, text: "A task", subheader: "Personal") }

    context "when the type is a schedule marker" do
      let(:type) { "<" }

      it { is_expected.to be_scheduled }
    end

    context "when the type is not a schedule marker" do
      let(:type) { " " }

      it { is_expected.not_to be_scheduled }
    end
  end

  describe "#complete?" do
    subject(:task) { Task.new(type:, text: "A task", subheader: "Personal") }

    context "when the type is a completion marker" do
      let(:type) { "x" }

      it { is_expected.to be_complete }
    end

    context "when the type is not a completion marker" do
      let(:type) { " " }

      it { is_expected.not_to be_complete }
    end
  end

  describe "#incomplete?" do
    subject(:task) { Task.new(type:, text: "A task", subheader: "Personal") }

    context "when the type is a space" do
      let(:type) { " " }

      it { is_expected.to be_incomplete }
    end

    context "when the type is not a space" do
      let(:type) { ">" }

      it { is_expected.not_to be_incomplete }
    end
  end

  describe "#partial?" do
    subject(:task) { Task.new(type:, text: "A task", subheader: "Personal") }

    context "when the type is a partial marker" do
      let(:type) { "/" }

      it { is_expected.to be_partial }
    end

    context "when the type is not a partial marker" do
      let(:type) { " " }

      it { is_expected.not_to be_partial }
    end
  end

  describe "#cancelled?" do
    subject(:task) { Task.new(type:, text: "A task", subheader: "Personal") }

    context "when the type is a cancellation marker" do
      let(:type) { "-" }

      it { is_expected.to be_cancelled }
    end

    context "when the type is not a cancellation marker" do
      let(:type) { "x" }

      it { is_expected.not_to be_cancelled }
    end
  end

  describe "#forwardable?" do
    subject(:task) { Task.new(type:, text: "A task", subheader: "Personal") }

    context "when the task is forwarded" do
      let(:type) { ">" }

      it { is_expected.to be_forwardable }
    end

    context "when the task is scheduled" do
      let(:type) { "<" }

      it { is_expected.to be_forwardable }
    end

    context "when the task is partial" do
      let(:type) { "/" }

      it { is_expected.to be_forwardable }
    end

    context "when the task is complete" do
      let(:type) { "x" }

      it { is_expected.not_to be_forwardable }
    end

    context "when the task is incomplete" do
      let(:type) { " " }

      it { is_expected.not_to be_forwardable }
    end

    context "when the task is cancelled" do
      let(:type) { "-" }

      it { is_expected.not_to be_forwardable }
    end
  end

  describe "#matches?" do
    subject(:task) { Task.new(type: ">", text: "Write the docs", subheader: "Personal") }

    context "when the text and subheader match, regardless of marker" do
      it { is_expected.to be_matches(Task.new(type: "x", text: "Write the docs", subheader: "Personal")) }
    end

    context "when the text differs" do
      it { is_expected.not_to be_matches(Task.new(type: ">", text: "Something else", subheader: "Personal")) }
    end

    context "when the subheader differs" do
      it { is_expected.not_to be_matches(Task.new(type: ">", text: "Write the docs", subheader: "Work")) }
    end
  end

  describe "#with" do
    subject(:task) { Task.new(type: " ", text: "A task", subheader: "Personal") }

    it "returns a copy with the subheader changed" do
      expect(task.with(subheader: "Work").subheader).to eq("Work")
    end
  end

  describe "#to_markdown" do
    subject(:task) { Task.new(type: ">", text: "Write the docs", subheader: "Personal") }

    it "renders the task as a list item" do
      expect(task.to_markdown).to eq("- [>] Write the docs")
    end
  end
end
