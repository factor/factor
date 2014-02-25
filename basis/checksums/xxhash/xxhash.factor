! Copyright (C) 2014 John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.c-types alien.data byte-arrays
checksums combinators generalizations grouping io.binary kernel
locals math math.bitwise math.ranges sequences ;

IN: checksums.xxhash

CONSTANT: prime1 2654435761
CONSTANT: prime2 2246822519
CONSTANT: prime3 3266489917
CONSTANT: prime4 668265263
CONSTANT: prime5 374761393

TUPLE: xxhash seed ;

C: <xxhash> xxhash

M:: xxhash checksum-bytes ( bytes checksum -- value )
    checksum seed>> :> seed
    bytes length :> len

    len 16 >= [

        seed prime1 w+ prime2 w+
        seed prime2 w+
        seed
        seed prime1 w-

        bytes byte-array? little-endian? and [
            0 len dup 16 mod - 4 - 4 <range>
            [ bytes <displaced-alien> uint deref ] map
        ] [
            bytes len 16 mod head-slice* 4 <groups> [ le> ] map
        ] if

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

    bytes len 16 mod tail-slice*
    dup length dup 4 mod - cut-slice [
        4 <groups> [
            le> prime3 w* w+ 17 bitroll-32 prime4 w*
        ] each
    ] [
        [
            prime5 w* w+ 11 bitroll-32 prime1 w*
        ] each
    ] bi*

    [ -15 shift ] [ bitxor ] bi prime2 w*
    [ -13 shift ] [ bitxor ] bi prime3 w*
    [ -16 shift ] [ bitxor ] bi ;

INSTANCE: xxhash checksum
