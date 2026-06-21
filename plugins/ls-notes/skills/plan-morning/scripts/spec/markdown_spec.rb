# frozen_string_literal: true

require_relative "../lib/markdown"

RSpec.describe Markdown do
  let(:content) do
    <<~MARKDOWN
      ## :LiCheckCircle2: Tasks

      ### Personal

      - [ ] Buy groceries

      ## :LiSun: Morning

      Some reflection.
    MARKDOWN
  end

  describe ".section" do
    subject { described_class.section(content, name, level) }

    context "when the section is followed by a same-level header" do
      let(:name) { "Tasks" }
      let(:level) { 2 }

      it { is_expected.to eq("\n### Personal\n\n- [ ] Buy groceries\n\n") }
    end

    context "when the section runs to the end of the content" do
      let(:name) { "Morning" }
      let(:level) { 2 }

      it { is_expected.to eq("\nSome reflection.\n") }
    end

    context "when the section has a subheader at a deeper level" do
      let(:name) { "Personal" }
      let(:level) { 3 }

      it { is_expected.to eq("\n- [ ] Buy groceries\n\n") }
    end

    context "when the header is not found" do
      let(:name) { "Evening" }
      let(:level) { 2 }

      it { is_expected.to be_nil }
    end
  end

  describe ".header_name" do
    subject { described_class.header_name(line) }

    context "when the line is a header" do
      let(:line) { "### Personal" }

      it { is_expected.to eq("Personal") }
    end

    context "when the header has a leading icon" do
      let(:line) { "### :LiFlower: Gratitude" }

      it { is_expected.to eq("Gratitude") }
    end

    context "when the line is not a header" do
      let(:line) { "- [ ] a task" }

      it { is_expected.to be_nil }
    end
  end

  describe ".header_names" do
    subject { described_class.header_names(content) }

    it { is_expected.to eq(["Tasks", "Personal", "Morning"]) }

    context "when a level is given" do
      subject { described_class.header_names(content, level: 3) }

      let(:content) { "## Tasks\n\n### Personal\n\n#### Online\n\n### Weekly Chores\n" }

      it "returns only the headers at that level" do
        is_expected.to eq(["Personal", "Weekly Chores"])
      end
    end
  end

  describe ".replace_section" do
    subject(:result) { described_class.replace_section(content, "Tasks", 2, "\n- [ ] new\n\n") }

    it "replaces the section's body" do
      expect(described_class.section(result, "Tasks", 2)).to eq("\n- [ ] new\n\n")
    end

    it "leaves other sections untouched" do
      expect(described_class.section(result, "Morning", 2)).to eq("\nSome reflection.\n")
    end

    context "when the section's body also appears elsewhere" do
      let(:content) { "---\n\n## Tasks\n\n## Morning\n\nkeep\n" }

      it "anchors on the header rather than the first matching body" do
        expect(result).to eq("---\n\n## Tasks\n\n- [ ] new\n\n## Morning\n\nkeep\n")
      end
    end
  end
end
