USING: byte-arrays help.markup help.syntax ;
IN: compression.inflate

HELP: gzip-inflate
{ $values { "bytes" byte-array } { "bytes'" byte-array } }
{ $description "Decompresses a gzip byte array, concatenating the output of all members. Optional extra fields, file names, comments, and header checksums are supported. The header checksum, when present, and the member's data checksum and uncompressed size are checked. Zero bytes following the last member are ignored as padding." }
{ $errors "Throws an error for invalid headers, truncated data, checksum and size mismatches, or non-zero data following the last member." } ;
