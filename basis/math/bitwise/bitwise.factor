! Copyright (C) 2007, 2008 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data arrays assocs byte-arrays
combinators combinators.short-circuit kernel kernel.private
layouts math math.bits sequences sequences.private
specialized-arrays words ;
IN: math.bitwise
SPECIALIZED-ARRAY: uchar
IN: math.bitwise

! utilities
: clear-bit ( x n -- y ) 2^ bitnot bitand ; inline
: set-bit ( x n -- y ) 2^ bitor ; inline
: unmask ( x n -- y ) bitnot bitand ; inline
: unmask? ( x n -- ? ) unmask zero? not ; inline
: mask ( x n -- y ) bitand ; inline
: mask? ( x n -- ? ) [ mask ] [ = ] bi ; inline
: wrap ( m n -- m' ) 1 - bitand ; inline
: on-bits ( m -- n ) dup 0 <= [ drop 0 ] [ 2^ 1 - ] if ; inline
: bits ( m n -- m' ) on-bits mask ; inline
: mask-bit ( m n -- m' ) 2^ mask ; inline
: toggle-bit ( m n -- m' ) 2^ bitxor ; inline
: >signed ( x n -- y )
    [ bits ] keep 2dup 1 - bit? [ 2^ - ] [ drop ] if ; inline
: >odd ( m -- n ) 0 set-bit ; foldable
: >even ( m -- n ) 0 clear-bit ; foldable
: next-even ( m -- n ) >even 2 + ; foldable
: next-odd ( m -- n ) dup even? [ 1 + ] [ 2 + ] if ; foldable
: shift-mod ( m s w -- n ) [ shift ] dip 2^ wrap ; inline

ERROR: bit-range-error x high low ;
: bit-range ( x high low -- y )
    2dup { [ nip 0 < ] [ < ] } 2|| [ bit-range-error ] when
    [ nip neg shift ] [ - 1 + ] 2bi bits ; inline

: bitroll ( x s w -- y )
    [ wrap ] keep
    [ shift-mod ] [ [ - ] keep shift-mod ] 3bi bitor ; inline

: bitroll-32 ( m s -- n ) 32 bitroll ; inline

: bitroll-64 ( m s -- n ) 64 bitroll ; inline

! 32-bit arithmetic
: w+ ( x y -- z ) + 32 bits ; inline
: w- ( x y -- z ) - 32 bits ; inline
: w* ( x y -- z ) * 32 bits ; inline

! 64-bit arithmetic
: W+ ( x y -- z ) + 64 bits ; inline
: W- ( x y -- z ) - 64 bits ; inline
: W* ( x y -- z ) * 64 bits ; inline

: symbols>flags ( symbols assoc -- flag-bits )
    '[ _ at ] map 0 [ bitor ] reduce ;

! bitfield
<PRIVATE

GENERIC: (bitfield-quot) ( spec -- quot )

M: integer (bitfield-quot)
    '[ _ shift ] ;

M: pair (bitfield-quot)
    first2-unsafe over word? [
        '[ _ execute _ shift ]
    ] [
        '[ _ _ shift ]
    ] if ;

: (bitfield) ( bitspec -- quot )
    [ [ 0 ] ] [
        [ (bitfield-quot) ] [ '[ @ _ dip bitor ] ] map-reduce
    ] if-empty ;

PRIVATE>

MACRO: bitfield ( bitspec -- quot ) (bitfield) ;

MACRO: bitfield* ( bitspec -- quot ) reverse (bitfield) ;

! bit-count
<PRIVATE

DEFER: byte-bit-count

<<

\ byte-bit-count
256 <iota> [
    8 <bits> 0 [ [ 1 + ] when ] reduce
] B{ } map-as '[ 0xff bitand _ nth-unsafe ]
( byte -- table ) define-declared

\ byte-bit-count make-inline

>>

GENERIC: (bit-count) ( x -- n )

: fixnum-bit-count ( x -- n )
    { fixnum } declare
    {
        [ byte-bit-count ]
        [ -8 shift byte-bit-count + ]
        [ -16 shift byte-bit-count + ]
        [ -24 shift byte-bit-count + ]
        [
            cell 8 = [
                {
                    [ -32 shift byte-bit-count + ]
                    [ -40 shift byte-bit-count + ]
                    [ -48 shift byte-bit-count + ]
                    [ -56 shift byte-bit-count + ]
                } cleave >fixnum
            ] [ drop ] if
        ]
    } cleave ;

M: fixnum (bit-count)
    fixnum-bit-count { fixnum } declare ; inline

M: bignum (bit-count)
    [ 0 ] [
        [ byte-bit-count ] [ -8 shift (bit-count) ] bi +
    ] if-zero ;

: byte-array-bit-count ( byte-array -- n )
    [ byte-bit-count ] map-sum ; inline

PRIVATE>

GENERIC: bit-count ( obj -- n )

M: integer bit-count
    assert-non-negative (bit-count) ; inline

M: byte-array bit-count
    byte-array-bit-count ;

M: object bit-count
    binary-object uchar <c-direct-array> byte-array-bit-count ;

: bit-length ( x -- n )
    dup 0 < [ non-negative-number-expected ] [
        dup 1 > [ log2 1 + ] when
    ] if ;

: even-parity? ( obj -- ? ) bit-count even? ;

: odd-parity? ( obj -- ? ) bit-count odd? ;

: d>w/w ( d -- w1 w2 )
    [ 0xffffffff bitand ] [ -32 shift 0xffffffff bitand ] bi ;

: w>h/h ( w -- h1 h2 )
    [ 0xffff bitand ] [ -16 shift 0xffff bitand ] bi ;

: h>b/b ( h -- b1 b2 )
    [ 0xff bitand ] [ -8 shift 0xff bitand ] bi ;
