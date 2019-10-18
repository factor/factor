! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays sequences sequences.private
kernel kernel.private math assocs ;
IN: quotations

UNION: callable POSTPONE: f quotation curry ;

M: wrapper equal?
    over wrapper? [ [ wrapped ] 2apply = ] [ 2drop f ] if ;

M: quotation clone (clone) ;

M: quotation length array-capacity ;

M: quotation nth-unsafe >r >fixnum r> array-nth ;

M: quotation set-nth-unsafe >r >fixnum r> set-array-nth ;

M: quotation new drop <quotation> ;

M: quotation equal?
    over quotation? pick curry? or
    [ sequence= ] [ 2drop f ] if ;

: >quotation ( seq -- quot ) [ ] clone-like ; inline

M: quotation like drop dup quotation? [ >quotation ] unless ;

INSTANCE: quotation sequence

: make-dip ( quot n -- newquot )
    dup \ >r <repetition> -rot \ r> <repetition> 3append
    >quotation ;

: 1quotation ( obj -- quot ) [ ] 1sequence ;

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

M: curry set-nth immutable ;

M: curry new drop <quotation> ;

M: curry equal?
    over quotation? pick curry? or
    [ sequence= ] [ 2drop f ] if ;

M: curry like
    drop [ ] like ;

INSTANCE: curry sequence
