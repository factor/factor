! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: math math-internals kernel ;

! Power-related functions:
!     exp log sqrt pow

: exp >rect swap fexp swap polar> ;
: log >polar swap flog swap rect> ;

: sqrt ( z -- sqrt )
    >polar dup pi = [
        drop fsqrt 0 swap rect>
    ] [
        swap fsqrt swap 2 / polar>
    ] ifte ;

: ^mag ( w abs arg -- magnitude )
    >r >r >rect swap r> swap fpow r> rot * fexp / ;

: ^theta ( w abs arg -- theta )
    >r >r >rect r> flog * swap r> * + ;

: ^ ( z w -- z^w )
    over real? over integer? and [
        fpow
    ] [
        swap >polar 3dup ^theta >r ^mag r> polar>
    ] ifte ;
