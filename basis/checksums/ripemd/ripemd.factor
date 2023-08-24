! Copyright (C) 2017 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data byte-arrays checksums
checksums.common combinators grouping hints kernel
kernel.private math math.bitwise sequences sequences.private
specialized-arrays ;
SPECIALIZED-ARRAY: uint
IN: checksums.ripemd

SINGLETON: ripemd-160

INSTANCE: ripemd-160 block-checksum

TUPLE: ripemd-160-state < block-checksum-state
{ state1 uint-array }
{ state2 uint-array }
{ old-state uint-array } ;

: <ripemd-160-state> ( -- ripemd-160 )
    ripemd-160-state new-checksum-state
        64 >>block-size
        uint-array{ 0x67452301 0xefcdab89 0x98badcfe 0x10325476 0xc3d2e1f0 }
        [ clone >>state1 ] [ clone >>state2 ] [ >>old-state ] tri ;

M: ripemd-160 initialize-checksum-state drop <ripemd-160-state> ;

<PRIVATE

: combine-ripemd-160 ( ripemd-160-state -- new-state )
    [ old-state>> 1 cut prepend ]
    [ state1>> 2 cut prepend ]
    [ state2>> 3 cut prepend ] tri
    [ w+ ] 2map [ w+ ] 2map ; inline

: update-ripemd-160 ( ripemd-160 -- )
    [ combine-ripemd-160 dup clone dup clone ] [ ] bi
    [ old-state<< ] [ state1<< ] [ state2<< ] tri ; inline

: F ( x y z -- out ) bitxor bitxor ;  inline
: G ( x y z -- out ) pick bitnot swap [ bitand ] 2bi@ bitor ; inline
: H ( x y z -- out ) [ bitnot bitor ] [ bitxor ] bi* ; inline
: I ( x y z -- out ) tuck bitnot [ bitand ] 2bi@ bitor ; inline
: J ( x y z -- out ) bitnot bitor bitxor ; inline

CONSTANT: T11 0x00000000
CONSTANT: T12 0x5A827999
CONSTANT: T13 0x6ED9EBA1
CONSTANT: T14 0x8F1BBCDC
CONSTANT: T15 0xA953FD4E

CONSTANT: T21 0x50A28BE6
CONSTANT: T22 0x5C4DD124
CONSTANT: T23 0x6D703EF3
CONSTANT: T24 0x7A6D76E9
CONSTANT: T25 0x00000000

CONSTANT: a 0
CONSTANT: b 1
CONSTANT: c 2
CONSTANT: d 3
CONSTANT: e 4

CONSTANT: S1 uint-array{
11 14 15 12 5 8 7 9 11 13 14 15 6 7 9 8
7 6 8 13 11 9 7 15 7 12 15 9 11 7 13 12
11 13 6 7 14 9 13 15 14 8 13 6 5 12 7 5
11 12 14 15 14 15 9 8 9 14 5 6 8 6 5 12
9 15 5 11 6 8 13 12 5 12 13 14 11 8 5 6
}

CONSTANT: S2 uint-array{
8 9 9 11 13 15 15 5 7 7 8 11 14 14 12 6
9 13 15 7 12 8 9 11 7 7 12 7 6 15 13 11
9 7 15 11 8 6 6 14 12 13 5 14 13 13 7 5
15 5 8 11 14 14 6 14 6 9 12 9 12 5 15 8
8 5 12 9 12 5 14 6 8 13 6 5 15 13 11 11
}

:: (ABCDE) ( x state a b c d e k S s T quot -- )
    ! a = e + ((a + F(b,c,d) + X[k] + T) <<< S[s])
    ! c = c <<< 10
    a state [
        b state nth-unsafe
        c state nth-unsafe
        d state nth-unsafe quot call w+
        k x nth-unsafe w+
        T w+
        s S nth-unsafe bitroll-32
        e state nth-unsafe w+
    ] change-nth-unsafe
    c state [ 10 bitroll-32 ] change-nth-unsafe ; inline

