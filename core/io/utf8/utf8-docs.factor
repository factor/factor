USING: help.markup help.syntax io.encodings strings ;
IN: io.utf8

ARTICLE: "io.utf8" "Working with UTF8-encoded data"
"The UTF8 encoding is a variable-width encoding. 7-bit ASCII characters are encoded as single bytes, and other Unicode code points are encoded as 2 to 4 byte sequences."
{ $subsection encode-utf8 }
{ $subsection decode-utf8 } ;

ABOUT: "io.utf8"

HELP: decode-utf8
{ $values { "seq" "a sequence of bytes" } { "str" string } }
{ $description "Decodes a sequence of bytes representing a Unicode string in UTF8 format." }
{ $errors "Throws a " { $link decode-error } " if the input is malformed." } ;

HELP: encode-utf8
{ $values { "str" string } { "seq" "a sequence of bytes" } }
{ $description "Encodes a Unicode string as a sequence of bytes in UTF8 format." } ;
