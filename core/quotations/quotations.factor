! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays sequences sequences.private
kernel kernel.private math assocs quotations.private
slots.private ;
IN: quotations

<PRIVATE

: uncurry ( curry -- obj quot )
    dup 2 slot swap 3 slot ; inline

: uncompose ( compose -- quot quot2 )
    dup 2 slot swap 3 slot ; inline

PRIVATE>

M: quotation call (call) ;

M: curry call uncurry call ;

M: compose call uncompose [ call ] dip call ;

M: wrapper equal?
    over wrapper? [ [ wrapped>> ] bi@ = ] [ 2drop f ] if ;

UNION: callable quotation curry compose ;

M: callable equal?
    over callable? [ sequence= ] [ 2drop f ] if ;

M: quotation length array>> length ;

M: quotation nth-unsafe array>> nth-unsafe ;

: >quotation ( seq -- quot )
    >array array>quotation ; inline

M: callable like drop dup quotation? [ >quotation ] unless ;

INSTANCE: quotation immutable-sequence

: 1quotation ( obj -- quot ) 1array >quotation ;

GENERIC: literalize ( obj -- wrapped )

M: object literalize ;

M: wrapper literalize <wrapper> ;

M: curry length quot>> length 1 + ;

M: curry nth
    over 0 =
    [ nip obj>> literalize ]
    [ [ 1 - ] dip quot>> nth ]
    if ;

INSTANCE: curry immutable-sequence

M: compose length
    [ first>> length ] [ second>> length ] bi + ;

M: compose virtual-seq first>> ;

M: compose virtual@
    2dup first>> length < [
        first>>
    ] [
        [ first>> length - ] [ second>> ] bi
    ] if ;

INSTANCE: compose virtual-sequence
