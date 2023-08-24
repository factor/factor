! Copyright (C) 2006, 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data byte-arrays checksums
checksums.common combinators grouping hints kernel
kernel.private literals math math.bitwise
math.functions sequences sequences.private specialized-arrays ;
SPECIALIZED-ARRAY: uint
IN: checksums.md5

SINGLETON: md5

INSTANCE: md5 block-checksum

TUPLE: md5-state < block-checksum-state
{ state uint-array }
{ old-state uint-array } ;

: <md5-state> ( -- md5 )
    md5-state new-checksum-state
        64 >>block-size
        uint-array{ 0x67452301 0xefcdab89 0x98badcfe 0x10325476 }
        [ clone >>state ] [ >>old-state ] bi ;

M: md5 initialize-checksum-state drop <md5-state> ;

<PRIVATE

: update-md5 ( md5 -- )
    [ state>> ] [ old-state>> [ w+ ] 2map dup clone ] [ ] tri
    [ old-state<< ] [ state<< ] bi ; inline

CONSTANT: T $[
    80 <iota> [ sin abs 32 2^ * >integer ] uint-array{ } map-as
]

:: F ( X Y Z -- FXYZ )
    ! F(X,Y,Z) = XY v not(X) Z
    X Y bitand X bitnot Z bitand bitor ; inline

:: G ( X Y Z -- GXYZ )
    ! G(X,Y,Z) = XZ v Y not(Z)
    X Z bitand Y Z bitnot bitand bitor ; inline

: H ( X Y Z -- HXYZ )
    ! H(X,Y,Z) = X xor Y xor Z
    bitxor bitxor ; inline

:: I ( X Y Z -- IXYZ )
    ! I(X,Y,Z) = Y xor (X v not(Z))
    Z bitnot X bitor Y bitxor ; inline

CONSTANT: S11 7
CONSTANT: S12 12
CONSTANT: S13 17
CONSTANT: S14 22
CONSTANT: S21 5
CONSTANT: S22 9
CONSTANT: S23 14
CONSTANT: S24 20
CONSTANT: S31 4
CONSTANT: S32 11
CONSTANT: S33 16
CONSTANT: S34 23
CONSTANT: S41 6
CONSTANT: S42 10
CONSTANT: S43 15
CONSTANT: S44 21

CONSTANT: a 0
CONSTANT: b 1
CONSTANT: c 2
CONSTANT: d 3

:: (ABCD) ( x state a b c d k s i quot -- )
    ! a = b + ((a + F(b,c,d) + X[k] + T[i]) <<< s)
    a state [
        b state nth-unsafe
        c state nth-unsafe
        d state nth-unsafe quot call w+
        k x nth-unsafe w+
        i T nth-unsafe w+
        s bitroll-32
        b state nth-unsafe w+
    ] change-nth-unsafe ; inline

MACRO: with-md5-round ( ops quot -- quot )
    '[ [ _ (ABCD) ] compose ] map '[ _ 2cleave ] ;

: (process-md5-block-F) ( block state -- )
    { uint-array uint-array } declare {
        [ a b c d 0  S11 1  ]
        [ d a b c 1  S12 2  ]
        [ c d a b 2  S13 3  ]
        [ b c d a 3  S14 4  ]
        [ a b c d 4  S11 5  ]
        [ d a b c 5  S12 6  ]
        [ c d a b 6  S13 7  ]
        [ b c d a 7  S14 8  ]
        [ a b c d 8  S11 9  ]
        [ d a b c 9  S12 10 ]
        [ c d a b 10 S13 11 ]
        [ b c d a 11 S14 12 ]
        [ a b c d 12 S11 13 ]
        [ d a b c 13 S12 14 ]
        [ c d a b 14 S13 15 ]
        [ b c d a 15 S14 16 ]
    } [ F ] with-md5-round ;

: (process-md5-block-G) ( block state -- )
    { uint-array uint-array } declare {
        [ a b c d 1  S21 17 ]
        [ d a b c 6  S22 18 ]
        [ c d a b 11 S23 19 ]
        [ b c d a 0  S24 20 ]
        [ a b c d 5  S21 21 ]
        [ d a b c 10 S22 22 ]
        [ c d a b 15 S23 23 ]
        [ b c d a 4  S24 24 ]
        [ a b c d 9  S21 25 ]
        [ d a b c 14 S22 26 ]
        [ c d a b 3  S23 27 ]
        [ b c d a 8  S24 28 ]
        [ a b c d 13 S21 29 ]
        [ d a b c 2  S22 30 ]
        [ c d a b 7  S23 31 ]
        [ b c d a 12 S24 32 ]
    } [ G ] with-md5-round ;

: (process-md5-block-H) ( block state -- )
    { uint-array uint-array } declare {
        [ a b c d 5  S31 33 ]
        [ d a b c 8  S32 34 ]
        [ c d a b 11 S33 35 ]
        [ b c d a 14 S34 36 ]
        [ a b c d 1  S31 37 ]
        [ d a b c 4  S32 38 ]
        [ c d a b 7  S33 39 ]
        [ b c d a 10 S34 40 ]
        [ a b c d 13 S31 41 ]
        [ d a b c 0  S32 42 ]
        [ c d a b 3  S33 43 ]
        [ b c d a 6  S34 44 ]
        [ a b c d 9  S31 45 ]
        [ d a b c 12 S32 46 ]
        [ c d a b 15 S33 47 ]
        [ b c d a 2  S34 48 ]
    } [ H ] with-md5-round ;

: (process-md5-block-I) ( block state -- )
    { uint-array uint-array } declare {
        [ a b c d 0  S41 49 ]
        [ d a b c 7  S42 50 ]
        [ c d a b 14 S43 51 ]
        [ b c d a 5  S44 52 ]
        [ a b c d 12 S41 53 ]
        [ d a b c 3  S42 54 ]
        [ c d a b 10 S43 55 ]
        [ b c d a 1  S44 56 ]
        [ a b c d 8  S41 57 ]
        [ d a b c 15 S42 58 ]
        [ c d a b 6  S43 59 ]
        [ b c d a 13 S44 60 ]
        [ a b c d 4  S41 61 ]
        [ d a b c 11 S42 62 ]
        [ c d a b 2  S43 63 ]
        [ b c d a 9  S44 64 ]
    } [ I ] with-md5-round ;

: byte-array>le ( byte-array -- byte-array )
    little-endian? [
        dup 4 <groups> [
            [ [ 1 2 ] dip exchange-unsafe ]
            [ [ 0 3 ] dip exchange-unsafe ] bi
        ] each
    ] unless ;

HINTS: byte-array>le byte-array ;

M: md5-state checksum-block
    [
        [ byte-array>le uint cast-array ] [ state>> ] bi* {
            [ (process-md5-block-F) ]
            [ (process-md5-block-G) ]
            [ (process-md5-block-H) ]
            [ (process-md5-block-I) ]
        } 2cleave
    ] [
        update-md5
    ] bi ;

: md5>checksum ( md5 -- bytes )
    state>> underlying>> byte-array>le ;

M: md5-state clone
    call-next-method
    [ clone ] change-state
    [ clone ] change-old-state ;

M: md5-state get-checksum
    clone
    [ bytes>> f ] [ bytes-read>> pad-last-block ] [ ] tri
    [ [ checksum-block ] curry each ] [ md5>checksum ] bi ;

PRIVATE>
