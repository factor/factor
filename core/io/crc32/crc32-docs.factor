USING: help.markup help.syntax math ;
IN: io.crc32

HELP: crc32
{ $values { "seq" "a sequence" } { "n" integer } }
{ $description "Computes the CRC32 checksum of a sequence of bytes." } ;

HELP: file-crc32
{ $values { "path" "a pathname string" } { "n" integer } }
{ $description "Computes the CRC32 checksum of a file's contents." } ;

ARTICLE: "io.crc32" "CRC32 checksum calculation"
"The CRC32 checksum algorithm provides a quick but unreliable way to detect changes in data."
{ $subsection crc32 }
{ $subsection file-crc32 } ;

ABOUT: "io.crc32"
