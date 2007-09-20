! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences sequences.private
kernel kernel.private math assocs quotations.private ;
IN: quotations

M: wrapper equal?
    over wrapper? [ [ wrapped ] 2apply = ] [ 2drop f ] if ;

UNION: callable quotation curry ;

M: callable equal?
    over callable? [ sequence= ] [ 2drop f ] if ;

: <quotation> ( n -- quot )
    f <array> array>quotation ; inline

M: quotation length quotation-array length ;

M: quotation nth-unsafe quotation-array nth-unsafe ;

: >quotation ( seq -- quot )
    >array array>quotation ; inline

M: quotation like drop dup quotation? [ >quotation ] unless ;

INSTANCE: quotation immutable-sequence

: make-dip ( quot n -- newquot )
    dup \ >r <repetition> -rot \ r> <repetition> 3append
    >quotation ;

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

M: curry like drop [ ] like ;

INSTANCE: curry immutable-sequence
