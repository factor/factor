! Copyright (C) 2014 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types alien.data byte-arrays
checksums combinators endian generalizations grouping kernel
math math.bitwise sequences specialized-arrays ;
SPECIALIZED-ARRAY: uint64_t

IN: checksums.xxhash

CONSTANT: prime1 2654435761
CONSTANT: prime2 2246822519
CONSTANT: prime3 3266489917
CONSTANT: prime4 668265263
CONSTANT: prime5 374761393

TUPLE: xxhash seed ;

C: <xxhash> xxhash

<PRIVATE

:: native-mapper ( from to bytes c-type -- seq )
    from to bytes <slice>
    bytes byte-array? alien.data:little-endian? and
    [ c-type cast-array ]
    [ c-type heap-size <groups> [ le> ] map ] if ; inline

PRIVATE>

M:: xxhash checksum-bytes ( bytes checksum -- value )
    checksum seed>> :> seed
    bytes length :> len

    len dup 16 mod - :> len/16
    len dup 4 mod - :> len/4

    len 16 >= [

        seed prime1 w+ prime2 w+
        seed prime2 w+
        seed
        seed prime1 w-

        0 len/16 bytes uint native-mapper

        4 <groups> [
            first4
            [ prime2 w* w+ 13 bitroll-32 prime1 w* ]
            4 napply
        ] each

        {
            [ 1 bitroll-32 ]
            [ 7 bitroll-32 ]
            [ 12 bitroll-32 ]
            [ 18 bitroll-32 ]
        } spread w+ w+ w+
    ] [
        seed prime5 w+
    ] if

    len w+

    len/16 len/4 bytes uint native-mapper
    [ prime3 w* w+ 17 bitroll-32 prime4 w* ] each

    bytes len/4 tail-slice
    [ prime5 w* w+ 11 bitroll-32 prime1 w* ] each

    [ -15 shift ] [ bitxor ] bi prime2 w*
    [ -13 shift ] [ bitxor ] bi prime3 w*
    [ -16 shift ] [ bitxor ] bi ;

INSTANCE: xxhash checksum
