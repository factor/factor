! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel kernel.private math sequences
sequences.private growable bit-arrays ;
IN: bit-vectors

<PRIVATE

: bit-array>vector ( bit-array length -- bit-vector )
    bit-vector construct-boa ; inline

PRIVATE>

: <bit-vector> ( n -- bit-vector )
    <bit-array> 0 bit-array>vector ; inline

: >bit-vector ( seq -- bit-vector ) V{ } clone-like ;

M: bit-vector like
    drop dup bit-vector? [
        dup bit-array?
        [ dup length bit-array>vector ] [ >bit-vector ] if
    ] unless ;

M: bit-vector new
    drop [ <bit-array> ] keep >fixnum bit-array>vector ;

M: bit-vector equal?
    over bit-vector? [ sequence= ] [ 2drop f ] if ;

INSTANCE: bit-vector growable
