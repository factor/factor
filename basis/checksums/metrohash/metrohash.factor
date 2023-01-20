! Copyright (C) 2018 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data byte-arrays checksums
combinators endian grouping kernel math math.bitwise sequences
specialized-arrays ;
SPECIALIZED-ARRAY: uint64_t
SPECIALIZED-ARRAY: uint32_t
SPECIALIZED-ARRAY: uint16_t
IN: checksums.metrohash

TUPLE: metrohash-64 seed ;

C: <metrohash-64> metrohash-64

<PRIVATE

:: native-mapper ( from to bytes c-type -- seq )
    from to bytes <slice>
    bytes byte-array? alien.data:little-endian? and
    [ c-type cast-array ]
    [ c-type heap-size <groups> [ le> ] map ] if ; inline

PRIVATE>

M:: metrohash-64 checksum-bytes ( bytes checksum -- value )
    0xD6D018F5 :> k0
    0xA2AA033B :> k1
    0x62992FC1 :> k2
    0x30BC5B29 :> k3

    checksum seed>> :> seed
    bytes length :> len

    len dup 32 mod - :> len/32
    len dup 16 mod - :> len/16
    len dup 8 mod - :> len/8
    len dup 4 mod - :> len/4
    len dup 2 mod - :> len/2

    seed k2 W+ k0 W* :> h

    h h h h :> ( v0! v1! v2! v3! )

    len 32 >= [
        0 len/32 bytes uint64_t native-mapper 4 <groups> [
            first4 {
                [ k0 W* v0 W+ -29 bitroll-64 v2 W+ v0! ]
                [ k1 W* v1 W+ -29 bitroll-64 v3 W+ v1! ]
                [ k2 W* v2 W+ -29 bitroll-64 v0 W+ v2! ]
                [ k3 W* v3 W+ -29 bitroll-64 v1 W+ v3! ]
            } spread
        ] each

        v0 v3 W+ k0 W* v1 W+ -37 bitroll-64 k1 W* v2 bitxor v2!
        v1 v2 W+ k1 W* v0 W+ -37 bitroll-64 k0 W* v3 bitxor v3!
        v0 v2 W+ k0 W* v3 W+ -37 bitroll-64 k1 W* v0 bitxor v0!
        v1 v3 W+ k1 W* v2 W+ -37 bitroll-64 k0 W* v1 bitxor v1!

        v0 v1 bitxor h W+ v0!
    ] when

    len/32 len/16 bytes uint64_t native-mapper [
        first2
        [ k2 W* v0 W+ -29 bitroll-64 k3 W* v1! ]
        [ k2 W* v0 W+ -29 bitroll-64 k3 W* v2! ] bi*
        v1 k0 W* -21 bitroll-64 v2 W+ v1 bitxor v1!
        v2 k3 W* -21 bitroll-64 v1 W+ v2 bitxor v2!
        v2 v0 W+ v0!
    ] unless-empty

    len/16 len/8 bytes uint64_t native-mapper [
        first k3 W* v0 W+ v0!
        v0 -55 bitroll-64 k1 W* v0 bitxor v0!
    ] unless-empty

    len/8 len/4 bytes uint32_t native-mapper [
        first k3 W* v0 W+ v0!
        v0 -26 bitroll-64 k1 W* v0 bitxor v0!
    ] unless-empty

    len/4 len/2 bytes uint16_t native-mapper [
        first k3 W* v0 W+ v0!
        v0 -48 bitroll-64 k1 W* v0 bitxor v0!
    ] unless-empty

    bytes len/2 tail-slice [
        first k3 W* v0 W+ v0!
        v0 -37 bitroll-64 k1 W* v0 bitxor v0!
    ] unless-empty

    v0 -28 bitroll-64 v0 bitxor v0!
    v0 k0 W* v0!
    v0 -29 bitroll-64 v0 bitxor v0!
    v0 ;

INSTANCE: metrohash-64 checksum

TUPLE: metrohash-128 seed ;

C: <metrohash-128> metrohash-128

M:: metrohash-128 checksum-bytes ( bytes checksum -- value )
    0xC83A91E1 :> k0
    0x8648DBDB :> k1
    0x7BDEC03B :> k2
    0x2F5870A5 :> k3

    checksum seed>> :> seed
    bytes length :> len

    len dup 32 mod - :> len/32
    len dup 16 mod - :> len/16
    len dup 8 mod - :> len/8
    len dup 4 mod - :> len/4
    len dup 2 mod - :> len/2

    seed k0 W- k3 W* :> v0!
    seed k1 W+ k2 W* :> v1!
    seed k0 W+ k2 W* :> v2!
    seed k1 W- k3 W* :> v3!

    len 32 >= [
        0 len/32 bytes uint64_t native-mapper 4 <groups> [
            first4 {
                [ k0 W* v0 W+ -29 bitroll-64 v2 W+ v0! ]
                [ k1 W* v1 W+ -29 bitroll-64 v3 W+ v1! ]
                [ k2 W* v2 W+ -29 bitroll-64 v0 W+ v2! ]
                [ k3 W* v3 W+ -29 bitroll-64 v1 W+ v3! ]
            } spread
        ] each

        v0 v3 W+ k0 W* v1 W+ -21 bitroll-64 k1 W* v2 bitxor v2!
        v1 v2 W+ k1 W* v0 W+ -21 bitroll-64 k0 W* v3 bitxor v3!
        v0 v2 W+ k0 W* v3 W+ -21 bitroll-64 k1 W* v0 bitxor v0!
        v1 v3 W+ k1 W* v2 W+ -21 bitroll-64 k0 W* v1 bitxor v1!
    ] when

    len/32 len/16 bytes uint64_t native-mapper [
        first2
        [ k2 W* v0 W+ -33 bitroll-64 k3 W* v0! ]
        [ k2 W* v1 W+ -33 bitroll-64 k3 W* v1! ] bi*
        v0 k2 W* v1 W+ -45 bitroll-64 k1 W* v0 bitxor v0!
        v1 k3 W* v0 W+ -45 bitroll-64 k0 W* v1 bitxor v1!
    ] unless-empty

    len/16 len/8 bytes uint64_t native-mapper [
        first k2 W* v0 W+ -33 bitroll-64 k3 W* v0!
        v0 k2 W* v1 W+ -27 bitroll-64 k1 W* v0 bitxor v0!
    ] unless-empty

    len/8 len/4 bytes uint32_t native-mapper [
        first k2 W* v1 W+ -33 bitroll-64 k3 W* v1!
        v1 k3 W* v0 W+ -46 bitroll-64 k0 W* v1 bitxor v1!
    ] unless-empty

    len/4 len/2 bytes uint16_t native-mapper [
        first k2 W* v0 W+ -33 bitroll-64 k3 W* v0!
        v0 k2 W* v1 W+ -22 bitroll-64 k1 W* v0 bitxor v0!
    ] unless-empty

    bytes len/2 tail-slice [
        first k2 W* v1 W+ -33 bitroll-64 k3 W* v1!
        v1 k3 W* v0 W+ -58 bitroll-64 k0 W* v1 bitxor v1!
    ] unless-empty

    v0 k0 W* v1 W+ -13 bitroll-64 v0 W+ v0!
    v1 k1 W* v0 W+ -37 bitroll-64 v1 W+ v1!
    v0 k2 W* v1 W+ -13 bitroll-64 v0 W+ v0!
    v1 k3 W* v0 W+ -37 bitroll-64 v1 W+ v1!

    v0 64 shift v1 + ;

INSTANCE: metrohash-128 checksum
