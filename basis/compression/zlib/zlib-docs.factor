! Copyright (C) 2013 Benjamin Pollack.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math strings byte-arrays ;
IN: compression.zlib

HELP: <compressed>
{ $values
    { "data" byte-array } { "length" integer }
    { "compressed" compressed }
}
{ $description "Creates a new " { $link compressed } ", using the provided bytes as the compressed data and the provided length as the uncompressed length.  You should almost always use " { $link compress } ", rather than using this constructor directly." } ;

HELP: compress
{ $values
    { "byte-array" byte-array }
    { "compressed" compressed }
}
{ $description "Compresses the given byte-array, returning a Factor object holding the compressed data." } ;

HELP: compressed
{ $class-description "The class used to hold compressed data." } ;

HELP: compressed-size
{ $values
    { "byte-array" byte-array }
    { "n" integer }
}
{ $description "Returns the maximum number of bytes required to store the compressed version of a byte array." } ;

HELP: uncompress
{ $values
    { "compressed" compressed }
    { "byte-array" byte-array }
}
{ $description "Uncompresses a compressed object, returning a byte-array of the underlying data." } ;

ARTICLE: "compression.zlib" "compression.zlib"
{ $vocab-link "compression.zlib" }
;

ABOUT: "compression.zlib"
