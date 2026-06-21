# frozen_string_literal: true

# Helpers for extracting pieces of Markdown content. The section helper operates
# on and returns plain content, so it composes: the body of a level-2 section
# can be passed back in to fetch a level-3 subsection within it.
module Markdown
  class << self
    # Returns the body of a section: the content following the matching header,
    # up to (but excluding) the next header at the same level or higher, or the
    # end of the content.
    #
    # @param content [String] the Markdown content to search
    # @param name [String] the header text to match, ignoring a leading icon
    # @param level [Integer] the header level (the number of leading "#")
    # @return [String, nil] the section body, or nil when the header is absent
    def section(content, name, level)
      content[section_regex(name, level), "body"]
    end

    # Returns the name of a header line at any level, ignoring a leading Obsidian
    # icon token. Returns nil when the line is not a header.
    #
    # @param line [String] the line to inspect
    # @return [String, nil] the header name, or nil
    def header_name(line)
      line[/\A#+ (?::[^\s:]+: )?(?<name>.+?)[ \t]*\z/, "name"]
    end

    # Returns the names of every header in the content, in order, ignoring
    # leading Obsidian icon tokens. Pass a level to restrict the results to
    # headers at exactly that level, skipping deeper or shallower ones.
    #
    # @param content [String] the Markdown content to scan
    # @param level [Integer, nil] the header level to keep, or nil for all
    # @return [Array<String>] the header names
    def header_names(content, level: nil)
      content.lines(chomp: true).filter_map do |line|
        next if level && !line.match?(/\A#{"#" * level} /)

        header_name(line)
      end
    end

    # Replaces a section's body, keeping its header. The match is anchored on the
    # header, so it edits the right section even when the body is not unique.
    #
    # @param content [String] the Markdown content to edit
    # @param name [String] the header text to match, ignoring a leading icon
    # @param level [Integer] the header level (the number of leading "#")
    # @param replacement [String] the replacement body
    # @return [String] the content with the section's body replaced
    def replace_section(content, name, level, replacement)
      content.sub(section_regex(name, level)) { "#{$~[:header]}#{replacement}" }
    end

    private

    # Builds a regex matching a named header and capturing its body up to the
    # next header at the same level or higher (or the end of the content). The
    # "#{n}" fragments are literal "#" characters followed by a "{n}" quantifier,
    # so the closing lookahead matches one-to-level hashes. The header may carry
    # a leading Obsidian icon token, such as ":LiSun:".
    #
    # @param name [String] the header text to match
    # @param level [Integer] the header level
    # @return [Regexp] the section-matching regex
    def section_regex(name, level)
      hashes = "#" * level
      opening = "(?<header>^#{hashes} (?::[^\\s:]+: )?#{Regexp.escape(name)}[ \\t]*\\n)"
      closing = "(?=^#" + "{1,#{level}} |\\z)"
      Regexp.new("#{opening}(?<body>.*?)#{closing}", Regexp::MULTILINE)
    end
  end
end
