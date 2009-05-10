! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.private ;
IN: math

GENERIC: >fixnum ( x -- n ) foldable
GENERIC: >bignum ( x -- n ) foldable
GENERIC: >integer ( x -- n ) foldable
GENERIC: >float ( x -- y ) foldable

GENERIC: numerator ( a/b -- a )
GENERIC: denominator ( a/b -- b )

GENERIC: real-part ( z -- x )
GENERIC: imaginary-part ( z -- y )

MATH: number= ( x y -- ? ) foldable

M: object number= 2drop f ;

MATH: <  ( x y -- ? ) foldable
MATH: <= ( x y -- ? ) foldable
MATH: >  ( x y -- ? ) foldable
MATH: >= ( x y -- ? ) foldable

MATH: +   ( x y -- z ) foldable
MATH: -   ( x y -- z ) foldable
MATH: *   ( x y -- z ) foldable
MATH: /   ( x y -- z ) foldable
MATH: /f  ( x y -- z ) foldable
MATH: /i  ( x y -- z ) foldable
MATH: mod ( x y -- z ) foldable

MATH: /mod ( x y -- z w ) foldable

MATH: bitand ( x y -- z ) foldable
MATH: bitor  ( x y -- z ) foldable
MATH: bitxor ( x y -- z ) foldable
GENERIC# shift 1 ( x n -- y ) foldable
GENERIC: bitnot ( x -- y ) foldable
GENERIC# bit? 1 ( x n -- ? ) foldable

GENERIC: abs ( x -- y ) foldable

<PRIVATE

GENERIC: (log2) ( x -- n ) foldable

PRIVATE>

: log2 ( x -- n )
    dup 0 <= [
        "log2 expects positive inputs" throw
    ] [
        (log2)
    ] if ; inline

: zero? ( x -- ? ) 0 number= ; inline
: 1+ ( x -- y ) 1 + ; inline
: 1- ( x -- y ) 1 - ; inline
: 2/ ( x -- y ) -1 shift ; inline
: sq ( x -- y ) dup * ; inline
: neg ( x -- -x ) 0 swap - ; inline
: recip ( x -- y ) 1 swap / ; inline
: sgn ( x -- n ) dup 0 < [ drop -1 ] [ 0 > 1 0 ? ] if ; inline
: ?1+ ( x -- y ) [ 1 + ] [ 0 ] if* ; inline
: rem ( x y -- z ) abs [ mod ] [ + ] [ mod ] tri ; foldable
: 2^ ( n -- 2^n ) 1 swap shift ; inline
: even? ( n -- ? ) 1 bitand zero? ;
: odd? ( n -- ? ) 1 bitand 1 number= ;

UNION: integer fixnum bignum ;

TUPLE: ratio { numerator integer read-only } { denominator integer read-only } ;

UNION: rational integer ratio ;

UNION: real rational float ;

TUPLE: complex { real real read-only } { imaginary real read-only } ;

UNION: number real complex ;

: fp-bitwise= ( x y -- ? ) [ double>bits ] bi@ = ; inline

GENERIC: fp-special? ( x -- ? )
GENERIC: fp-nan? ( x -- ? )
GENERIC: fp-qnan? ( x -- ? )
GENERIC: fp-snan? ( x -- ? )
GENERIC: fp-infinity? ( x -- ? )
GENERIC: fp-nan-payload ( x -- bits )

M: object fp-special?
    drop f ;
M: object fp-nan?
    drop f ;
M: object fp-qnan?
    drop f ;
M: object fp-snan?
    drop f ;
M: object fp-infinity?
    drop f ;
M: object fp-nan-payload
    drop f ;

M: float fp-special?
    double>bits -52 shift HEX: 7ff [ bitand ] keep = ;

M: float fp-nan-payload
    double>bits HEX: fffffffffffff bitand ; foldable flushable

M: float fp-nan?
    dup fp-special? [ fp-nan-payload zero? not ] [ drop f ] if ;

M: float fp-qnan?
    dup fp-nan? [ fp-nan-payload HEX: 8000000000000 bitand zero? not ] [ drop f ] if ;

M: float fp-snan?
    dup fp-nan? [ fp-nan-payload HEX: 8000000000000 bitand zero? ] [ drop f ] if ;

M: float fp-infinity?
    dup fp-special? [ fp-nan-payload zero? ] [ drop f ] if ;

: <fp-nan> ( payload -- nan )
    HEX: 7ff0000000000000 bitor bits>double ; foldable flushable

: next-float ( m -- n )
    double>bits
    dup -0.0 double>bits > [ 1 - bits>double ] [ ! negative non-zero
        dup -0.0 double>bits = [ drop 0.0 ] [ ! negative zero
            1 + bits>double ! positive
        ] if
    ] if ; foldable flushable

: prev-float ( m -- n )
    double>bits
    dup -0.0 double>bits >= [ 1 + bits>double ] [ ! negative
        dup 0.0 double>bits = [ drop -0.0 ] [ ! positive zero
            1 - bits>double ! positive non-zero
        ] if
    ] if ; foldable flushable

: next-power-of-2 ( m -- n )
    dup 2 <= [ drop 2 ] [ 1 - log2 1 + 2^ ] if ; inline

: power-of-2? ( n -- ? )
    dup 0 <= [ drop f ] [ dup 1 - bitand zero? ] if ; foldable

: align ( m w -- n )
    1 - [ + ] keep bitnot bitand ; inline

<PRIVATE

: iterate-prep ( n quot -- i n quot ) [ 0 ] 2dip ; inline

: if-iterate? ( i n true false -- ) [ 2over < ] 2dip if ; inline

: iterate-step ( i n quot -- i n quot )
    #! Apply quot to i, keep i and quot, hide n.
    [ nip call ] 3keep ; inline

: iterate-next ( i n quot -- i' n quot ) [ 1 + ] 2dip ; inline

PRIVATE>

: (each-integer) ( i n quot: ( i -- ) -- )
    [ iterate-step iterate-next (each-integer) ]
    [ 3drop ] if-iterate? ; inline recursive

: (find-integer) ( i n quot: ( i -- ? ) -- i )
    [
        iterate-step roll
        [ 2drop ] [ iterate-next (find-integer) ] if
    ] [ 3drop f ] if-iterate? ; inline recursive

: (all-integers?) ( i n quot: ( i -- ? ) -- ? )
    [
        iterate-step roll
        [ iterate-next (all-integers?) ] [ 3drop f ] if
    ] [ 3drop t ] if-iterate? ; inline recursive

: each-integer ( n quot -- )
    iterate-prep (each-integer) ; inline

: times ( n quot -- )
    [ drop ] prepose each-integer ; inline

: find-integer ( n quot -- i )
    iterate-prep (find-integer) ; inline

: all-integers? ( n quot -- ? )
    iterate-prep (all-integers?) ; inline

: find-last-integer ( n quot: ( i -- ? ) -- i )
    over 0 < [
        2drop f
    ] [
        [ call ] 2keep rot [
            drop
        ] [
            [ 1 - ] dip find-last-integer
        ] if
    ] if ; inline recursive
