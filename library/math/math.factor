! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: errors generic kernel math-internals ;

! Math operations
2GENERIC: number= ( x y -- ? )
M: object number= 2drop f ;

2GENERIC: <  ( x y -- ? )
2GENERIC: <= ( x y -- ? )
2GENERIC: >  ( x y -- ? )
2GENERIC: >= ( x y -- ? )

2GENERIC: +   ( x y -- x+y )
2GENERIC: -   ( x y -- x-y )
2GENERIC: *   ( x y -- x*y )
2GENERIC: /   ( x y -- x/y )
2GENERIC: /i  ( x y -- x/y )
2GENERIC: /f  ( x y -- x/y )
2GENERIC: mod ( x y -- x%y )

2GENERIC: /mod ( x y -- x/y x%y )

2GENERIC: bitand ( x y -- z )
2GENERIC: bitor  ( x y -- z )
2GENERIC: bitxor ( x y -- z )
2GENERIC: shift  ( x n -- y )

GENERIC: bitnot ( n -- n )

GENERIC: truncate ( n -- n )
GENERIC: floor    ( n -- n )
GENERIC: ceiling  ( n -- n )

: max ( x y -- z ) [ > ] 2keep ? ;

: min ( x y -- z ) [ < ] 2keep ? ;

: between? ( x min max -- ? )
    #! Push if min <= x <= max. Handles case where min > max
    #! by swapping them.
    2dup > [ swap ] when  >r dupd max r> min = ;

: sq dup * ;

: neg 0 swap - ;
: recip 1 swap / ;

: rem ( x y -- x%y )
    #! Like modulus, but always gives a positive result.
    [ mod ] keep  over 0 < [ + ] [ drop ] ifte ;

: sgn ( n -- -1/0/1 )
    #! Push the sign of a real number.
    dup 0 = [ drop 0 ] [ 1 < -1 1 ? ] ifte ;

GENERIC: abs ( z -- |z| )

: align ( offset width -- offset )
    2dup mod dup 0 number= [ 2drop ] [ - + ] ifte ;

: (repeat) ( i n quot -- )
    pick pick >= [
        3drop
    ] [
        [ swap >r call 1 + r> ] keep (repeat)
    ] ifte ; inline

: repeat ( n quot -- )
    #! Execute a quotation n times. The loop counter is kept on
    #! the stack, and ranges from 0 to n-1.
    0 -rot (repeat) ; inline

: times ( n quot -- )
    #! Evaluate a quotation n times.
    swap [ >r dup slip r> ] repeat drop ; inline

: 2repeat ( i j quot -- | quot: i j -- i j )
    rot [
        rot [ [ rot dup slip -rot ] repeat ] keep -rot
    ] repeat 2drop ; inline

: power-of-2? ( n -- ? ) dup dup neg bitand = ;
