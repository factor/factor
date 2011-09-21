! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math quotations ;
IN: alien.endian

HELP: be16
{ $var-description "Signed bit-endian 16-bit." } ;

HELP: be32
{ $var-description "Signed bit-endian 32-bit." } ;

HELP: be64
{ $var-description "Signed bit-endian 64-bit." } ;

HELP: be8
{ $var-description "Signed bit-endian 8-bit." } ;

HELP: byte-reverse
{ $values
    { "n" integer } { "signed?" boolean }
    { "quot" quotation }
}
{ $description "Reverses the " { $snippet "n" } " bytes in an integer with bitwise operations. The second parameter only works for 1, 2, 4, or 8 byte signed numbers." } ;

HELP: le16
{ $var-description "Signed little-endian 16-bit." } ;

HELP: le32
{ $var-description "Signed little-endian 32-bit." } ;

HELP: le64
{ $var-description "Signed little-endian 64-bit." } ;

HELP: le8
{ $var-description "Signed little-endian 8-bit." } ;

HELP: ube16
{ $var-description "Unsigned big-endian 16-bit." } ;

HELP: ube32
{ $var-description "Unsigned big-endian 32-bit." } ;

HELP: ube64
{ $var-description "Unsigned big-endian 64-bit." } ;

HELP: ube8
{ $var-description "Unsigned big-endian 8-bit." } ;

HELP: ule16
{ $var-description "Unsigned little-endian 16-bit." } ;

HELP: ule32
{ $var-description "Unsigned little-endian 32-bit." } ;

HELP: ule64
{ $var-description "Unsigned little-endian 64-bit." } ;

HELP: ule8
{ $var-description "Unsigned little-endian 8-bit." } ;

ARTICLE: "alien.endian" "Alien endian-aware types"
"The " { $vocab-link "alien.endian" } " vocabulary defines c-types that are endian-aware for use in structs. These types will cause the bytes in a byte-array to be interpreted as little or big-endian transparently when reading or writing. There are both signed and unsigned types defined; signed is the default while unsigned are prefixed with a " { $snippet "u" } ". The intended use-case is for network protocols in network-byte-order (big-endian)." $nl
"Byte-reversal of integers:"
{ $subsections
    byte-reverse
}
"The big-endian c-types are:"
{ $subsections
    be8
    be16
    be32
    be64
    ube8
    ube16
    ube32
    ube64
}
"The little-endian c-types are:"
{ $subsections
    le8
    le16
    le32
    le64
    ule8
    ule16
    ule32
    ule64
} ;

ABOUT: "alien.endian"
