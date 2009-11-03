! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math words kernel alien byte-arrays
hashtables vectors strings sbufs arrays
quotations assocs layouts classes.tuple.private
kernel.private ;

16 data-alignment set

BIN: 1111 tag-mask set
4 tag-bits set

14 num-types set

32 mega-cache-size set

H{
    { fixnum 0 }
    { POSTPONE: f 1 }
    { array 2 }
    { float 3 }
    { quotation 4 }
    { bignum 5 }
    { alien 6 }
    { tuple 7 }
    { wrapper 8 }
    { byte-array 9 }
    { callstack 10 }
    { string 11 }
    { word 12 }
    { dll 13 }
} type-numbers set