MACRO: with-ripemd-160-round ( ops quot -- quot )
    '[ [ _ (ABCDE) ] compose ] map '[ _ 2cleave ] ;

: (process-ripemd-160-block-F1) ( block state1 -- )
    { uint-array uint-array } declare {
        [ a b c d e  0 S1  0 T11 ]
        [ e a b c d  1 S1  1 T11 ]
        [ d e a b c  2 S1  2 T11 ]
        [ c d e a b  3 S1  3 T11 ]
        [ b c d e a  4 S1  4 T11 ]
        [ a b c d e  5 S1  5 T11 ]
        [ e a b c d  6 S1  6 T11 ]
        [ d e a b c  7 S1  7 T11 ]
        [ c d e a b  8 S1  8 T11 ]
        [ b c d e a  9 S1  9 T11 ]
        [ a b c d e 10 S1 10 T11 ]
        [ e a b c d 11 S1 11 T11 ]
        [ d e a b c 12 S1 12 T11 ]
        [ c d e a b 13 S1 13 T11 ]
        [ b c d e a 14 S1 14 T11 ]
        [ a b c d e 15 S1 15 T11 ]
    } [ F ] with-ripemd-160-round ;

: (process-ripemd-160-block-G1) ( block state1 -- )
    { uint-array uint-array } declare {
        [ e a b c d  7 S1 16 T12 ]
        [ d e a b c  4 S1 17 T12 ]
        [ c d e a b 13 S1 18 T12 ]
        [ b c d e a  1 S1 19 T12 ]
        [ a b c d e 10 S1 20 T12 ]
        [ e a b c d  6 S1 21 T12 ]
        [ d e a b c 15 S1 22 T12 ]
        [ c d e a b  3 S1 23 T12 ]
        [ b c d e a 12 S1 24 T12 ]
        [ a b c d e  0 S1 25 T12 ]
        [ e a b c d  9 S1 26 T12 ]
        [ d e a b c  5 S1 27 T12 ]
        [ c d e a b  2 S1 28 T12 ]
        [ b c d e a 14 S1 29 T12 ]
        [ a b c d e 11 S1 30 T12 ]
        [ e a b c d  8 S1 31 T12 ]
    } [ G ] with-ripemd-160-round ;

: (process-ripemd-160-block-H1) ( block state1 -- )
    { uint-array uint-array } declare {
        [ d e a b c  3 S1 32 T13 ]
        [ c d e a b 10 S1 33 T13 ]
        [ b c d e a 14 S1 34 T13 ]
        [ a b c d e  4 S1 35 T13 ]
        [ e a b c d  9 S1 36 T13 ]
        [ d e a b c 15 S1 37 T13 ]
        [ c d e a b  8 S1 38 T13 ]
        [ b c d e a  1 S1 39 T13 ]
        [ a b c d e  2 S1 40 T13 ]
        [ e a b c d  7 S1 41 T13 ]
        [ d e a b c  0 S1 42 T13 ]
        [ c d e a b  6 S1 43 T13 ]
        [ b c d e a 13 S1 44 T13 ]
        [ a b c d e 11 S1 45 T13 ]
        [ e a b c d  5 S1 46 T13 ]
        [ d e a b c 12 S1 47 T13 ]
    } [ H ] with-ripemd-160-round ;

: (process-ripemd-160-block-I1) ( block state1 -- )
    { uint-array uint-array } declare {
        [ c d e a b  1 S1 48 T14 ]
        [ b c d e a  9 S1 49 T14 ]
        [ a b c d e 11 S1 50 T14 ]
        [ e a b c d 10 S1 51 T14 ]
        [ d e a b c  0 S1 52 T14 ]
        [ c d e a b  8 S1 53 T14 ]
        [ b c d e a 12 S1 54 T14 ]
        [ a b c d e  4 S1 55 T14 ]
        [ e a b c d 13 S1 56 T14 ]
        [ d e a b c  3 S1 57 T14 ]
        [ c d e a b  7 S1 58 T14 ]
        [ b c d e a 15 S1 59 T14 ]
        [ a b c d e 14 S1 60 T14 ]
        [ e a b c d  5 S1 61 T14 ]
        [ d e a b c  6 S1 62 T14 ]
        [ c d e a b  2 S1 63 T14 ]
    } [ I ] with-ripemd-160-round ;

