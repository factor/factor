! Copyright (C) 2007, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math sequences accessors math.bits
sequences.private words namespaces macros hints
combinators fry io.binary combinators.smart ;
IN: math.bitwise

! utilities
: clear-bit ( x n -- y ) 2^ bitnot bitand ; inline
: set-bit ( x n -- y ) 2^ bitor ; inline
: bit-clear? ( x n -- ? ) 2^ bitand 0 = ; inline
: unmask ( x n -- ? ) bitnot bitand ; inline
: unmask? ( x n -- ? ) unmask 0 > ; inline
: mask ( x n -- ? ) bitand ; inline
: mask? ( x n -- ? ) mask 0 > ; inline
: wrap ( m n -- m' ) 1- bitand ; inline
: bits ( m n -- m' ) 2^ wrap ; inline
: mask-bit ( m n -- m' ) 2^ mask ; inline
: on-bits ( n -- m ) 2^ 1- ; inline
: toggle-bit ( m n -- m' ) 2^ bitxor ; inline

: shift-mod ( n s w -- n )
    [ shift ] dip 2^ wrap ; inline

: bitroll ( x s w -- y )
    [ wrap ] keep
    [ shift-mod ] [ [ - ] keep shift-mod ] 3bi bitor ; inline

: bitroll-32 ( n s -- n' ) 32 bitroll ; inline

: bitroll-64 ( n s -- n' ) 64 bitroll ; inline

! 32-bit arithmetic
: w+ ( int int -- int ) + 32 bits ; inline
: w- ( int int -- int ) - 32 bits ; inline
: w* ( int int -- int ) * 32 bits ; inline

! flags
MACRO: flags ( values -- )
    [ 0 ] [ [ ?execute bitor ] curry compose ] reduce ;

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
256 [
    8 <bits> 0 [ [ 1+ ] when ] reduce
] B{ } map-as '[ HEX: ff bitand _ nth-unsafe ]
(( byte -- table )) define-declared

\ byte-bit-count make-inline

>>

GENERIC: (bit-count) ( x -- n )

M: fixnum (bit-count)
    [
        {
            [           byte-bit-count ]
            [ -8  shift byte-bit-count ]
            [ -16 shift byte-bit-count ]
            [ -24 shift byte-bit-count ]
        } cleave
    ] sum-outputs ;

M: bignum (bit-count)
    dup 0 = [ drop 0 ] [
        [ byte-bit-count ] [ -8 shift (bit-count) ] bi +
    ] if ;

PRIVATE>

: bit-count ( x -- n )
    dup 0 < [ bitnot ] when (bit-count) ; inline

! Signed byte array to integer conversion
: signed-le> ( bytes -- x )
    [ le> ] [ length 8 * 1- on-bits ] bi
    2dup > [ bitnot bitor ] [ drop ] if ;

: signed-be> ( bytes -- x )
    <reversed> signed-le> ;

: >signed ( x n -- y )
    2dup neg 1+ shift 1 = [ 2^ - ] [ drop ] if ;

