USING: help.markup help.syntax kernel math byte-arrays accessors ;
IN: bitstreams



HELP: <lsb0-bit-reader>
{ $values { "bytes" byte-array } { "bs" bit-reader } }
{ $description "Creates a bitreader object, reading from the given bytearray, which counts the LSB as bit position 0. The cursor is placed at the start of the array. Note that this does not affect the order in which read bits are returned, only the order in which the cursor visits them." } ;

HELP: <msb0-bit-reader>
{ $values { "bytes" byte-array } { "bs" bit-reader } }
{ $description "Creates a bitreader object, reading from the given bytearray, which counts the MSB as bit position 0. The cursor is placed at the start of the array. Note that this does not affect the order in which read bits are returned, only the order in which the cursor visits them." } ;

HELP: peek
{ $values { "n" integer } { "bitstream" bit-reader } { "value" integer } }
{ $description "Reads the next n bits ahead of the cursor. Does not move the cursor; to read bits and move the cursor on use " { $link read } "." } ;

HELP: read
{ $values { "n" integer } { "bitstream" bit-reader } { "value" integer } }
{ $description "Reads the next n bits ahead of the cursor, and then moves the cursor on by n bits. To read bits without moving the cursor, use " { $link peek } ". This word shadows the read word in the " { $vocab-link "io" } " vocabulary, so you may need to alias it if you are using file IO as well as bitstreams." } ;

HELP: seek
{ $values { "n" integer } { "bitstream" bit-reader } }
{ $description "Moves the read cursor of the bit-reader forward by n bits. Use a negative value of n to move the cursor back." } ;

HELP: align
{ $values { "n" integer } { "bitstream" bit-reader } }
{ $description "Moves the read cursor of the bit-reader forward until its position in bits from the start of the stream is an even multiple of n. If it is already such a multiple, the cursor is not moved at all." } ;

HELP: enough-bits?
{ $values { "n" integer } { "bs" bit-reader } { "?" boolean } }
{ $description "Returns a true value if at least n bits remain to be read from the bit-reader." } ;


HELP: set-abp
{ $values { "abp" integer } { "bitstream" bit-reader } }
{ $description "Moves the read cursor of the bit-reader to abp bits from the start of the stream. The position of the cursor in terms of bytes and bits can be changed by directly updating the bit-reader tuple using " { $link >>byte-pos } " and " { $link >>bit-pos } "." } ;

HELP: get-abp
{ $values { "bitstream" bit-reader } { "abp" integer } }
{ $description "Returns the current position of the bit-reader's read cursor as a number of bits from the start of the stream. The position of the cursor in terms of bytes and bits can be read directly from the bit-reader tuple using " { $link byte-pos>> } " and " { $link bit-pos>> } "." } ;
