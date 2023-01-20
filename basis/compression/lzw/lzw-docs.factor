! Copyright (C) 2009 Keith Lazuka
! See https://factorcode.org/license.txt for BSD license.
USING: bitstreams byte-arrays classes help.markup help.syntax
kernel math quotations sequences ;
IN: compression.lzw

HELP: gif-lzw-uncompress
{ $values
    { "seq" sequence } { "code-size" integer }
    { "byte-array" byte-array }
}
{ $description "Decompresses a sequence of LZW-compressed bytes obtained from a GIF file." } ;

HELP: tiff-lzw-uncompress
{ $values
    { "seq" sequence }
    { "byte-array" byte-array }
}
{ $description "Decompresses a sequence of LZW-compressed bytes obtained from a TIFF file." } ;

HELP: lzw-read
{ $values
    { "lzw" lzw } { "n" integer }
}
{ $description "Read the next LZW code." } ;

HELP: lzw-process-next-code
{ $values
    { "lzw" lzw } { "quot" quotation }
}
{ $description "Read the next LZW code and, assuming that the code is neither the Clear Code nor the End of Information Code, conditionally processes it by calling " { $snippet "quot" } " with the lzw object and the LZW code. If it does read a Clear Code, this combinator will take care of handling the Clear Code for you." } ;

HELP: <lzw-uncompress>
{ $values
    { "input" bit-reader } { "code-size" "number of bits" } { "class" class }
    { "obj" object }
}
{ $description "Instantiate a new LZW decompressor." } ;

HELP: code-space-full?
{ $values
    { "lzw" lzw }
    { "?" boolean }
}
{ $description "Determines when to increment the variable length code's bit-width." } ;

HELP: reset-lzw-uncompress
{ $values
    { "lzw" lzw }
}
{ $description "Reset the LZW uncompressor state (either at initialization time or immediately after receiving a Clear Code)." } ;

ARTICLE: "compression.lzw.differences" "LZW differences between TIFF and GIF"
{ $vocab-link "compression.lzw" }
$nl
"There are some subtle differences between the LZW algorithm used by TIFF and GIF images."
{ $heading "Variable Length Codes" }
"Both TIFF and GIF use a variation of the LZW algorithm that uses variable length codes. In both cases, the maximum code size is 12 bits. The initial code size, however, is different between the two formats. TIFF's initial code size is always 9 bits. GIF's initial code size is specified on a per-file basis at the beginning of the image descriptor block, with a minimum of 3 bits."
$nl
"TIFF and GIF each switch to the next code size using slightly different algorithms. GIF increments the code size as soon as the LZW string table's length is equal to 2**code-size, while TIFF increments the code size when the table's length is equal to 2**code-size - 1."
{ $heading "Packing Bits into Bytes" }
"TIFF and GIF LZW algorithms differ in how they pack the code bits into the byte stream. The least significant bit in a TIFF code is stored in the most significant bit of the bytestream, while the least significant bit in a GIF code is stored in the least significant bit of the bytestream."
{ $heading "Special Codes" }
"TIFF and GIF both add the concept of a 'Clear Code' and a 'End of Information Code' to the LZW algorithm. In both cases, the 'Clear Code' is equal to 2**(code-size - 1) and the 'End of Information Code' is equal to the Clear Code + 1. These 2 codes are reserved in the string table. So in both cases, the LZW string table is initialized to have a length equal to the End of Information Code + 1."
;

ARTICLE: "compression.lzw" "LZW compression"
{ $vocab-link "compression.lzw" }
$nl
"Implements both the TIFF and GIF variations of the LZW algorithm."
{ $heading "Decompression" }
{ $subsections
    tiff-lzw-uncompress
    gif-lzw-uncompress
}
{ $heading "Compression" }
"Compression has not yet been implemented."
$nl
"Implementation details:"
{ $subsections "compression.lzw.differences" }
;

ABOUT: "compression.lzw"