: (process-ripemd-160-block-J1) ( block state1 -- )
    { uint-array uint-array } declare {
        [ b c d e a  4 S1 64 T15 ]
        [ a b c d e  0 S1 65 T15 ]
        [ e a b c d  5 S1 66 T15 ]
        [ d e a b c  9 S1 67 T15 ]
        [ c d e a b  7 S1 68 T15 ]
        [ b c d e a 12 S1 69 T15 ]
        [ a b c d e  2 S1 70 T15 ]
        [ e a b c d 10 S1 71 T15 ]
        [ d e a b c 14 S1 72 T15 ]
        [ c d e a b  1 S1 73 T15 ]
        [ b c d e a  3 S1 74 T15 ]
        [ a b c d e  8 S1 75 T15 ]
        [ e a b c d 11 S1 76 T15 ]
        [ d e a b c  6 S1 77 T15 ]
        [ c d e a b 15 S1 78 T15 ]
        [ b c d e a 13 S1 79 T15 ]
    } [ J ] with-ripemd-160-round ;


: (process-ripemd-160-block-J2) ( block state2 -- )
    { uint-array uint-array } declare {
        [ a b c d e  5 S2  0 T21 ]
        [ e a b c d 14 S2  1 T21 ]
        [ d e a b c  7 S2  2 T21 ]
        [ c d e a b  0 S2  3 T21 ]
        [ b c d e a  9 S2  4 T21 ]
        [ a b c d e  2 S2  5 T21 ]
        [ e a b c d 11 S2  6 T21 ]
        [ d e a b c  4 S2  7 T21 ]
        [ c d e a b 13 S2  8 T21 ]
        [ b c d e a  6 S2  9 T21 ]
        [ a b c d e 15 S2 10 T21 ]
        [ e a b c d  8 S2 11 T21 ]
        [ d e a b c  1 S2 12 T21 ]
        [ c d e a b 10 S2 13 T21 ]
        [ b c d e a  3 S2 14 T21 ]
        [ a b c d e 12 S2 15 T21 ]
    } [ J ] with-ripemd-160-round ;

: (process-ripemd-160-block-I2) ( block state2 -- )
    { uint-array uint-array } declare {
        [ e a b c d  6 S2 16 T22 ]
        [ d e a b c 11 S2 17 T22 ]
        [ c d e a b  3 S2 18 T22 ]
        [ b c d e a  7 S2 19 T22 ]
        [ a b c d e  0 S2 20 T22 ]
        [ e a b c d 13 S2 21 T22 ]
        [ d e a b c  5 S2 22 T22 ]
        [ c d e a b 10 S2 23 T22 ]
        [ b c d e a 14 S2 24 T22 ]
        [ a b c d e 15 S2 25 T22 ]
        [ e a b c d  8 S2 26 T22 ]
        [ d e a b c 12 S2 27 T22 ]
        [ c d e a b  4 S2 28 T22 ]
        [ b c d e a  9 S2 29 T22 ]
        [ a b c d e  1 S2 30 T22 ]
        [ e a b c d  2 S2 31 T22 ]
    } [ I ] with-ripemd-160-round ;

: (process-ripemd-160-block-H2) ( block state2 -- )
    { uint-array uint-array } declare {
        [ d e a b c 15 S2 32 T23 ]
        [ c d e a b  5 S2 33 T23 ]
        [ b c d e a  1 S2 34 T23 ]
        [ a b c d e  3 S2 35 T23 ]
        [ e a b c d  7 S2 36 T23 ]
        [ d e a b c 14 S2 37 T23 ]
        [ c d e a b  6 S2 38 T23 ]
        [ b c d e a  9 S2 39 T23 ]
        [ a b c d e 11 S2 40 T23 ]
        [ e a b c d  8 S2 41 T23 ]
        [ d e a b c 12 S2 42 T23 ]
        [ c d e a b  2 S2 43 T23 ]
        [ b c d e a 10 S2 44 T23 ]
        [ a b c d e  0 S2 45 T23 ]
        [ e a b c d  4 S2 46 T23 ]
        [ d e a b c 13 S2 47 T23 ]
    } [ H ] with-ripemd-160-round ;

