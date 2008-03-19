USING: help.markup help.syntax io.encodings strings io.files ;
IN: io.encodings.utf8

ARTICLE: "io.encodings.utf8" "Working with UTF8-encoded data"
"The UTF8 encoding is a variable-width encoding. 7-bit ASCII characters are encoded as single bytes, and other Unicode code points are encoded as 2 to 4 byte sequences. The encoding descriptor for UTF-8:"
{ $subsection utf8 } ;

HELP: utf8
{ $class-description "This is the class of encoding tuples which denote a UTF-8 encoding. This conforms to the " { $link "encodings-protocol" } "." } ;

ABOUT: "io.encodings.utf8"
