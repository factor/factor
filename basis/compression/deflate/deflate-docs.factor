USING: byte-arrays help.markup help.syntax strings ;
IN: compression.deflate

HELP: deflate
{ $values { "bytes" byte-array } { "bytes'" byte-array } }
{ $description "Compresses a byte array into a raw RFC 1951 DEFLATE stream. Uses LZ77 matches with a 32 KiB window and fixed Huffman codes, falling back to stored blocks when they are smaller. The result has no gzip or zlib header or checksum." } ;

HELP: inflate
{ $values { "bytes" byte-array } { "bytes'" byte-array } }
{ $description "Decompresses a raw RFC 1951 DEFLATE stream. Supports stored, fixed Huffman, and dynamic Huffman blocks, including overlapping matches and references into earlier blocks. Stops at the end of the final block; remaining padding bits and trailing bytes are ignored. The complete result is held in memory." }
{ $errors "Throws " { $link invalid-deflate } " for truncated or malformed input, including invalid Huffman trees, reserved codes, and references before the beginning of the output." } ;

HELP: invalid-deflate
{ $values { "reason" string } }
{ $description "Indicates a malformed or truncated raw DEFLATE stream. The reason slot describes the problem." } ;

ARTICLE: "compression.deflate" "Raw DEFLATE compression"
"The " { $vocab-link "compression.deflate" } " vocabulary implements "
{ $url "https://www.rfc-editor.org/rfc/rfc1951" "RFC 1951" }
" in Factor, without a native compression library. It operates on byte arrays:"
{ $subsections deflate inflate invalid-deflate }
"For gzip and zlib containers, see " { $vocab-link "compression.gzip" }
", " { $vocab-link "compression.inflate" } " and "
{ $vocab-link "compression.zlib" } "." ;

ABOUT: "compression.deflate"
