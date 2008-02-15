USING: help.markup help.syntax math ;
IN: io.crc32

HELP: crc32
{ $values { "seq" "a sequence of bytes" } { "n" integer } }
{ $description "Computes the CRC32 checksum of a sequence of bytes." } ;

HELP: lines-crc32
{ $values { "lines" "a sequence of strings" } { "n" integer } }
{ $description "Computes the CRC32 checksum of a sequence of lines of bytes." } ;

ARTICLE: "io.crc32" "CRC32 checksum calculation"
"The CRC32 checksum algorithm provides a quick but unreliable way to detect changes in data."
{ $subsection crc32 }
{ $subsection lines-crc32 } ;

ABOUT: "io.crc32"
