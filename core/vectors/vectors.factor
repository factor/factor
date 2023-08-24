! Copyright (C) 2004, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays growable kernel math sequences
sequences.private ;
IN: vectors

TUPLE: vector
{ underlying array }
{ length array-capacity } ;

: <vector> ( n -- vector ) 0 <array> 0 vector boa ; inline

: >vector ( seq -- vector ) V{ } clone-like ;

M: vector like
    drop dup vector? [
        dup array? [ dup length vector boa ] [ >vector ] if
    ] unless ; inline

M: vector new-sequence
    drop [ f <array> ] [ integer>fixnum ] bi vector boa ; inline

M: vector equal?
    over vector? [ sequence= ] [ 2drop f ] if ;

M: array like
    ! If we have an array, we're done.
    ! If we have a vector, and it's at full capacity, we're done.
    ! Otherwise, call resize-array, which is a relatively
    ! fast primitive.
    drop dup array? [
        dup vector? [
            [ length ] [ underlying>> ] bi
            2dup length eq?
            [ nip ] [ resize-array ] if
        ] [ >array ] if
    ] unless ; inline

M: sequence new-resizable drop <vector> ; inline

INSTANCE: vector growable

: 1vector ( x -- vector ) 1array 1 vector boa ; inline

: ?push ( elt seq/f -- seq )
    [ [ push ] keep ] [ 1vector ] if* ;
