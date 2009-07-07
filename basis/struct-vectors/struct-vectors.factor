! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types byte-arrays growable kernel math sequences
sequences.private struct-arrays ;
IN: struct-vectors

TUPLE: struct-vector
{ underlying struct-array }
{ length array-capacity }
{ c-type read-only } ;

: <struct-vector> ( capacity c-type -- struct-vector )
    [ <struct-array> 0 ] keep struct-vector boa ; inline

M: struct-vector byte-length underlying>> byte-length ;
M: struct-vector new-sequence
    [ c-type>> <struct-array> ] [ [ >fixnum ] [ c-type>> ] bi* ] 2bi
    struct-vector boa ;

M: struct-vector contract 2drop ;

M: struct-array new-resizable c-type>> <struct-vector> ;

INSTANCE: struct-vector growable
