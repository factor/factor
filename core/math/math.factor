! Copyright (C) 2003, 2009 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private ;
IN: math

BUILTIN: fixnum ;
BUILTIN: bignum ;
BUILTIN: float ;

PRIMITIVE: bits>double ( n -- x )
PRIMITIVE: bits>float ( n -- x )
PRIMITIVE: double>bits ( x -- n )
PRIMITIVE: float>bits ( x -- n )

<PRIVATE
PRIMITIVE: bignum* ( x y -- z )
PRIMITIVE: bignum+ ( x y -- z )
PRIMITIVE: bignum- ( x y -- z )
PRIMITIVE: bignum-bit? ( x n -- ? )
PRIMITIVE: bignum-bitand ( x y -- z )
PRIMITIVE: bignum-bitnot ( x -- y )
PRIMITIVE: bignum-bitor ( x y -- z )
PRIMITIVE: bignum-bitxor ( x y -- z )
PRIMITIVE: bignum-gcd ( x y -- z )
PRIMITIVE: bignum-log2 ( x -- n )
PRIMITIVE: bignum-mod ( x y -- z )
PRIMITIVE: bignum-shift ( x y -- z )
PRIMITIVE: bignum/i ( x y -- z )
PRIMITIVE: bignum/mod ( x y -- z w )
PRIMITIVE: bignum< ( x y -- ? )
PRIMITIVE: bignum<= ( x y -- ? )
PRIMITIVE: bignum= ( x y -- ? )
PRIMITIVE: bignum> ( x y -- ? )
PRIMITIVE: bignum>= ( x y -- ? )
PRIMITIVE: bignum>fixnum ( x -- y )
PRIMITIVE: bignum>fixnum-strict ( x -- y )
PRIMITIVE: both-fixnums? ( x y -- ? )
PRIMITIVE: fixnum* ( x y -- z )
PRIMITIVE: fixnum*fast ( x y -- z )
PRIMITIVE: fixnum+ ( x y -- z )
PRIMITIVE: fixnum+fast ( x y -- z )
PRIMITIVE: fixnum- ( x y -- z )
PRIMITIVE: fixnum-bitand ( x y -- z )
PRIMITIVE: fixnum-bitnot ( x -- y )
PRIMITIVE: fixnum-bitor ( x y -- z )
PRIMITIVE: fixnum-bitxor ( x y -- z )
PRIMITIVE: fixnum-fast ( x y -- z )
PRIMITIVE: fixnum-mod ( x y -- z )
PRIMITIVE: fixnum-shift ( x y -- z )
PRIMITIVE: fixnum-shift-fast ( x y -- z )
PRIMITIVE: fixnum/i ( x y -- z )
PRIMITIVE: fixnum/i-fast ( x y -- z )
PRIMITIVE: fixnum/mod ( x y -- z w )
PRIMITIVE: fixnum/mod-fast ( x y -- z w )
PRIMITIVE: fixnum< ( x y -- ? )
PRIMITIVE: fixnum<= ( x y -- z )
PRIMITIVE: fixnum> ( x y -- ? )
PRIMITIVE: fixnum>= ( x y -- ? )
PRIMITIVE: fixnum>bignum ( x -- y )
PRIMITIVE: fixnum>float ( x -- y )
PRIMITIVE: float* ( x y -- z )
PRIMITIVE: float+ ( x y -- z )
PRIMITIVE: float- ( x y -- z )
PRIMITIVE: float-u< ( x y -- ? )
PRIMITIVE: float-u<= ( x y -- ? )
PRIMITIVE: float-u> ( x y -- ? )
PRIMITIVE: float-u>= ( x y -- ? )
PRIMITIVE: float/f ( x y -- z )
PRIMITIVE: float< ( x y -- ? )
PRIMITIVE: float<= ( x y -- ? )
PRIMITIVE: float= ( x y -- ? )
PRIMITIVE: float> ( x y -- ? )
PRIMITIVE: float>= ( x y -- ? )
PRIMITIVE: float>bignum ( x -- y )
PRIMITIVE: float>fixnum ( x -- y )
PRIVATE>

