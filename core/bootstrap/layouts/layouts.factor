! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math words kernel alien byte-arrays
hashtables vectors strings sbufs arrays
quotations assocs layouts classes.tuple.private
kernel.private ;

BIN: 111 tag-mask set
8 num-tags set
3 tag-bits set

15 num-types set

32 mega-cache-size set

H{
    { fixnum      BIN: 000 }
    { bignum      BIN: 001 }
    { array       BIN: 010 }
    { float       BIN: 011 }
    { quotation   BIN: 100 }
    { POSTPONE: f BIN: 101 }
    { object      BIN: 110 }
    { hi-tag      BIN: 110 }
    { tuple       BIN: 111 }
} tag-numbers set

tag-numbers get H{
    { wrapper 8 }
    { byte-array 9 }
    { callstack 10 }
    { string 11 }
    { word 12 }
    { dll 13 }
    { alien 14 }
} assoc-union type-numbers set
