! Copyright (C) 2007, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien arrays byte-arrays kernel layouts math namespaces
quotations strings words ;

16 data-alignment set

0b1111 tag-mask set
4 tag-bits set

32 mega-cache-size set

! Type tags, should be kept in sync with:
!   vm/layouts.hpp
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

14 num-types set

2 header-bits set
