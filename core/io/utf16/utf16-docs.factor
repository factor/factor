USING: help.markup help.syntax io.encodings strings ;
IN: io.utf16

ARTICLE: "io.utf16" "Working with UTF16-encoded data"
"The UTF16 encoding is a variable-width encoding. Unicode code points are encoded as 2 or 4 byte sequences."
{ $subsection encode-utf16le }
{ $subsection encode-utf16be }
{ $subsection decode-utf16le }
{ $subsection decode-utf16be }
"Support for UTF16 data with a byte order mark:"
{ $subsection encode-utf16 }
{ $subsection decode-utf16 } ;

ABOUT: "io.utf16"

HELP: decode-utf16
{ $values { "seq" "a sequence of bytes" } { "str" string } }
{ $description "Decodes a sequence of bytes representing a Unicode string in UTF16 format. The bytes must begin with a UTF16 byte order mark, which determines if the input is in little or big endian. To decode data without a byte order mark, use " { $link decode-utf16le } " or " { $link decode-utf16be } "." }
{ $errors "Throws a " { $link decode-error } " if the input is malformed." } ;

HELP: decode-utf16be
{ $values { "seq" "a sequence of bytes" } { "str" string } }
{ $description "Decodes a sequence of bytes representing a Unicode string in big endian UTF16 format. The bytes must not begin with a UTF16 byte order mark. To decode data with a byte order mark, use " { $link decode-utf16 } "." }
{ $errors "Throws a " { $link decode-error } " if the input is malformed." } ;

HELP: decode-utf16le
{ $values { "seq" "a sequence of bytes" } { "str" string } }
{ $description "Decodes a sequence of bytes representing a Unicode string in little endian UTF16 format. The bytes must not begin with a UTF16 byte order mark. To decode data with a byte order mark, use " { $link decode-utf16 } "." }
{ $errors "Throws a " { $link decode-error } " if the input is malformed." } ;

{ decode-utf16 decode-utf16le decode-utf16be } related-words

HELP: encode-utf16be
{ $values { "str" string } { "seq" "a sequence of bytes" } }
{ $description "Encodes a Unicode string as a sequence of bytes in big endian UTF16 format." } ;

HELP: encode-utf16le
{ $values { "str" string } { "seq" "a sequence of bytes" } }
{ $description "Encodes a Unicode string as a sequence of bytes in little endian UTF16 format." } ;

HELP: encode-utf16
{ $values { "str" string } { "seq" "a sequence of bytes" } }
{ $description "Encodes a Unicode string as a sequence of bytes in UTF16 format with a byte order mark." } ;

{ encode-utf16 encode-utf16be encode-utf16le } related-words
