! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math words generic kernel alien byte-arrays
hashtables vectors strings sbufs arrays bit-arrays quotations
assocs ;

BIN: 111 tag-mask set
8 num-tags set
3 tag-bits set

20 num-types set

H{
    { fixnum  BIN: 000 }
    { bignum  BIN: 001 }
    { word    BIN: 010 }
    { object  BIN: 011 }
    { ratio   BIN: 100 }
    { float   BIN: 101 }
    { complex BIN: 110 }
    { wrapper BIN: 111 }
} tag-numbers set

tag-numbers get H{
    { array      8  }
    { hashtable  10 }
    { vector     11 }
    { string     12 }
    { sbuf       13 }
    { quotation  14 }
    { dll        15 }
    { alien      16 }
    { tuple      17 }
    { byte-array 18 }
    { bit-array  19 }
} union type-numbers set
