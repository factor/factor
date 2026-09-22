USING: byte-arrays help.markup help.syntax ;
IN: compression.gzip

HELP: compress-fixed
{ $values { "byte-array" byte-array } { "byte-array'" byte-array } }
{ $description "Compresses bytes into a gzip member using fixed Huffman codes. The result includes the gzip header, checksum, and uncompressed size." } ;

HELP: compress-dynamic
{ $values { "byte-array" byte-array } { "byte-array'" byte-array } }
{ $description "Compresses bytes into a gzip member using dynamic Huffman codes. The result includes the gzip header, checksum, and uncompressed size." } ;