GENERIC: >fixnum ( x -- n ) foldable
GENERIC: >bignum ( x -- n ) foldable
GENERIC: >integer ( x -- n ) foldable
GENERIC: >float ( x -- y ) foldable
GENERIC: integer>fixnum ( x -- y ) foldable
GENERIC: integer>fixnum-strict ( x -- y ) foldable

GENERIC: numerator ( a/b -- a )
GENERIC: denominator ( a/b -- b )
GENERIC: >fraction ( a/b -- a b )

GENERIC: real-part ( z -- x )
GENERIC: imaginary-part ( z -- y )

MATH: number= ( x y -- ? ) foldable

M: object number= 2drop f ;

MATH: <  ( x y -- ? ) foldable
MATH: <= ( x y -- ? ) foldable
MATH: >  ( x y -- ? ) foldable
MATH: >= ( x y -- ? ) foldable

MATH: unordered? ( x y -- ? ) foldable
MATH: u<  ( x y -- ? ) foldable
MATH: u<= ( x y -- ? ) foldable
MATH: u>  ( x y -- ? ) foldable
MATH: u>= ( x y -- ? ) foldable

M: object unordered? 2drop f ;

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
GENERIC#: shift 1 ( x n -- y ) foldable
GENERIC: bitnot ( x -- y ) foldable
GENERIC#: bit? 1 ( x n -- ? ) foldable

GENERIC: abs ( x -- y ) foldable

<PRIVATE

GENERIC: (log2) ( x -- n ) foldable

PRIVATE>

ERROR: non-negative-number-expected n ;

: assert-non-negative ( n -- n )
    dup 0 < [ non-negative-number-expected ] when ; inline

ERROR: positive-number-expected n ;

: assert-positive ( n -- n )
    dup 0 > [ positive-number-expected ] unless ; inline

ERROR: negative-number-expected n ;

: assert-negative ( n -- n )
    dup 0 < [ negative-number-expected ] unless ; inline

: recursive-hashcode ( n obj quot -- code )
    pick 0 <= [ 3drop 0 ] [ [ 1 - ] 2dip call ] if ; inline

: log2 ( x -- n ) assert-positive (log2) ; inline
: zero? ( x -- ? ) 0 number= ; inline
: 2/ ( x -- y ) -1 shift ; inline
: sq ( x -- y ) dup * ; inline
: neg ( x -- -x ) -1 * ; inline
: sgn ( x -- n ) dup 0 < [ drop -1 ] [ 0 > 1 0 ? ] if ; inline
: ?1+ ( x -- y ) [ 1 + ] [ 0 ] if* ; inline
: rem ( x y -- z ) abs [ mod ] [ + ] [ mod ] tri ; foldable
: 2^ ( n -- 2^n ) 1 swap shift ; inline
: even? ( n -- ? ) 1 bitand zero? ; inline
: odd? ( n -- ? ) 1 bitand 1 number= ; inline

: bit-length ( x -- n )
    assert-non-negative dup 1 > [ log2 1 + ] when ;

GENERIC: neg? ( x -- ? )

: if-zero ( ..a n quot1: ( ..a -- ..b ) quot2: ( ..a n -- ..b ) -- ..b )
    [ dup zero? ] [ [ drop ] prepose ] [ ] tri* if ; inline

: when-zero ( ... n quot: ( ... -- ... x ) -- ... x ) [ ] if-zero ; inline

: unless-zero ( ... n quot: ( ... n -- ... ) -- ... ) [ ] swap if-zero ; inline

: until-zero ( ... n quot: ( ... x -- ... y ) -- ... ) [ dup zero? ] swap until drop ; inline

UNION: integer fixnum bignum ;

TUPLE: ratio
    { numerator integer read-only }
    { denominator integer read-only } ;

UNION: rational integer ratio ;

M: rational neg? 0 < ; inline

UNION: real rational float ;

TUPLE: complex
    { real real read-only }
    { imaginary real read-only } ;

UNION: number real complex ;

GENERIC: recip ( x -- y )

M: number recip 1 swap / ; inline

