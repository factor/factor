! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel
USING: arrays generic kernel-internals math namespaces sequences
sequences-internals words ;

: <quotation> ( n -- quot ) f <array> quotation-type become ;

M: wrapper equal?
    over wrapper? [ [ wrapped ] 2apply = ] [ 2drop f ] if ;

M: quotation clone (clone) ;
M: quotation length array-capacity ;
M: quotation nth bounds-check nth-unsafe ;
M: quotation set-nth bounds-check set-nth-unsafe ;
M: quotation nth-unsafe >r >fixnum r> array-nth ;
M: quotation set-nth-unsafe >r >fixnum r> set-array-nth ;

: >quotation ( seq -- quot )
    [ quotation? ] [ <quotation> ] >sequence ; inline

M: quotation like drop dup quotation? [ >quotation ] unless ;

: make-dip ( quot n -- newquot )
    dup \ >r <array> -rot \ r> <array> append3 >quotation ;

: unit ( obj -- quot ) 1array >quotation ;

GENERIC: literalize ( obj -- newobj )
M: object literalize ;
M: word literalize <wrapper> ;
M: wrapper literalize <wrapper> ;

: curry ( obj quot -- newquot )
    [ swap literalize , % ] [ ] make ;

: alist>quot ( default assoc -- quot )
    [ [ first2 swap % , , \ if , ] [ ] make ] each ;
