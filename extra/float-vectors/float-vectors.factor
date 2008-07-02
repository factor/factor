! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel kernel.private math sequences
sequences.private growable float-arrays prettyprint.backend
parser accessors ;
IN: float-vectors

TUPLE: float-vector
{ underlying float-array }
{ length array-capacity } ;

: <float-vector> ( n -- float-vector )
    0.0 <float-array> 0 float-vector boa ; inline

: >float-vector ( seq -- float-vector )
    T{ float-vector f F{ } 0 } clone-like ;

M: float-vector like
    drop dup float-vector? [
        dup float-array?
        [ dup length float-vector boa ] [ >float-vector ] if
    ] unless ;

M: float-vector new-sequence
    drop [ 0.0 <float-array> ] [ >fixnum ] bi float-vector boa ;

M: float-vector equal?
    over float-vector? [ sequence= ] [ 2drop f ] if ;

M: float-array new-resizable drop <float-vector> ;

INSTANCE: float-vector growable

: FV{ \ } [ >float-vector ] parse-literal ; parsing

M: float-vector >pprint-sequence ;

M: float-vector pprint-delims drop \ FV{ \ } ;
