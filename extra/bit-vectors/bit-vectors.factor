! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel kernel.private math sequences
sequences.private growable bit-arrays prettyprint.backend
parser accessors ;
IN: bit-vectors

TUPLE: bit-vector
{ underlying bit-array }
{ length array-capacity } ;

<PRIVATE

: bit-array>vector ( bit-array length -- bit-vector )
    bit-vector boa ; inline

PRIVATE>

: <bit-vector> ( n -- bit-vector )
    <bit-array> 0 bit-array>vector ; inline

: >bit-vector ( seq -- bit-vector )
    T{ bit-vector f ?{ } 0 } clone-like ;

M: bit-vector like
    drop dup bit-vector? [
        dup bit-array?
        [ dup length bit-array>vector ] [ >bit-vector ] if
    ] unless ;

M: bit-vector new-sequence
    drop [ <bit-array> ] keep >fixnum bit-array>vector ;

M: bit-vector equal?
    over bit-vector? [ sequence= ] [ 2drop f ] if ;

M: bit-array new-resizable drop <bit-vector> ;

INSTANCE: bit-vector growable

: ?V{ \ } [ >bit-vector ] parse-literal ; parsing

M: bit-vector >pprint-sequence ;

M: bit-vector pprint-delims drop \ ?V{ \ } ;
