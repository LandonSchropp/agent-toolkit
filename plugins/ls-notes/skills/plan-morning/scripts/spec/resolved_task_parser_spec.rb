# frozen_string_literal: true

require_relative "../lib/resolved_task_parser"

RSpec.describe ResolvedTaskParser do
  subject(:parser) { described_class.new(content) }

  let(:content) do
    <<~MARKDOWN
      # Previous Daily Notes

      ## Monday, January 1, 2026

      ### Tasks

      _These tasks were left unresolved. Mark each one with what happened to it._

      #### Personal

      - [x] Update the README.md

      ## Tuesday, January 2, 2026 (Yesterday)

      ### Tasks

      _These tasks were left unresolved. Mark each one with what happened to it._

      #### Work

      - [ ] Post a status update

      ### Highlights

      _What were the notable moments?_

      1. Shipped it

      ### Identity Vote

      - [x] 🟢 Made progress

      **Evidence:** Kept going.
    MARKDOWN
  end

  describe "#tasks" do
    it "parses a day's tasks from its subheaders" do
      expect(parser.tasks(Date.new(2026, 1, 1)).map(&:text)).to eq(["Update the README.md"])
    end

    it "tags each task with its subheader" do
      expect(parser.tasks(Date.new(2026, 1, 2)).map(&:subheader)).to eq(["Work"])
    end

    it "keeps the marker the user set" do
      expect(parser.tasks(Date.new(2026, 1, 1)).first.type).to eq("x")
    end

    it "ignores the Highlights and Identity Vote sections" do
      expect(parser.tasks(Date.new(2026, 1, 2)).map(&:text)).to eq(["Post a status update"])
    end

    context "when the file does not cover the day" do
      it "returns an empty task list" do
        expect(parser.tasks(Date.new(2026, 1, 9))).to eq([])
      end
    end
  end

  describe "#covers?" do
    context "when the file has a header for the day" do
      it { expect(parser.covers?(Date.new(2026, 1, 1))).to be(true) }
    end

    context "when the file has no header for the day" do
      it { expect(parser.covers?(Date.new(2026, 1, 9))).to be(false) }
    end

    context "when a day has no Tasks section" do
      let(:content) do
        <<~MARKDOWN
          # Previous Daily Notes

          ## Wednesday, January 3, 2026 (Yesterday)

          ### Highlights

          1. Nothing to resolve
        MARKDOWN
      end

      it "returns an empty task list" do
        expect(parser.tasks(Date.new(2026, 1, 3))).to eq([])
      end
    end
  end
end
