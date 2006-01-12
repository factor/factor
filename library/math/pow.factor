! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: math
USING: errors kernel math math-internals ;

: exp >rect swap fexp swap polar> ; inline
: log >polar swap flog swap rect> ; inline

GENERIC: sqrt ( n -- n ) foldable

M: complex sqrt >polar swap fsqrt swap 2 / polar> ;
M: real sqrt dup 0 < [ neg fsqrt 0 swap rect> ] [ fsqrt ] if ;

GENERIC: ^ ( z w -- z^w ) foldable

: ^mag ( w abs arg -- magnitude )
    >r >r >rect swap r> swap fpow r> rot * fexp / ; inline

: ^theta ( w abs arg -- theta )
    >r >r >rect r> flog * swap r> * + ; inline

M: number ^ ( z w -- z^w )
    swap >polar 3dup ^theta >r ^mag r> polar> ;

: each-bit ( n quot -- | quot: 0/1 -- )
    over 0 number= pick -1 number= or [
        2drop
    ] [
        2dup >r >r >r 1 bitand r> call r> -1 shift r> each-bit
    ] if ; inline

: (integer^) ( z w -- z^w )
    1 swap [ 1 number= [ dupd * ] when >r sq r> ] each-bit nip ;
    inline

M: integer ^ ( z w -- z^w )
    over 0 number= over 0 number= and [
        "0^0 is not defined" throw
    ] [
        dup 0 < [ neg ^ recip ] [ (integer^) ] if
    ] if ;

: power-of-2? ( n -- ? )
    dup 0 > [
        dup dup neg bitand =
    ] [
        drop f
    ] if ; foldable

: log2 ( n -- b )
    {
        { [ dup 0 <= ] [ "Input must be positive" throw ] }
        { [ dup 1 = ] [ drop 0 ] }
        { [ t ] [ -1 shift log2 1+ ] }
    } cond ; foldable