: (process-ripemd-160-block-G2) ( block state2 -- )
    { uint-array uint-array } declare {
        [ c d e a b  8 S2 48 T24 ]
        [ b c d e a  6 S2 49 T24 ]
        [ a b c d e  4 S2 50 T24 ]
        [ e a b c d  1 S2 51 T24 ]
        [ d e a b c  3 S2 52 T24 ]
        [ c d e a b 11 S2 53 T24 ]
        [ b c d e a 15 S2 54 T24 ]
        [ a b c d e  0 S2 55 T24 ]
        [ e a b c d  5 S2 56 T24 ]
        [ d e a b c 12 S2 57 T24 ]
        [ c d e a b  2 S2 58 T24 ]
        [ b c d e a 13 S2 59 T24 ]
        [ a b c d e  9 S2 60 T24 ]
        [ e a b c d  7 S2 61 T24 ]
        [ d e a b c 10 S2 62 T24 ]
        [ c d e a b 14 S2 63 T24 ]
    } [ G ] with-ripemd-160-round ;

: (process-ripemd-160-block-F2) ( block state2 -- )
    { uint-array uint-array } declare {
        [ b c d e a 12 S2 64 T25 ]
        [ a b c d e 15 S2 65 T25 ]
        [ e a b c d 10 S2 66 T25 ]
        [ d e a b c  4 S2 67 T25 ]
        [ c d e a b  1 S2 68 T25 ]
        [ b c d e a  5 S2 69 T25 ]
        [ a b c d e  8 S2 70 T25 ]
        [ e a b c d  7 S2 71 T25 ]
        [ d e a b c  6 S2 72 T25 ]
        [ c d e a b  2 S2 73 T25 ]
        [ b c d e a 13 S2 74 T25 ]
        [ a b c d e 14 S2 75 T25 ]
        [ e a b c d  0 S2 76 T25 ]
        [ d e a b c  3 S2 77 T25 ]
        [ c d e a b  9 S2 78 T25 ]
        [ b c d e a 11 S2 79 T25 ]
    } [ F ] with-ripemd-160-round ;

: byte-array>le ( byte-array -- byte-array )
    little-endian? [
        dup 4 <groups> [
            [ [ 1 2 ] dip exchange-unsafe ]
            [ [ 0 3 ] dip exchange-unsafe ] bi
        ] each
    ] unless ;

HINTS: byte-array>le byte-array ;

M: ripemd-160-state checksum-block
    [
        [ byte-array>le uint cast-array ] dip [
        state1>> {
            [ (process-ripemd-160-block-F1) ]
            [ (process-ripemd-160-block-G1) ]
            [ (process-ripemd-160-block-H1) ]
            [ (process-ripemd-160-block-I1) ]
            [ (process-ripemd-160-block-J1) ]
        } 2cleave ] [
        state2>> {
            [ (process-ripemd-160-block-J2) ]
            [ (process-ripemd-160-block-I2) ]
            [ (process-ripemd-160-block-H2) ]
            [ (process-ripemd-160-block-G2) ]
            [ (process-ripemd-160-block-F2) ]
        } 2cleave ] 2bi
    ] [
        update-ripemd-160
    ] bi ;

: ripemd-160>checksum ( ripemd-160 -- bytes )
    old-state>> underlying>> byte-array>le ;

M: ripemd-160-state clone
    call-next-method
    [ clone ] change-state1 [ clone ] change-state2
    [ clone ] change-old-state ;

M: ripemd-160-state get-checksum
    clone
    [ bytes>> f ] [ bytes-read>> pad-last-block ] [ ] tri
    [ [ checksum-block ] curry each ] [ ripemd-160>checksum ] bi ;

PRIVATE>
