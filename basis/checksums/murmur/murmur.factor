! Copyright (C) 2013 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors checksums fry grouping io.binary kernel math
math.bitwise sequences ;
IN: checksums.murmur

TUPLE: murmur3-32 seed ;

C: <murmur3-32> murmur3-32

CONSTANT: c1 0xcc9e2d51
CONSTANT: c2 0x1b873593
CONSTANT: r1 15
CONSTANT: r2 13
CONSTANT: m 5
CONSTANT: n 0xe6546b64

<PRIVATE

: 32-bit ( n -- n' ) 32 on-bits mask ; inline

: rotl ( k r -- k' )
    [ shift ] [ 32 - shift ] 2bi bitor ; inline

: (hash-chunk) ( k -- k' )
    c1 * 32-bit r1 rotl c2 * 32-bit ; inline

: hash-chunk ( hash k -- hash' )
    (hash-chunk) bitxor r2 rotl m * n + 32-bit ; inline

PRIVATE>

M: murmur3-32 checksum-bytes ( bytes checksum -- value )
    [ [ length ] keep over 4 mod cut* ] [ seed>> 32-bit ] bi*
    '[ 4 <groups> _ [ le> hash-chunk ] reduce ]
    [ be> (hash-chunk) bitxor bitxor 32-bit ] bi*
    [ -16 shift ] [ bitxor 0x85ebca6b * 32-bit ] bi
    [ -13 shift ] [ bitxor 0xc2b2ae35 * 32-bit ] bi
    [ -16 shift ] [ bitxor 32 >signed ] bi ;

INSTANCE: murmur3-32 checksum
