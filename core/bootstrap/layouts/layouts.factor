! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math words kernel alien byte-arrays
hashtables vectors strings sbufs arrays
quotations assocs layouts classes.tuple.private
kernel.private ;

BIN: 111 tag-mask set
8 num-tags set
3 tag-bits set

17 num-types set

H{
    { fixnum      BIN: 000 }
    { bignum      BIN: 001 }
    { ratio       BIN: 010 }
    { float       BIN: 011 }
    { complex     BIN: 100 }
    { POSTPONE: f BIN: 101 }
    { object      BIN: 110 }
    { hi-tag      BIN: 110 }
    { tuple       BIN: 111 }
} tag-numbers set

tag-numbers get H{
    { array 8 }
    { wrapper 9 }
    { byte-array 10 }
    { callstack 11 }
    { string 12 }
    { word 13 }
    { quotation 14 }
    { dll 15 }
    { alien 16 }
} assoc-union type-numbers set
