! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: quotations
USING: arrays generic sequences sequences-internals
words kernel kernel-internals math ;

M: wrapper equal?
    over wrapper? [ [ wrapped ] 2apply = ] [ 2drop f ] if ;

M: quotation clone (clone) ;

M: quotation length array-capacity ;

M: quotation nth bounds-check nth-unsafe ;

M: quotation set-nth bounds-check set-nth-unsafe ;

M: quotation nth-unsafe >r >fixnum r> array-nth ;

M: quotation set-nth-unsafe >r >fixnum r> set-array-nth ;

M: quotation new drop <quotation> ;

M: quotation equal?
    over quotation? [ sequence= ] [ 2drop f ] if ;

: >quotation ( seq -- quot ) [ ] clone-like ; inline

M: quotation like drop dup quotation? [ >quotation ] unless ;

: make-dip ( quot n -- newquot )
    dup \ >r <array> -rot \ r> <array> 3append >quotation ;

: 1quotation ( obj -- quot ) [ ] singleton ;

GENERIC: literalize ( obj -- wrapped )
M: object literalize ;
M: word literalize <wrapper> ;
M: wrapper literalize <wrapper> ;

: curry ( obj quot -- newquot )
    swap literalize add* [ ] like ;

: alist>quot ( default assoc -- quot )
    [ first2 rot \ if 3array append [ ] like ] each ;
