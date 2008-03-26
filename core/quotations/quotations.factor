! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences sequences.private
kernel kernel.private math assocs quotations.private
slots.private ;
IN: quotations

M: quotation call (call) ;

M: curry call dup 3 slot swap 4 slot call ;

M: compose call dup 3 slot swap 4 slot slip call ;

M: wrapper equal?
    over wrapper? [ [ wrapped ] 2apply = ] [ 2drop f ] if ;

UNION: callable quotation curry compose ;

M: callable equal?
    over callable? [ sequence= ] [ 2drop f ] if ;

M: quotation length quotation-array length ;

M: quotation nth-unsafe quotation-array nth-unsafe ;

: >quotation ( seq -- quot )
    >array array>quotation ; inline

M: callable like drop dup quotation? [ >quotation ] unless ;

INSTANCE: quotation immutable-sequence

: 1quotation ( obj -- quot ) 1array >quotation ;

GENERIC: literalize ( obj -- wrapped )

M: object literalize ;

M: wrapper literalize <wrapper> ;

M: curry length curry-quot length 1+ ;

M: curry nth
    over zero? [
        nip curry-obj literalize
    ] [
        >r 1- r> curry-quot nth
    ] if ;

INSTANCE: curry immutable-sequence

M: compose length
    dup compose-first length
    swap compose-second length + ;

M: compose nth
    2dup compose-first length < [
        compose-first
    ] [
        [ compose-first length - ] keep compose-second
    ] if nth ;

INSTANCE: compose immutable-sequence
