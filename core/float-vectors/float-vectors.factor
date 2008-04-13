! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel kernel.private math sequences
sequences.private growable float-arrays ;
IN: float-vectors

<PRIVATE

: float-array>vector ( float-array length -- float-vector )
    float-vector construct-boa ; inline

PRIVATE>

: <float-vector> ( n -- float-vector )
    0.0 <float-array> 0 float-array>vector ; inline

: >float-vector ( seq -- float-vector ) FV{ } clone-like ;

M: float-vector like
    drop dup float-vector? [
        dup float-array?
        [ dup length float-array>vector ] [ >float-vector ] if
    ] unless ;

M: float-vector new-sequence
    drop [ 0.0 <float-array> ] keep >fixnum float-array>vector ;

M: float-vector equal?
    over float-vector? [ sequence= ] [ 2drop f ] if ;

M: float-array new-resizable drop <float-vector> ;

INSTANCE: float-vector growable
