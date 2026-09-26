USING: assocs byte-arrays help.markup help.syntax strings ;
IN: yenc

HELP: yenc-file
{ $values { "path" string } { "yenc" byte-array } }
{ $description "Encodes a file in a single-part yEnc envelope. The trailer contains the file size and the CRC32 of the file contents." } ;

HELP: ydec-file
{ $values { "yenc" "a byte sequence" } { "ybegin" assoc } { "yend" assoc } { "bytes" byte-array } }
{ $description "Decodes the first yEnc envelope, ignoring text before and after it. Returns the header and trailer metadata with string values and the decoded bytes. Filenames may contain spaces and equals signs. Sizes and any single-part CRC32 are checked; corrupt envelopes throw " { $link invalid-yenc } "." }
{ $notes "For a multipart envelope, decodes one part and checks its range, part number, size and required pcrc32. The ypart begin and end fields are included in the returned header as one-based, inclusive byte offsets. Separate parts are not assembled automatically. A whole-file crc32 is returned but can only be checked when the part covers the entire file. " { $link yenc-file } " produces single-part envelopes." } ;

HELP: invalid-yenc
{ $description "Thrown when a yEnc envelope is missing required size, part or marker information, or fails size, range or CRC32 validation." } ;
