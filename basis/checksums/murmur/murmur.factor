! Copyright (C) 2013 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.c-types alien.data byte-arrays
checksums fry grouping io.binary kernel math math.bitwise
math.ranges sequences ;

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

: rotl ( k r -- k' )
    [ shift ] [ 32 - shift ] 2bi bitor ; inline

: (hash-chunk) ( k -- k' )
    c1 * 32 bits r1 rotl c2 * 32 bits ; inline

: hash-chunk ( hash k -- hash' )
    (hash-chunk) bitxor r2 rotl m * n + 32 bits ; inline

: main-loop ( seq hash -- seq hash' )
    over byte-array? little-endian? and [
        [ 0 over length 4 - 4 <range> ] dip
        [ pick <displaced-alien> int deref hash-chunk ] reduce
    ] [
        [ dup length 4 mod dupd head-slice* 4 <groups> ] dip
        [ le> hash-chunk ] reduce
    ] if ; inline

: end-case ( seq hash -- hash' )
    swap dup length
    [ 4 mod tail-slice* be> (hash-chunk) bitxor ]
    [ bitxor ] bi 32 bits ; inline

: avalanche ( hash -- hash' )
    [ -16 shift ] [ bitxor 0x85ebca6b * 32 bits ] bi
    [ -13 shift ] [ bitxor 0xc2b2ae35 * 32 bits ] bi
    [ -16 shift ] [ bitxor ] bi ; inline

PRIVATE>

M: murmur3-32 checksum-bytes ( bytes checksum -- value )
    seed>> 32 bits main-loop end-case avalanche ;

INSTANCE: murmur3-32 checksum
