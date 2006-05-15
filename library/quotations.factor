! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel
USING: arrays kernel-internals lists math namespaces sequences
sequences-internals ;

UNION: quotation general-list ;

: >quotation >list ;

: make-dip ( quot n -- quot )
    dup \ >r <array> -rot \ r> <array> append3 >quotation ;

: unit ( a -- [ a ] ) 1array >quotation ;

: curry ( obj quot -- quot ) >r unit r> append ;

: alist>quot ( default alist -- quot )
    [ [ first2 swap % , , \ if , ] [ ] make ] each ;

! M: quotation clone (clone) ;
! M: quotation length array-capacity ;
! M: quotation nth bounds-check nth-unsafe ;
! M: quotation set-nth bounds-check set-nth-unsafe ;
! M: quotation nth-unsafe >r >fixnum r> array-nth ;
! M: quotation set-nth-unsafe >r >fixnum r> set-array-nth ;
! M: quotation resize resize-array ;
! 
! : >quotation ( seq -- array ) [ <quotation> ] >sequence ; inline
! 
! M: quotation like drop dup quotation? [ >quotation ] unless ;
