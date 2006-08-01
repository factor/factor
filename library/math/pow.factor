! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: math
USING: errors kernel math math-internals ;

: exp >rect swap fexp swap polar> ; inline
: log >polar swap flog swap rect> ; inline

GENERIC: sqrt ( n -- n ) foldable

M: complex sqrt >polar swap fsqrt swap 2 / polar> ;
M: real sqrt dup 0 < [ neg fsqrt 0 swap rect> ] [ fsqrt ] if ;

GENERIC: (^) ( z w -- z^w ) foldable

: ^ ( z w -- z^w )
    over zero? [
        dup zero?
        [ 2drop 0.0/0.0 ] [ 0 < [ drop 1.0/0.0 ] when ] if
     ] [
         (^)
     ] if ; inline

: ^mag ( w abs arg -- magnitude )
    >r >r >rect swap r> swap fpow r> rot * fexp / ; inline

: ^theta ( w abs arg -- theta )
    >r >r >rect r> flog * swap r> * + ; inline

M: number (^) ( z w -- z^w )
    swap >polar 3dup ^theta >r ^mag r> polar> ;

: ^n ( z w -- z^w )
    {
        { [ dup zero? ] [ 2drop 1 ] }
        { [ dup 1 number= ] [ drop ] }
        { [ t ] [ over sq over 2 /i ^n -rot 2 mod ^n * ] }
    } cond ; inline

M: integer (^) ( z w -- z^w )
    dup 0 < [ neg ^n recip ] [ ^n ] if ;

: power-of-2? ( n -- ? )
    dup 0 > [
        dup dup neg bitand =
    ] [
        drop f
    ] if ; foldable

: log2 ( n -- b )
    {
        { [ dup 0 <= ] [ "log2 expects positive inputs" throw ] }
        { [ dup 1 = ] [ drop 0 ] }
        { [ t ] [ -1 shift log2 1+ ] }
    } cond ; foldable
