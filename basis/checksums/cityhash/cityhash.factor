! Copyright (C) 2026 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
! Based on Google's CityHash; see LICENSE.txt for its MIT license.

USING: accessors checksums combinators endian kernel locals math
math.bitwise sequences ;
IN: checksums.cityhash

SINGLETON: cityhash-32
TUPLE: cityhash-64 seed ;
C: <cityhash-64> cityhash-64
TUPLE: cityhash-128 seed ;
C: <cityhash-128> cityhash-128

<PRIVATE

CONSTANT: k0 0xc3a5c85c97cb3127
CONSTANT: k1 0xb492b66fbe98f273
CONSTANT: k2 0x9ae16a3b2f90404f
CONSTANT: c1 0xcc9e2d51
CONSTANT: c2 0x1b873593

:: fetch32 ( bytes offset -- n )
    offset offset 4 + bytes <slice> le> ; inline

:: fetch64 ( bytes offset -- n )
    offset offset 8 + bytes <slice> le> ; inline

: swap32 ( n -- n' ) 4 >le be> ; inline
: swap64 ( n -- n' ) 8 >le be> ; inline

: fmix ( h -- h' )
    dup -16 shift bitxor 0x85ebca6b w*
    dup -13 shift bitxor 0xc2b2ae35 w*
    dup -16 shift bitxor ; inline

: mix32 ( a -- a' ) c1 w* -17 bitroll-32 c2 w* ; inline
: step32 ( h -- h' ) -19 bitroll-32 5 w* 0xe6546b64 w+ ; inline
: mur ( h a -- h' ) mix32 bitxor step32 ; inline

:: hash32-0to4 ( bytes seed -- hash )
    seed :> b!
    9 :> c!
    bytes [ 8 >signed b c1 w* w+ b! c b bitxor c! ] each
    c bytes length mur b mur fmix ;

:: hash32-5to12 ( bytes seed -- hash )
    bytes length :> len
    len 5 w* :> b
    b seed w+
    len bytes 0 fetch32 w+ mur
    b bytes len 4 - fetch32 w+ mur
    bytes len -1 shift 4 bitand fetch32 9 w+ mur
    seed bitxor fmix ;

:: hash32-13to24 ( bytes -- hash )
    bytes length :> len
    len
    bytes len -1 shift 4 - fetch32 mur
    bytes 4 fetch32 mur
    bytes len 8 - fetch32 mur
    bytes len -1 shift fetch32 mur
    bytes 0 fetch32 mur
    bytes len 4 - fetch32 mur fmix ;

:: finish32 ( h g f -- hash )
    g -11 bitroll-32 c1 w* -17 bitroll-32 c1 w* :> g'
    f -11 bitroll-32 c1 w* -17 bitroll-32 c1 w* :> f'
    h g' w+ step32 -17 bitroll-32 c1 w*
    f' w+ step32 -17 bitroll-32 c1 w* ;

:: hash32-long ( bytes -- hash )
    bytes length :> len
    len bytes len 4 - fetch32 mur bytes len 16 - fetch32 mur :> h!
    len c1 w* bytes len 8 - fetch32 mur bytes len 12 - fetch32 mur :> g!
    len c1 w* bytes len 20 - fetch32 mix32 w+ step32 :> f!
    len 1 - 20 /i <iota> [| i |
        i 20 * :> offset
        bytes offset fetch32 mix32 :> a0
        bytes offset 4 + fetch32 :> a1
        bytes offset 8 + fetch32 mix32 :> a2
        bytes offset 12 + fetch32 mix32 :> a3
        bytes offset 16 + fetch32 :> a4
        h a0 bitxor -18 bitroll-32 5 w* 0xe6546b64 w+ h!
        f a1 w+ -19 bitroll-32 c1 w* f!
        g a2 w+ -18 bitroll-32 5 w* 0xe6546b64 w+ g!
        h a3 a1 w+ bitxor step32 h!
        g a4 bitxor swap32 5 w* g!
        h a4 5 w* w+ swap32 h!
        f a0 w+ f!
        f h g f! g! h!
    ] each
    h g f finish32 ;

: hash32 ( bytes -- hash )
    dup length {
        { [ dup 4 <= ] [ drop 0 hash32-0to4 ] }
        { [ dup 12 <= ] [ drop 0 hash32-5to12 ] }
        { [ dup 24 <= ] [ drop hash32-13to24 ] }
        [ drop hash32-long ]
    } cond ;

: shift-mix ( n -- n' ) dup -47 shift bitxor ; inline

:: hash16-mul ( u v mul -- hash )
    u v bitxor mul W* shift-mix v bitxor mul W* shift-mix mul W* ;

: hash16 ( u v -- hash ) 0x9ddfea08eb382d69 hash16-mul ;

:: hash64-0to16 ( bytes -- hash )
    bytes length :> len
    k2 len 2 * W+ :> mul
    {
        { [ len 8 >= ] [
            bytes 0 fetch64 k2 W+ :> a
            bytes len 8 - fetch64 :> b
            b -37 bitroll-64 mul W* a W+
            a -25 bitroll-64 b W+ mul W* mul hash16-mul
        ] }
        { [ len 4 >= ] [
            bytes 0 fetch32 3 shift len W+
            bytes len 4 - fetch32 mul hash16-mul
        ] }
        { [ len 0 > ] [
            bytes first len -1 shift bytes nth 8 shift + k2 W*
            len bytes last 2 shift + k0 W* bitxor shift-mix k2 W*
        ] }
        [ k2 ]
    } cond ;

:: hash64-17to32 ( bytes -- hash )
    bytes length :> len
    k2 len 2 * W+ :> mul
    bytes 0 fetch64 k1 W* :> a
    bytes 8 fetch64 :> b
    bytes len 8 - fetch64 mul W* :> c
    bytes len 16 - fetch64 k2 W* :> d
    a b W+ -43 bitroll-64 c -30 bitroll-64 W+ d W+
    a b k2 W+ -18 bitroll-64 W+ c W+ mul hash16-mul ;

:: hash64-33to64 ( bytes -- hash )
    bytes length :> len
    k2 len 2 * W+ :> mul
    bytes 0 fetch64 k2 W* :> a
    bytes 8 fetch64 :> b
    bytes len 24 - fetch64 :> c
    bytes len 32 - fetch64 :> d
    bytes 16 fetch64 k2 W* :> e
    bytes 24 fetch64 9 W* :> f
    bytes len 8 - fetch64 :> g
    bytes len 16 - fetch64 mul W* :> h
    a g W+ -43 bitroll-64 b -30 bitroll-64 c W+ 9 W* W+ :> u
    a g W+ d bitxor f W+ 1 W+ :> v
    u v W+ mul W* swap64 h W+ :> w
    e f W+ -42 bitroll-64 c W+ :> x
    v w W+ mul W* swap64 g W+ mul W* :> y
    e f W+ c W+ :> z
    x z W+ mul W* y W+ swap64 b W+ :> a'
    z a' W+ mul W* d W+ h W+ shift-mix mul W* x W+ ;

:: weak-hash32 ( bytes offset a b -- low high )
    a bytes offset fetch64 W+ :> a'
    a' bytes offset 8 + fetch64 W+ bytes offset 16 + fetch64 W+ :> sum
    bytes offset 24 + fetch64 :> z
    sum z W+
    b a' W+ z W+ -21 bitroll-64 sum -44 bitroll-64 W+ a' W+ ;

! Shared 64-byte round used by CityHash64, CityHash128, and FarmHash64.
TUPLE: hash-state x y z v0 v1 w0 w1 ;

:: hash-round ( bytes offset state mul factor -- )
    state x>> state y>> W+ state v0>> W+ bytes offset 8 + fetch64 W+
    -37 bitroll-64 mul W* state w1>> factor W* bitxor :> x
    state y>> state v1>> W+ bytes offset 48 + fetch64 W+
    -42 bitroll-64 mul W* state v0>> factor W* W+
    bytes offset 40 + fetch64 W+ :> y
    state z>> state w0>> W+ -33 bitroll-64 mul W* :> z
    bytes offset state v1>> mul W* x state w0>> W+ weak-hash32 :> ( v0 v1 )
    bytes offset 32 + z state w1>> W+ y bytes offset 16 + fetch64 W+
    weak-hash32 :> ( w0 w1 )
    state z >>x y >>y x >>z v0 >>v0 v1 >>v1 w0 >>w0 w1 >>w1 drop ;

:: hash64-long ( bytes -- hash )
    bytes length :> len
    bytes len 40 - fetch64 :> x
    bytes len 16 - fetch64 bytes len 56 - fetch64 W+ :> y
    bytes len 48 - fetch64 len W+ bytes len 24 - fetch64 hash16 :> z
    x k1 W* bytes 0 fetch64 W+ y z
    bytes len 64 - len z weak-hash32
    bytes len 32 - y k1 W+ x weak-hash32 hash-state boa :> state
    len 1 - 64 /i <iota> [| i | bytes i 64 * state k1 1 hash-round ] each
    state v0>> state w0>> hash16 state y>> shift-mix k1 W* W+ state z>> W+
    state v1>> state w1>> hash16 state x>> W+ hash16 ;

: hash64 ( bytes -- hash )
    dup length {
        { [ dup 16 <= ] [ drop hash64-0to16 ] }
        { [ dup 32 <= ] [ drop hash64-17to32 ] }
        { [ dup 64 <= ] [ drop hash64-33to64 ] }
        [ drop hash64-long ]
    } cond ;

: >uint128 ( low high -- n ) 64 shift bitor ; inline

:: city-murmur ( bytes low high -- hash )
    bytes length :> len
    low :> a!
    high :> b!
    0 :> c!
    0 :> d!
    len 16 <= [
        a k1 W* shift-mix k1 W* a!
        b k1 W* bytes hash64-0to16 W+ c!
        a len 8 >= [ bytes 0 fetch64 ] [ c ] if W+ shift-mix d!
    ] [
        bytes len 8 - fetch64 k1 W+ a hash16 c!
        b len W+ c bytes len 16 - fetch64 W+ hash16 d!
        a d W+ a!
        len 1 - 16 /i <iota> [| i |
            a bytes i 16 * fetch64 k1 W* shift-mix k1 W* bitxor k1 W* a!
            b a bitxor b!
            c bytes i 16 * 8 + fetch64 k1 W* shift-mix k1 W* bitxor k1 W* c!
            d c bitxor d!
        ] each
    ] if
    a c hash16 a!
    d b hash16 b!
    a b bitxor b a hash16 >uint128 ;

:: hash128-long ( bytes low high -- hash )
    bytes length :> len
    len k1 W* :> z
    high k1 bitxor -49 bitroll-64 k1 W* bytes 0 fetch64 W+ :> v0
    v0 -42 bitroll-64 k1 W* bytes 8 fetch64 W+ :> v1
    high z W+ -35 bitroll-64 k1 W* low W+ :> w0
    low bytes 88 fetch64 W+ -53 bitroll-64 k1 W* :> w1
    low high z v0 v1 w0 w1 hash-state boa :> state
    len 128 /i 2 * <iota> [| i | bytes i 64 * state k1 1 hash-round ] each
    state
        state x>> state v0>> state z>> W+ -49 bitroll-64 k0 W* W+ >>x
        state y>> k0 W* state w1>> -37 bitroll-64 W+ >>y
        state z>> k0 W* state w0>> -27 bitroll-64 W+ >>z
        state w0>> 9 W* >>w0
        state v0>> k0 W* >>v0 drop
    len 128 mod 31 + 32 /i <iota> [| i |
        len i 1 + 32 * - :> offset
        state
            state x>> state y>> W+ -42 bitroll-64 k0 W* state v1>> W+ >>y
            state w0>> bytes offset 16 + fetch64 W+ >>w0
            state x>> k0 W* state w0>> W+ >>x
            state z>> state w1>> W+ bytes offset fetch64 W+ >>z
            state w1>> state v0>> W+ >>w1 drop
        bytes offset state v0>> state z>> W+ state v1>> weak-hash32
        :> ( next-v0 next-v1 )
        state next-v0 k0 W* >>v0 next-v1 >>v1 drop
    ] each
    state x>> state v0>> hash16 :> x
    state y>> state z>> W+ state w0>> hash16 :> y
    x state v1>> W+ state w1>> hash16 y W+
    x state w1>> W+ y state v1>> W+ hash16 >uint128 ;

:: hash128-seeded ( bytes seed -- hash )
    seed 64 bits :> low
    seed -64 shift 64 bits :> high
    bytes length 128 <
    [ bytes low high city-murmur ] [ bytes low high hash128-long ] if ;

:: hash128 ( bytes -- hash )
    bytes length 16 >= [
        bytes 16 tail-slice
        bytes 0 fetch64 bytes 8 fetch64 k0 W+ >uint128 hash128-seeded
    ] [ bytes k0 k1 >uint128 hash128-seeded ] if ;

PRIVATE>

M: cityhash-32 checksum-bytes drop hash32 ;

M: cityhash-64 checksum-bytes
    seed>> [ [ hash64 k2 W- ] dip 64 bits hash16 ] [ hash64 ] if* ;

M: cityhash-128 checksum-bytes
    seed>> [ hash128-seeded ] [ hash128 ] if* ;

INSTANCE: cityhash-32 checksum
INSTANCE: cityhash-64 checksum
INSTANCE: cityhash-128 checksum
