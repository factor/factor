! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math sequences sequences.private growable
accessors ;
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
    drop [ f <array> ] [ >fixnum ] bi vector boa ; inline

M: vector equal?
    over vector? [ sequence= ] [ 2drop f ] if ;

M: array like
    #! If we have an array, we're done.
    #! If we have a vector, and it's at full capacity, we're done.
    #! Otherwise, call resize-array, which is a relatively
    #! fast primitive.
    drop dup array? [
        dup vector? [
            [ length ] [ underlying>> ] bi
            2dup length eq?
            [ nip ] [ resize-array ] if
        ] [ >array ] if
    ] unless ; inline

M: sequence new-resizable drop <vector> ; inline

INSTANCE: vector growable

: 1vector ( x -- vector ) V{ } 1sequence ;

: ?push ( elt seq/f -- seq )
    [ 1 <vector> ] unless* [ push ] keep ;
