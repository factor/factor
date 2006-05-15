! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: kernel
USING: arrays lists namespaces sequences ;

UNION: quotation general-list ;

: >quotation >list ;

: make-dip ( quot n -- quot )
    dup \ >r <array> -rot \ r> <array> append3 >quotation ;

: unit ( a -- [ a ] ) 1array >quotation ;

: curry ( obj quot -- quot ) >r unit r> append ;

: alist>quot ( default alist -- quot )
    [ [ first2 swap % , , \ if , ] [ ] make ] each ;
