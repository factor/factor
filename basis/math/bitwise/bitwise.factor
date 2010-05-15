! Copyright (C) 2007, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators combinators.smart fry kernel
macros math math.bits sequences sequences.private words
byte-arrays alien alien.c-types specialized-arrays ;
SPECIALIZED-ARRAY: uchar
IN: math.bitwise

! utilities
: clear-bit ( x n -- y ) 2^ bitnot bitand ; inline
: set-bit ( x n -- y ) 2^ bitor ; inline
: bit-clear? ( x n -- ? ) 2^ bitand 0 = ; inline
: unmask ( x n -- ? ) bitnot bitand ; inline
: unmask? ( x n -- ? ) unmask 0 > ; inline
: mask ( x n -- ? ) bitand ; inline
: mask? ( x n -- ? ) mask 0 > ; inline
: wrap ( m n -- m' ) 1 - bitand ; inline
: bits ( m n -- m' ) 2^ wrap ; inline
: mask-bit ( m n -- m' ) 2^ mask ; inline
: on-bits ( m -- n ) 2^ 1 - ; inline
: toggle-bit ( m n -- m' ) 2^ bitxor ; inline
: >signed ( x n -- y ) 2dup neg 1 + shift 1 = [ 2^ - ] [ drop ] if ;
: >odd ( m -- n ) 0 set-bit ; foldable
: >even ( m -- n ) 0 clear-bit ; foldable
: next-even ( m -- n ) >even 2 + ; foldable
: next-odd ( m -- n ) dup even? [ 1 + ] [ 2 + ] if ; foldable
: shift-mod ( m s w -- n ) [ shift ] dip 2^ wrap ; inline

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
    [ at ] curry map
    0 [ bitor ] reduce ;

! bitfield
<PRIVATE

GENERIC: (bitfield-quot) ( spec -- quot )

M: integer (bitfield-quot) ( spec -- quot )
    [ swapd shift bitor ] curry ;

M: pair (bitfield-quot) ( spec -- quot )
    first2 over word? [ [ swapd execute ] dip ] [ ] ?
    [ shift bitor ] append 2curry ;

PRIVATE>

MACRO: bitfield ( bitspec -- )
    [ 0 ] [ (bitfield-quot) compose ] reduce ;

! bit-count
<PRIVATE

DEFER: byte-bit-count

<<

\ byte-bit-count
256 iota [
    8 <bits> 0 [ [ 1 + ] when ] reduce
] B{ } map-as '[ HEX: ff bitand _ nth-unsafe ]
(( byte -- table )) define-declared

\ byte-bit-count make-inline

>>

GENERIC: (bit-count) ( x -- n )

: fixnum-bit-count ( x -- n )
    0 swap [
        dup 0 >
    ] [
        [ 8 bits byte-bit-count ] [ -8 shift ] bi
        [ + ] dip
    ] while drop ;

M: fixnum (bit-count)
    fixnum-bit-count ; inline

M: bignum (bit-count)
    dup 0 = [ drop 0 ] [
        [ byte-bit-count ] [ -8 shift (bit-count) ] bi +
    ] if ;

: byte-array-bit-count ( byte-array -- n )
    0 [ byte-bit-count + ] reduce ; inline

PRIVATE>

ERROR: invalid-bit-count-target object ;

GENERIC: bit-count ( obj -- n )

M: integer bit-count
    dup 0 < [ invalid-bit-count-target ] when (bit-count) ; inline

M: byte-array bit-count
    byte-array-bit-count ;

M: object bit-count
    binary-object <direct-uchar-array> byte-array-bit-count ;

: even-parity? ( obj -- ? ) bit-count even? ;

: odd-parity? ( obj -- ? ) bit-count odd? ;