: rect> ( x y -- z )
    ! Note: an imaginary 0.0 should still create a complex
    dup 0 = [ drop ] [ complex boa ] if ; inline

GENERIC: >rect ( z -- x y )

M: real >rect 0 ; inline

M: complex >rect [ real-part ] [ imaginary-part ] bi ; inline

<PRIVATE

: (gcd) ( b a x y -- a d )
    swap [
        nip
    ] [
        [ /mod [ over * swapd - ] dip ] keep (gcd)
    ] if-zero ; inline recursive

PRIVATE>

: gcd ( x y -- a d )
    [ 0 1 ] 2dip (gcd) dup 0 < [ neg ] when ; inline

MATH: simple-gcd ( x y -- d ) foldable

<PRIVATE

: fixnum-gcd ( x y -- d ) { fixnum fixnum } declare gcd nip ;

PRIVATE>

M: fixnum simple-gcd fixnum-gcd ; inline

M: bignum simple-gcd bignum-gcd ; inline

M: real simple-gcd gcd nip ; inline

: lcm ( a b -- c )
    [ * dup zero? ] 2keep '[ _ _ simple-gcd / ] unless ; foldable

: fp-bitwise= ( x y -- ? ) [ double>bits ] same? ; inline

GENERIC: fp-special? ( x -- ? )
GENERIC: fp-nan? ( x -- ? )
GENERIC: fp-qnan? ( x -- ? )
GENERIC: fp-snan? ( x -- ? )
GENERIC: fp-infinity? ( x -- ? )
GENERIC: fp-nan-payload ( x -- bits )
GENERIC: fp-sign ( x -- ? )

M: object fp-special? drop f ; inline
M: object fp-nan? drop f ; inline
M: object fp-qnan? drop f ; inline
M: object fp-snan? drop f ; inline
M: object fp-infinity? drop f ; inline

: <fp-nan> ( payload -- nan )
    0x7ff0000000000000 bitor bits>double ; inline

GENERIC: next-float ( m -- n )
GENERIC: prev-float ( m -- n )

: next-power-of-2 ( m -- n )
    dup 2 <= [ drop 2 ] [ 1 - log2 1 + 2^ ] if ; inline

: power-of-2? ( n -- ? )
    dup 0 <= [ drop f ] [ dup 1 - bitand zero? ] if ; foldable

: align ( m w -- n )
    1 - [ + ] keep bitnot bitand ; inline

: each-integer-from ( ... from to quot: ( ... i -- ... ) -- ... )
    2over < [
        [ nip call ] 3keep
        [ 1 + ] 2dip each-integer-from
    ] [
        3drop
    ] if ; inline recursive

: each-integer ( ... n quot: ( ... i -- ... ) -- ... )
    [ 0 ] 2dip each-integer-from ; inline

: times ( ... n quot: ( ... -- ... ) -- ... )
    [ drop ] prepose each-integer ; inline

: find-integer-from ( ... i n quot: ( ... i -- ... ? ) -- ... i/f )
    2over < [
        [ nip call ] 3keep roll
        [ 2drop ]
        [ [ 1 + ] 2dip find-integer-from ] if
    ] [
        3drop f
    ] if ; inline recursive

: find-integer ( ... n quot: ( ... i -- ... ? ) -- ... i/f )
    [ 0 ] 2dip find-integer-from ; inline

: find-last-integer ( ... n quot: ( ... i -- ... ? ) -- ... i/f )
    over 0 < [
        2drop f
    ] [
        [ call ] 2keep rot [
            drop
        ] [
            [ 1 - ] dip find-last-integer
        ] if
    ] if ; inline recursive

: all-integers-from? ( ... from to quot: ( ... i -- ... ? ) -- ... ? )
    2over < [
        [ nip call ] 3keep roll
        [ [ 1 + ] 2dip all-integers-from? ]
        [ 3drop f ] if
    ] [
        3drop t
    ] if ; inline recursive

: all-integers? ( ... n quot: ( ... i -- ... ? ) -- ... ? )
    [ 0 ] 2dip all-integers-from? ; inline
