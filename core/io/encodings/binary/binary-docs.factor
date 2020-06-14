USING: help.markup help.syntax io.encodings.binary ;
IN: io.encodings.binary+docs

HELP: binary
{ $class-description "Encoding descriptor for binary I/O." } ;

ARTICLE: "io.encodings.binary" "Binary encoding"
"Making an encoded stream with the binary encoding is a no-op; streams with this encoding deal with byte-arrays, not strings."
{ $subsections binary } ;

ABOUT: "io.encodings.binary"
