! Copyright (C) 2006, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel kernel.private math sequences
sequences.private slots.private ;
IN: quotations

BUILTIN: quotation
    { array array read-only initial: { } }
    cached-effect
    cache-counter ;

PRIMITIVE: jit-compile ( quot -- )
PRIMITIVE: quotation-code ( quot -- start end )
PRIMITIVE: quotation-compiled? ( quot -- ? )

<PRIVATE
PRIMITIVE: array>quotation ( array -- quot )

: uncurry ( curry -- obj quot )
    { curried } declare dup 2 slot swap 3 slot ; inline

: uncompose ( compose -- quot quot2 )
    { composed } declare dup 2 slot swap 3 slot ; inline

PRIVATE>

M: quotation call (call) ;

M: curried call uncurry call ;

M: composed call uncompose [ call ] dip call ;

M: wrapper equal?
    over wrapper? [ [ wrapped>> ] same? ] [ 2drop f ] if ;

UNION: callable quotation curried composed ;

M: callable equal?
    over callable? [ sequence= ] [ 2drop f ] if ;

M: quotation length array>> length ;

M: quotation nth-unsafe array>> nth-unsafe ;

: >quotation ( seq -- quot )
    >array array>quotation ; inline

M: callable like drop dup quotation? [ >quotation ] unless ;

INSTANCE: quotation immutable-sequence

: 1quotation ( obj -- quot ) 1array array>quotation ;

GENERIC: literalize ( obj -- wrapped )

M: object literalize ;

M: wrapper literalize <wrapper> ;

M: curried length quot>> length 1 + ;

M: curried nth
    over 0 =
    [ nip obj>> literalize ]
    [ [ 1 - ] dip quot>> nth ]
    if ;

INSTANCE: curried immutable-sequence

M: composed length
    [ first>> length ] [ second>> length ] bi + ;

M: composed virtual-exemplar first>> ;

M: composed virtual@
    2dup first>> length < [
        first>>
    ] [
        [ first>> length - ] [ second>> ] bi
    ] if ;

INSTANCE: composed virtual-sequence

: compose-all ( seq -- quot )
    [ ] [ compose ] reduce ; inline
