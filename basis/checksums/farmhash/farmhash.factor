! Copyright (C) 2026 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
! Based on Google's FarmHash; see LICENSE.txt for its MIT license.

USING: accessors checksums checksums.cityhash
checksums.cityhash.private combinators kernel locals math
math.bitwise sequences ;
IN: checksums.farmhash

TUPLE: farmhash-32 seed ;
C: <farmhash-32> farmhash-32
TUPLE: farmhash-64 seed ;
C: <farmhash-64> farmhash-64
TUPLE: farmhash-128 seed ;
C: <farmhash-128> farmhash-128

<PRIVATE

! Portable farmhashmk (Fingerprint32), without CPU dispatch or debug tweaks.
:: farm32-13to24 ( bytes seed -- hash )
    bytes length :> len
    bytes len -1 shift 4 - fetch32 :> a
    bytes 4 fetch32 :> b
    bytes len 8 - fetch32 :> c
    bytes len -1 shift fetch32 :> d
    bytes 0 fetch32 :> e
    bytes len 4 - fetch32 :> f
    a -12 bitroll-32 f w+ :> a1
    a1 -3 bitroll-32 c w+ :> a2
    a2 f w+ -12 bitroll-32 d w+ :> a3
    d c1 w* len w+ seed w+ c mur a1 w+
    e mur a2 w+ b seed bitxor mur a3 w+ fmix ;

:: farm32-long ( bytes -- hash )
    bytes length :> len
    len bytes len 4 - fetch32 mur bytes len 16 - fetch32 mur :> h!
    len c1 w* bytes len 8 - fetch32 mur bytes len 12 - fetch32 mur :> g!
    len c1 w* bytes len 20 - fetch32 mix32 w+ -19 bitroll-32 113 w+ :> f!
    len 1 - 20 /i <iota> [| i |
        i 20 * :> offset
        bytes offset fetch32 :> a
        bytes offset 4 + fetch32 :> b
        bytes offset 8 + fetch32 :> c
        bytes offset 12 + fetch32 :> d
        bytes offset 16 + fetch32 :> e
        h a w+ d mur e w+ h!
        g b w+ c mur a w+ g!
        f c w+ b e c1 w* w+ mur d w+ g w+ f!
        g f w+ g!
    ] each
    h g f finish32 ;

: farm32 ( bytes -- hash )
    dup length {
        { [ dup 4 <= ] [ drop 0 hash32-0to4 ] }
        { [ dup 12 <= ] [ drop 0 hash32-5to12 ] }
        { [ dup 24 <= ] [ drop 0 farm32-13to24 ] }
        [ drop farm32-long ]
    } cond ;

:: farm32-seeded ( bytes seed -- hash )
    bytes length :> len
    {
        { [ len 4 <= ] [ bytes seed hash32-0to4 ] }
        { [ len 12 <= ] [ bytes seed hash32-5to12 ] }
        { [ len 24 <= ] [ bytes seed c1 w* farm32-13to24 ] }
        [
            bytes 24 head-slice seed len bitxor farm32-13to24
            bytes 24 tail-slice farm32 seed w+ mur
        ]
    } cond ;

! Portable farmhashna (Fingerprint64). Inputs up to 32 bytes match CityHash64.
:: farm64-33to64 ( bytes -- hash )
    bytes length :> len
    k2 len 2 * W+ :> mul
    bytes 0 fetch64 k2 W* :> a
    bytes 8 fetch64 :> b
    bytes len 8 - fetch64 mul W* :> c
    bytes len 16 - fetch64 k2 W* :> d
    a b W+ -43 bitroll-64 c -30 bitroll-64 W+ d W+ :> y
    y a b k2 W+ -18 bitroll-64 W+ c W+ mul hash16-mul :> z
    bytes 16 fetch64 mul W* :> e
    bytes 24 fetch64 :> f
    y bytes len 32 - fetch64 W+ mul W* :> g
    z bytes len 24 - fetch64 W+ mul W* :> h
    e f W+ -43 bitroll-64 g -30 bitroll-64 W+ h W+
    e f a W+ -18 bitroll-64 W+ g W+ mul hash16-mul ;

:: farm64-long ( bytes -- hash )
    bytes length :> len
    81 k1 W* 113 W+ :> y
    y k2 W* 113 W+ shift-mix k2 W* :> z
    81 k2 W* bytes 0 fetch64 W+ y z 0 0 0 0 hash-state boa :> state
    ! Leave 1 to 64 bytes for the final, overlapping round.
    len 1 - 64 /i <iota> [| i | bytes i 64 * state k1 1 hash-round ] each
    k1 state z>> 255 bitand 1 shift W+ :> mul
    state
        state w0>> len 1 - 63 bitand W+ >>w0
        state v0>> state w0>> W+ >>v0
        state w0>> state v0>> W+ >>w0 drop
    bytes len 64 - state mul 9 hash-round
    state v0>> state w0>> mul hash16-mul
    state y>> shift-mix k0 W* W+ state z>> W+
    state v1>> state w1>> mul hash16-mul state x>> W+ mul hash16-mul ;

: farm64 ( bytes -- hash )
    dup length {
        { [ dup 16 <= ] [ drop hash64-0to16 ] }
        { [ dup 32 <= ] [ drop hash64-17to32 ] }
        { [ dup 64 <= ] [ drop farm64-33to64 ] }
        [ drop farm64-long ]
    } cond ;

PRIVATE>

M: farmhash-32 checksum-bytes
    seed>> [ 32 bits farm32-seeded ] [ farm32 ] if* ;

M: farmhash-64 checksum-bytes
    seed>> [ [ farm64 k2 W- ] dip 64 bits hash16 ] [ farm64 ] if* ;

! Fingerprint128 and its seeded variant are CityHash128.
M: farmhash-128 checksum-bytes
    seed>> <cityhash-128> checksum-bytes ;

INSTANCE: farmhash-32 checksum
INSTANCE: farmhash-64 checksum
INSTANCE: farmhash-128 checksum
