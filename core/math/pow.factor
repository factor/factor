! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: math
USING: errors kernel math math-internals ;

: exp ( x -- y ) >rect swap fexp swap polar> ; inline
: log ( x -- y ) >polar swap flog swap rect> ; inline

GENERIC: sqrt ( x -- y ) foldable

M: complex sqrt >polar swap fsqrt swap 2.0 / polar> ;

M: real sqrt
    >float dup 0.0 < [ neg fsqrt 0.0 swap rect> ] [ fsqrt ] if ;

GENERIC: (^) ( x y -- z ) foldable

: ^ ( x y -- z )
    over zero? [
        dup zero?
        [ 2drop 0.0/0.0 ] [ 0 < [ drop 1.0/0.0 ] when ] if
    ] [
        (^)
    ] if ; inline

: ^mag ( w abs arg -- magnitude )
    >r >r >float-rect swap r> swap fpow r> rot * fexp /f ;
    inline

: ^theta ( w abs arg -- theta )
    >r >r >float-rect r> flog * swap r> * + ; inline

M: number (^)
    swap >polar 3dup ^theta >r ^mag r> polar> ;

: ^n ( z w -- z^w )
    {
        { 0 [ drop 1 ] }
        { 1 [ ] }
        [ over sq over 2/ ^n -rot 1 bitand ^n * ]
    } case ; inline

M: integer (^)
    dup 0 < [ neg ^n recip ] [ ^n ] if ;

: log2 ( n -- b )
    {
        { [ dup 0 <= ] [ "log2 expects positive inputs" throw ] }
        { [ dup 1 number= ] [ drop 0 ] }
        { [ t ] [ -1 shift log2 1+ ] }
    } cond ; foldable
