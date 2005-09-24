! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: errors generic kernel math-internals ;

! Math operations
G: number= ( x y -- ? ) math-combination ; foldable
M: object number= 2drop f ;

G: <  ( x y -- ? ) math-combination ; foldable
G: <= ( x y -- ? ) math-combination ; foldable
G: >  ( x y -- ? ) math-combination ; foldable
G: >= ( x y -- ? ) math-combination ; foldable

G: +   ( x y -- x+y ) math-combination ; foldable
G: -   ( x y -- x-y ) math-combination ; foldable
G: *   ( x y -- x*y ) math-combination ; foldable
G: /   ( x y -- x/y ) math-combination ; foldable
G: /i  ( x y -- x/y ) math-combination ; foldable
G: /f  ( x y -- x/y ) math-combination ; foldable
G: mod ( x y -- x%y ) math-combination ; foldable

G: /mod ( x y -- x/y x%y ) math-combination ; foldable

G: bitand ( x y -- z ) math-combination ; foldable
G: bitor  ( x y -- z ) math-combination ; foldable
G: bitxor ( x y -- z ) math-combination ; foldable
G: shift  ( x n -- y ) math-combination ; foldable

GENERIC: 1+ ( x -- x+1 ) foldable
GENERIC: 1- ( x -- x-1 ) foldable

GENERIC: bitnot ( n -- n ) foldable

GENERIC: truncate ( n -- n ) foldable
GENERIC: floor    ( n -- n ) foldable
GENERIC: ceiling  ( n -- n ) foldable

: max ( x y -- z ) [ > ] 2keep ? ; inline
: min ( x y -- z ) [ < ] 2keep ? ; inline

: between? ( x min max -- ? )
    #! Push if min <= x <= max. Handles case where min > max
    #! by swapping them.
    2dup > [ swap ] when  >r dupd max r> min = ; foldable

: sq dup * ; inline

: neg 0 swap - ; inline
: recip 1 swap / ; inline

: rem ( x y -- x%y )
    #! Like modulus, but always gives a positive result.
    [ mod ] keep  over 0 < [ + ] [ drop ] if ; inline

: sgn ( n -- -1/0/1 )
    #! Push the sign of a real number.
    dup 0 = [ drop 0 ] [ 1 < -1 1 ? ] if ; foldable

GENERIC: abs ( z -- |z| ) foldable
GENERIC: absq ( n -- |n|^2 ) foldable

: align ( offset width -- offset )
    2dup mod dup 0 number= [ 2drop ] [ - + ] if ; inline

: (repeat) ( i n quot -- )
    pick pick >=
    [ 3drop ] [ [ swap >r call 1+ r> ] keep (repeat) ] if ;
    inline

: repeat ( n quot -- | quot: n -- n )
    #! The loop counter is kept on the stack, and ranges from
    #! 0 to n-1.
    0 -rot (repeat) ; inline

: times ( n quot -- | quot: -- )
    swap [ >r dup slip r> ] repeat drop ; inline

: power-of-2? ( n -- ? )
    dup 0 > [
        dup dup neg bitand =
    ] [
        drop f
    ] if ; foldable

: log2 ( n -- b )
    #! Log base two for integers.
    dup 0 <= [
        "Input must be positive" throw
    ] [
        dup 1 = [ drop 0 ] [ 2 /i log2 1+ ] if
    ] if ; foldable

GENERIC: number>string ( str -- num ) foldable
