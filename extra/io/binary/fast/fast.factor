! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data byte-arrays combinators
combinators.smart endian fry hints kernel locals macros math
math.ranges sequences sequences.generalizations ;
RENAME: be> io.binary => slow-be>
RENAME: le> io.binary => slow-le>
RENAME: signed-be> io.binary => slow-signed-be>
RENAME: signed-le> io.binary => slow-signed-le>
RENAME: >be io.binary => >slow-be
RENAME: >le io.binary => >slow-le
IN: io.binary.fast

ERROR: bad-length bytes n ;

: check-length ( bytes n -- bytes n )
    2dup [ length ] dip > [ bad-length ] when ; inline

<<
: be-range ( n -- range )
    1 - 8 * 0 -8 <range> ; inline

: le-range ( n -- range )
    1 - 8 * 0 swap 8 <range> ; inline

: reassemble-bytes ( range -- quot )
    [ [ [ ] ] [ '[ _ shift ] ] if-zero ] map
    '[ [ _ spread ] [ bitor ] reduce-outputs ] ; inline

MACRO: reassemble-be ( n -- quot ) be-range reassemble-bytes ;

MACRO: reassemble-le ( n -- quot ) le-range reassemble-bytes ;
>>

:: n-be> ( bytes n -- x )
    bytes n check-length drop n firstn-unsafe n reassemble-be ; inline

:: n-le> ( bytes n -- x )
    bytes n check-length drop n firstn-unsafe n reassemble-le ; inline

HINTS: n-be> { byte-array object } ;
HINTS: n-le> { byte-array object } ;

<PRIVATE
: if-endian ( endian bytes-quot seq-quot -- )
    [
        compute-native-endianness =
        [ dup byte-array? ] [ f ] if
    ] 2dip if ; inline
PRIVATE>

: 2be> ( bytes -- x )
    big-endian [ uint16_t deref ] [ 2 n-be> ] if-endian ;

: 4be> ( bytes -- x )
    big-endian [ uint32_t deref ] [ 4 n-be> ] if-endian ;

: 8be> ( bytes -- x )
    big-endian [ uint64_t deref ] [ 8 n-be> ] if-endian ;

: be> ( bytes -- x )
    dup length {
        { 2 [ 2be> ] }
        { 4 [ 4be> ] }
        { 8 [ 8be> ] }
        [ drop slow-be> ]
    } case ;

: signed-be> ( bytes -- x )
    compute-native-endianness big-endian = [
        dup byte-array? [
            dup length {
                { 2 [ int16_t deref ] }
                { 4 [ int32_t deref ] }
                { 8 [ int64_t deref ] }
                [ drop slow-signed-be> ]
            } case
        ] [ slow-signed-be> ] if
    ] [ slow-signed-be> ] if ;

: 2le> ( bytes -- x )
    little-endian [ uint16_t deref ] [ 2 n-le> ] if-endian ;

: 4le> ( bytes -- x )
    little-endian [ uint32_t deref ] [ 4 n-le> ] if-endian ;

: 8le> ( bytes -- x )
    little-endian [ uint64_t deref ] [ 8 n-le> ] if-endian ;

: le> ( bytes -- x )
    dup length {
        { 2 [ 2le> ] }
        { 4 [ 4le> ] }
        { 8 [ 8le> ] }
        [ drop slow-le> ]
    } case ;

: signed-le> ( bytes -- x )
    compute-native-endianness little-endian = [
        dup byte-array? [
            dup length {
                { 2 [ int16_t deref ] }
                { 4 [ int32_t deref ] }
                { 8 [ int64_t deref ] }
                [ drop slow-signed-le> ]
            } case
        ] [ slow-signed-le> ] if
    ] [ slow-signed-le> ] if ;

: >le ( x n -- bytes )
    compute-native-endianness little-endian = [
        {
            { 2 [ int16_t <ref> ] }
            { 4 [ int32_t <ref> ] }
            { 8 [ int64_t <ref> ] }
            [ >slow-le ]
        } case
    ] [ >slow-le ] if ;

: >be ( x n -- bytes )
    compute-native-endianness big-endian = [
        {
            { 2 [ int16_t <ref> ] }
            { 4 [ int32_t <ref> ] }
            { 8 [ int64_t <ref> ] }
            [ >slow-be ]
        } case
    ] [ >slow-be ] if ;
