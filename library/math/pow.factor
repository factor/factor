! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: errors kernel math math-internals ;

! Power-related functions:
!     exp log sqrt pow ^mod

: exp >rect swap fexp swap polar> ; inline
: log >polar swap flog swap rect> ; inline

: sqrt ( z -- sqrt )
    >polar dup pi = [
        drop fsqrt 0 swap rect>
    ] [
        swap fsqrt swap 2 / polar>
    ] ifte ; foldable

: norm ( vec -- n ) norm-sq sqrt ;

: normalize ( vec -- vec ) dup norm v/n ;

GENERIC: ^ ( z w -- z^w ) foldable

: ^mag ( w abs arg -- magnitude )
    >r >r >rect swap r> swap fpow r> rot * fexp / ; inline

: ^theta ( w abs arg -- theta )
    >r >r >rect r> flog * swap r> * + ; inline

M: number ^ ( z w -- z^w )
    swap >polar 3dup ^theta >r ^mag r> polar> ;

: each-bit ( n quot -- | quot: 0/1 -- )
    #! Apply the quotation to each bit of the number. The number
    #! must be positive.
    over 0 number= [
        2drop
    ] [
        2dup >r >r >r 1 bitand r> call r> -1 shift r> each-bit
    ] ifte ; inline

: (integer^) ( z w -- z^w )
    1 swap [ 1 number= [ dupd * ] when >r sq r> ] each-bit nip ;
    inline

M: integer ^ ( z w -- z^w )
    over 0 number= over 0 number= and [
        "0^0 is not defined" throw
    ] [
        dup 0 < [ neg ^ recip ] [ (integer^) ] ifte
    ] ifte ; foldable

: (^mod) ( n z w -- z^w )
    1 swap [
        1 number= [ dupd * pick mod ] when >r sq over mod r>
    ] each-bit 2nip ; inline

: ^mod ( z w n -- z^w )
    #! Compute z^w mod n.
    over 0 < [
        [ >r neg r> ^mod ] keep mod-inv
    ] [
        -rot (^mod)
    ] ifte ; foldable
