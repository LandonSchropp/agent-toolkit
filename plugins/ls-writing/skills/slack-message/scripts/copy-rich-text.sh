#!/usr/bin/env bash

set -euo pipefail

# Puts an HTML file on the macOS clipboard as rich text, HTML and plain text at once.

if [[ $# -ne 1 ]]; then
  echo "Usage: copy-rich-text.sh <file>" >&2
  exit 1
fi

file="$1"

if [[ ! -f "$file" ]]; then
  echo "Error: The file $file doesn't exist." >&2
  exit 1
fi

# shellcheck disable=SC2016
osascript -l JavaScript -e '
ObjC.import("AppKit");

function run(argv) {
  const html = $.NSString.stringWithContentsOfFileEncodingError(argv[0], $.NSUTF8StringEncoding, null);
  const data = $("<meta charset=\"utf-8\">" + ObjC.unwrap(html)).dataUsingEncoding($.NSUTF8StringEncoding);
  const options = $({ [ObjC.unwrap($.NSDocumentTypeDocumentAttribute)]: $.NSHTMLTextDocumentType });
  const attributedString = $.NSAttributedString.alloc.initWithDataOptionsDocumentAttributesError(data, options, null, null);

  const range = $.NSMakeRange(0, attributedString.length);
  const rtf = attributedString.RTFFromRangeDocumentAttributes(range, $({}));

  const pasteboard = $.NSPasteboard.generalPasteboard;
  pasteboard.clearContents;
  pasteboard.setDataForType(rtf, $.NSPasteboardTypeRTF);
  pasteboard.setStringForType(html, $.NSPasteboardTypeHTML);
  pasteboard.setStringForType(attributedString.string, $.NSPasteboardTypeString);
}
' "$file"
