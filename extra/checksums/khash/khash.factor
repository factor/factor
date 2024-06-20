! Copyright (C) 2024 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types alien.data byte-arrays checksums
endian grouping kernel math math.bitwise sequences
specialized-arrays ;
SPECIALIZED-ARRAY: uint64_t

IN: checksums.khash

<PRIVATE

:: native-mapper ( from to bytes c-type -- seq )
    from to bytes <slice>
    bytes byte-array? alien.data:little-endian? and
    [ c-type cast-array ]
    [ c-type heap-size <groups> [ le> ] map ] if ; inline

:: khash64-step ( func input -- output )
    func
    input 7 - bitxor
    dup -31 bitroll-64 bitxor
    dup -11 bitroll-64 W-
    dup -17 bitroll-64 W-
    input 13 - bitxor
    dup -23 bitroll-64 bitxor
    dup -31 bitroll-64 W+
    dup -13 bitroll-64 W-
    input 2 - bitxor
    dup -19 bitroll-64 W-
    dup -5 bitroll-64 W+
    dup -31 bitroll-64 W- ;

PRIVATE>

TUPLE: khash64 seed ;

: <khash64> ( -- khash64 )
    0x6a09e667f3bcc908 khash64 boa ;

M:: khash64 checksum-bytes ( bytes checksum -- value )
    checksum seed>> :> seed
    bytes length :> len
    len 8 mod 0 assert= ! right now only handle groups of 8 bytes
    seed
    0 len bytes uint64_t native-mapper
    [ khash64-step ] each ;

INSTANCE: khash64 checksum
