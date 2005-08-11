! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: errors generic kernel math-internals ;

! Math operations
G: number= ( x y -- ? ) [ ] [ arithmetic-type ] ;
M: object number= 2drop f ;

G: <  ( x y -- ? ) [ ] [ arithmetic-type ] ;
G: <= ( x y -- ? ) [ ] [ arithmetic-type ] ;
G: >  ( x y -- ? ) [ ] [ arithmetic-type ] ;
G: >= ( x y -- ? ) [ ] [ arithmetic-type ] ;

G: +   ( x y -- x+y ) [ ] [ arithmetic-type ] ;
G: -   ( x y -- x-y ) [ ] [ arithmetic-type ] ;
G: *   ( x y -- x*y ) [ ] [ arithmetic-type ] ;
G: /   ( x y -- x/y ) [ ] [ arithmetic-type ] ;
G: /i  ( x y -- x/y ) [ ] [ arithmetic-type ] ;
G: /f  ( x y -- x/y ) [ ] [ arithmetic-type ] ;
G: mod ( x y -- x%y ) [ ] [ arithmetic-type ] ;

G: /mod ( x y -- x/y x%y ) [ ] [ arithmetic-type ] ;

G: bitand ( x y -- z ) [ ] [ arithmetic-type ] ;
G: bitor  ( x y -- z ) [ ] [ arithmetic-type ] ;
G: bitxor ( x y -- z ) [ ] [ arithmetic-type ] ;
G: shift  ( x n -- y ) [ ] [ arithmetic-type ] ;

GENERIC: bitnot ( n -- n )

GENERIC: truncate ( n -- n )
GENERIC: floor    ( n -- n )
GENERIC: ceiling  ( n -- n )

: max ( x y -- z ) [ > ] 2keep ? ; inline
: min ( x y -- z ) [ < ] 2keep ? ; inline

: between? ( x min max -- ? )
    #! Push if min <= x <= max. Handles case where min > max
    #! by swapping them.
    2dup > [ swap ] when  >r dupd max r> min = ;

: sq dup * ; inline

: neg 0 swap - ; inline
: recip 1 swap / ; inline

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
    pick pick >=
    [ 3drop ] [ [ swap >r call 1 + r> ] keep (repeat) ] ifte ;
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
    ] ifte ;

: log2 ( n -- b )
    #! Log base two for integers.
    dup 0 <= [
        "Input must be positive" throw
    ] [
        dup 1 = [ drop 0 ] [ 2 /i log2 1 + ] ifte
    ] ifte ;
