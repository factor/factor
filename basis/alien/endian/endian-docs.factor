! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math quotations
classes.struct ;
IN: alien.endian

HELP: BE-PACKED-STRUCT:
{ $description "Defines a packed " { $link struct } " where endian-unaware types become big-endian types. Note that endian-aware types will override the big-endianness of this " { $link struct } " declaration; little-endian types will stay little-endian. On big-endian platforms, the endian-unaware types will not change since they are the correct endianness already." }
{ $unchecked-example
    "! When run on a big-endian platform, this struct should prettyprint the same as defined"
    "! The output of this example is from a little-endian platform"
    "USE: alien.endian"
    "BE-PACKED-STRUCT: s1 { a char[7] } { b int } ;"
    "\\ s1 see"
    "USING: alien.c-types alien.endian classes.struct ;
IN: scratchpad
STRUCT: s1 { a char[7] } { b be32 initial: 0 } ;"
} ;

HELP: BE-STRUCT:
{ $description "Defines a " { $link struct } " where endian-unaware types become big-endian types. Note that endian-aware types will override the big-endianness of this " { $link struct } " declaration; little-endian types will stay little-endian. On big-endian platforms, the endian-unaware types will not change since they are the correct endianness already." }
{ $unchecked-example
    "! When run on a big-endian platform, this struct should prettyprint the same as defined"
    "! The output of this example is from a little-endian platform"
    "USE: alien.endian"
    "BE-STRUCT: s1 { a int } { b le32 } ;"
    "\\ s1 see"
    "USING: alien.c-types alien.endian classes.struct ;
IN: scratchpad
STRUCT: s1 { a be32 initial: 0 } { b le32 initial: 0 } ;"
} ;

HELP: LE-PACKED-STRUCT:
{ $description "Defines a packed " { $link struct } " where endian-unaware types become little-endian types. Note that endian-aware types will override the little-endianness of this " { $link struct } " declaration; big-endian types will stay big-endian. On little-endian platforms, the endian-unaware types will not change since they are the correct endianness already." }
{ $unchecked-example
    "! When run on a little-endian platform, this struct should prettyprint the same as defined"
    "! The output of this example is from a little-endian platform"
    "USE: alien.endian"
    "LE-PACKED-STRUCT: s1 { a char[7] } { b int } ;"
    "\\ s1 see"
    "USING: alien.c-types alien.endian classes.struct ;
IN: scratchpad
STRUCT: s1 { a char[7] } { b int initial: 0 } ;"
} ;

HELP: LE-STRUCT:
{ $description "Defines a " { $link struct } " where endian-unaware types become little-endian types. Note that endian-aware types will override the little-endianness of this " { $link struct } " declaration; big-endian types will stay big-endian. On little-endian platforms, the endian-unaware types will not change since they are the correct endianness already." }
{ $unchecked-example
    "! When run on a little-endian platform, this struct should prettyprint the same as defined"
    "! The output of this example is from a little-endian platform"
    "USE: alien.endian"
    "LE-STRUCT: s1 { a int } { b be32 } ;"
    "\\ s1 see"
    "USING: alien.c-types alien.endian classes.struct ;
IN: scratchpad
STRUCT: s1 { a int initial: 0 } { b be32 initial: 0 } ;"
} ;

HELP: be16
{ $var-description "Signed bit-endian 16-bit." } ;

HELP: be32
{ $var-description "Signed bit-endian 32-bit." } ;

HELP: be64
{ $var-description "Signed bit-endian 64-bit." } ;

HELP: be8
{ $var-description "Signed bit-endian 8-bit." } ;

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
}
"Syntax for making endian-aware structs out of native types:"
{ $subsections
    POSTPONE: LE-STRUCT:
    POSTPONE: BE-STRUCT:
    POSTPONE: LE-PACKED-STRUCT:
    POSTPONE: BE-PACKED-STRUCT:
} ;

ABOUT: "alien.endian"
