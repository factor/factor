! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel kernel.private math sequences
sequences.private growable ;
IN: float-vectors

<PRIVATE

: float-array>vector ( float-array -- float-vector )
    float-vector construct-boa ; inline

PRIVATE>

: <float-vector> ( n -- float-vector )
    <float-array> 0 float-array>vector ; inline

: >float-vector ( seq -- float-vector ) V{ } clone-like ;

M: float-vector like
    drop dup float-vector? [
        dup float-array?
        [ dup length float-array>vector ] [ >float-vector ] if
    ] unless ;

M: float-vector new
    drop [ <float-array> ] keep >fixnum float-array>vector ;

M: float-vector equal?
    over float-vector? [ sequence= ] [ 2drop f ] if ;

INSTANCE: float-vector growable
