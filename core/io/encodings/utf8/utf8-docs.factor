USING: help.markup help.syntax ;
IN: io.encodings.utf8

HELP: utf8
{ $class-description "Encoding descriptor for UTF-8 encoding." } ;

ARTICLE: "io.encodings.utf8" "UTF-8 encoding"
"UTF-8 is a variable-width encoding. 7-bit ASCII characters are encoded as single bytes, and other Unicode code points are encoded as 2 to 4 byte sequences."
{ $subsections utf8 }
"While not generally recommended, UTF-8 can have a Byte-Order-Mark (BOM) inserted at the beginning of a stream. We provide an encoding that will optionally skip the BOM, as well as insert the BOM when encoding."
{ $subsections utf8-bom } ;

ABOUT: "io.encodings.utf8"
