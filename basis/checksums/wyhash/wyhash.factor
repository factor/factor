! Copyright (C) 2021 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.data byte-arrays checksums
endian grouping kernel math math.bitwise
sequences sequences.generalizations sequences.private
specialized-arrays ;
SPECIALIZED-ARRAY: uint64_t
IN: checksums.wyhash

<PRIVATE

:: wymum ( a b -- a' b' )
    a -32 shift 32 bits :> Ha
    b -32 shift 32 bits :> Hb
    a 32 bits :> La
    b 32 bits :> Lb
    Ha Hb W* :> RH
    Ha Lb W* :> RM0
    Hb La W* :> RM1
    La Lb W* :> RL

    RL RM0 32 shift W+ :> T
    T RM1 32 shift W+ :> LO
    T RL < 1 0 ? LO T < 1 0 ? W+ :> C
    RH RM0 -32 shift W+ RM1 -32 shift W+ C W+ :> HI

    LO HI ;

: wymix ( a b -- c )
    wymum bitxor ;

CONSTANT: P0 0xa0761d6478bd642f
CONSTANT: P1 0xe7037ed1a0b428db
CONSTANT: P2 0x8ebc6af09c88c6e3
CONSTANT: P3 0x589965cc75374cc3

: wyrand ( seed -- seed' rand )
    P0 W+ dup dup P1 bitxor wymix ;

: wyhash64 ( a b -- c )
    [ P0 bitxor ] [ P1 bitxor ] bi* wymum
    [ P0 bitxor ] [ P1 bitxor ] bi* wymix ;

: wy2u01 ( r -- [0,1) )
    -12 shift 0x1.0p-52 * ;

: wy2gau ( r -- gaussian )
    [ ] [ -21 shift ] [ -42 shift ] tri
    [ 0x1fffff bitand ] tri@ + + 0x1.0p-20 * 3.0 - ;

:: native-mapper ( from to bytes c-type -- seq )
    from to bytes <slice>
    bytes byte-array? alien.data:little-endian? and
    [ c-type cast-array ]
    [ c-type heap-size <groups> [ le> ] map ] if ; inline

PRIVATE>

TUPLE: wyhash seed ;

C: <wyhash> wyhash

M:: wyhash checksum-bytes ( bytes checksum -- value )

    checksum seed>> P0 bitxor :> seed!
    bytes length :> len

    len 16 <= [
        len 8 <= [
            len 4 >= [
                bytes [ 4 head-slice ] [ 4 tail-slice* ] bi [ le> ] bi@
            ] [
                len 0 > [
                    0 bytes nth 16 shift
                    len 2/ bytes nth 8 shift bitor
                    len 1 - bytes nth bitor
                    0
                ] [
                    0 0
                ] if
            ] if
        ] [
            bytes [ 8 head-slice ] [ 8 tail-slice* ] bi [ le> ] bi@
        ] if
    ] [

        len 1 - dup 48 mod - :> len/48
        len 1 - dup 16 mod - :> len/16

        0 len/48 bytes uint64_t native-mapper [
            seed :> see1!
            seed :> see2!
            6 <groups> [
                6 firstn-unsafe :> ( n0 n1 n2 n3 n4 n5 )
                n0 P1 bitxor n1 seed bitxor wymix seed!
                n2 P2 bitxor n3 see1 bitxor wymix see1!
                n4 P3 bitxor n5 see2 bitxor wymix see2!
            ] each
            see1 see2 bitxor seed bitxor seed!
        ] unless-empty

        len/48 len/16 bytes uint64_t native-mapper [
            2 <groups> [
                first2-unsafe :> ( n0 n1 )
                n0 P1 bitxor n1 seed bitxor wymix seed!
            ] each
        ] unless-empty

        len 16 - len bytes uint64_t native-mapper first2

    ] if :> ( a b )

    len P1 bitxor a P1 bitxor b seed bitxor wymix wymix ;
