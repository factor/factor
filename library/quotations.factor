! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel
USING: arrays generic kernel-internals math namespaces sequences
sequences-internals words ;

M: wrapper equal?
    over wrapper? [ [ wrapped ] 2apply = ] [ 2drop f ] if ;

M: quotation clone (clone) ;
M: quotation length array-capacity ;
M: quotation nth bounds-check nth-unsafe ;
M: quotation set-nth bounds-check set-nth-unsafe ;
M: quotation nth-unsafe >r >fixnum r> array-nth ;
M: quotation set-nth-unsafe >r >fixnum r> set-array-nth ;

: >quotation ( seq -- array )
    [ quotation? ] [ <quotation> ] >sequence ; inline

M: quotation like drop dup quotation? [ >quotation ] unless ;

: make-dip ( quot n -- quot )
    dup \ >r <array> -rot \ r> <array> append3 >quotation ;

: unit ( a -- [ a ] ) 1array >quotation ;

GENERIC: literalize ( obj -- obj )
M: object literalize ;
M: word literalize <wrapper> ;
M: wrapper literalize <wrapper> ;

: curry ( obj quot -- quot ) swap literalize add* ;

: alist>quot ( default alist -- quot )
    [ [ first2 swap % , , \ if , ] [ ] make ] each ;
