! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: math
USING: errors generic kernel math-internals ;

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

GENERIC: bitnot ( n -- n ) foldable

GENERIC: 1+ ( x -- x+1 ) foldable
GENERIC: 1- ( x -- x-1 ) foldable
GENERIC: abs ( z -- |z| ) foldable
GENERIC: absq ( n -- |n|^2 ) foldable

GENERIC: zero? ( x -- ? ) foldable
M: object zero? drop f ;

: sq dup * ; foldable
: neg 0 swap - ; foldable
: recip 1 swap / ; foldable
: max ( x y -- z ) [ > ] 2keep ? ; foldable
: min ( x y -- z ) [ < ] 2keep ? ; foldable
: between? ( x min max -- ? ) pick >= >r >= r> and ; foldable
: rem ( x y -- z ) tuck mod over + swap mod ; foldable
: sgn ( m -- n ) dup 0 < -1 0 ? swap 0 > 1 0 ? bitor ; foldable
: align ( m w -- n ) 1- [ + ] keep bitnot bitand ; inline
: truncate ( x -- y ) dup 1 mod - ; foldable

: floor ( x -- y )
    dup 1 mod dup zero?
    [ drop ] [ dup 0 < [ - 1- ] [ - ] if ] if ; foldable

: ceiling ( x -- y ) neg floor neg ; foldable

: (repeat) ( i n quot -- )
    pick pick >= [
        3drop
    ] [
        [ swap >r call 1+ r> ] keep (repeat)
    ] if ; inline

: repeat 0 -rot (repeat) ; inline

: times ( n quot -- | quot: -- )
    swap [ >r dup slip r> ] repeat drop ; inline

GENERIC: number>string ( n -- str ) foldable
