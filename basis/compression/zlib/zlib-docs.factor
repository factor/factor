! Copyright (C) 2013 Benjamin Pollack.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math strings byte-arrays ;
IN: compression.zlib

HELP: compress
{ $values
    { "byte-array" byte-array }
    { "byte-array'" byte-array }
}
{ $description "Returns a byte-array of compressed bytes." } ;

HELP: uncompress
{ $values
    { "byte-array" byte-array }
    { "byte-array'" byte-array }
}
{ $description "Takes a zlib-compressed byte-array and uncompresses it to another byte-array." } ;

ARTICLE: "compression.zlib" "Compression (ZLIB)"
"The " { $vocab-link "compression.zlib" } " vocabulary provides support for ZLIB:"
{ $subsections
    compress
    uncompress
} ;

ABOUT: "compression.zlib"
