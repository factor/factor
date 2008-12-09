! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel kernel.private math sequences
sequences.private growable bit-arrays prettyprint.custom
parser accessors ;
IN: bit-vectors

TUPLE: bit-vector
{ underlying bit-array initial: ?{ } }
{ length array-capacity } ;

: <bit-vector> ( n -- bit-vector )
    <bit-array> 0 bit-vector boa ; inline

: >bit-vector ( seq -- bit-vector )
    T{ bit-vector f ?{ } 0 } clone-like ;

M: bit-vector like
    drop dup bit-vector? [
        dup bit-array?
        [ dup length bit-vector boa ] [ >bit-vector ] if
    ] unless ;

M: bit-vector new-sequence
    drop [ <bit-array> ] [ >fixnum ] bi bit-vector boa ;

M: bit-vector equal?
    over bit-vector? [ sequence= ] [ 2drop f ] if ;

M: bit-array new-resizable drop <bit-vector> ;

INSTANCE: bit-vector growable

: ?V{ \ } [ >bit-vector ] parse-literal ; parsing

M: bit-vector >pprint-sequence ;
M: bit-vector pprint-delims drop \ ?V{ \ } ;
M: bit-vector pprint* pprint-object ;
