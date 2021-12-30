! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

USING: alien.c-types alien.data byte-arrays combinators
combinators.smart endian kernel math math.ranges sequences
sequences.generalizations ;

USING: alien.c-types alien.data grouping kernel
math.bitwise namespaces sequences ;

IN: endian

SINGLETONS: big-endian little-endian ;

: compute-native-endianness ( -- class )
    1 int <ref> char deref 0 = big-endian little-endian ? ; foldable

<PRIVATE

: slow-be> ( seq -- x ) 0 [ [ 8 shift ] dip + ] reduce ;

: slow-le> ( seq -- x ) 0 [ 8 * shift + ] reduce-index ;

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

! HINTS: n-be> { byte-array object } ;
! HINTS: n-le> { byte-array object } ;

! { >le >be } [
!     { { fixnum fixnum } { bignum fixnum } }
!     set-specializer
! ] each

! { le> be> } [
!     { byte-array } set-specializer
! ] each

: if-endian ( endian bytes-quot seq-quot -- )
    [
        compute-native-endianness =
        [ dup byte-array? ] [ f ] if
    ] 2dip if ; inline

: 2be> ( bytes -- x )
    big-endian [ uint16_t deref ] [ 2 n-be> ] if-endian ;

: 4be> ( bytes -- x )
    big-endian [ uint32_t deref ] [ 4 n-be> ] if-endian ;

: 8be> ( bytes -- x )
    big-endian [ uint64_t deref ] [ 8 n-be> ] if-endian ;

: 2le> ( bytes -- x )
    little-endian [ uint16_t deref ] [ 2 n-le> ] if-endian ;

: 4le> ( bytes -- x )
    little-endian [ uint32_t deref ] [ 4 n-le> ] if-endian ;

: 8le> ( bytes -- x )
    little-endian [ uint64_t deref ] [ 8 n-le> ] if-endian ;

PRIVATE>

: be> ( bytes -- x )
    dup length {
        { 2 [ 2be> ] }
        { 4 [ 4be> ] }
        { 8 [ 8be> ] }
        [ drop slow-be> ]
    } case ;

: le> ( bytes -- x )
    dup length {
        { 2 [ 2le> ] }
        { 4 [ 4le> ] }
        { 8 [ 8le> ] }
        [ drop slow-le> ]
    } case ;

<PRIVATE

: signed> ( x seq -- n )
    length 8 * 2dup 1 - bit? [ 2^ - ] [ drop ] if ; inline

: slow-signed-le> ( bytes -- x ) [ le> ] [ signed> ] bi ;

: slow-signed-be> ( bytes -- x ) [ be> ] [ signed> ] bi ;

PRIVATE>

: signed-be> ( bytes -- x )
    big-endian [
        dup length {
            { 2 [ int16_t deref ] }
            { 4 [ int32_t deref ] }
            { 8 [ int64_t deref ] }
            [ drop slow-signed-be> ]
        } case
    ] [ slow-signed-be> ] if-endian ;

: signed-le> ( bytes -- x )
    little-endian [
        dup length {
            { 2 [ int16_t deref ] }
            { 4 [ int32_t deref ] }
            { 8 [ int64_t deref ] }
            [ drop slow-signed-le> ]
        } case
    ] [ slow-signed-le> ] if-endian ;

: nth-byte ( x n -- b ) -8 * shift 0xff bitand ; inline

<PRIVATE

: map-bytes ( x seq -- byte-array )
    [ nth-byte ] with B{ } map-as ; inline

: >slow-be ( x n -- byte-array ) <iota> <reversed> map-bytes ;

: >slow-le ( x n -- byte-array ) <iota> map-bytes ;

PRIVATE>

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

SYMBOL: native-endianness
native-endianness [ compute-native-endianness ] initialize

HOOK: >native-endian native-endianness ( obj n -- bytes )

M: big-endian >native-endian >be ;

M: little-endian >native-endian >le ;

HOOK: unsigned-native-endian> native-endianness ( obj -- bytes )

M: big-endian unsigned-native-endian> be> ;

M: little-endian unsigned-native-endian> le> ;

SYMBOL: endianness
endianness [ native-endianness get-global ] initialize

: signed-native-endian> ( obj n -- n' )
    [ unsigned-native-endian> ] dip >signed ;

HOOK: >endian endianness ( obj n -- bytes )

M: big-endian >endian >be ;

M: little-endian >endian >le ;

HOOK: endian> endianness ( seq -- n )

M: big-endian endian> be> ;

M: little-endian endian> le> ;

HOOK: unsigned-endian> endianness ( obj -- bytes )

M: big-endian unsigned-endian> be> ;

M: little-endian unsigned-endian> le> ;

HOOK: signed-endian> endianness ( obj -- bytes )

M: big-endian signed-endian> signed-be> ;

M: little-endian signed-endian> signed-le> ;

: with-endianness ( endian quot -- )
    [ endianness ] dip with-variable ; inline

: with-big-endian ( quot -- )
    big-endian swap with-endianness ; inline

: with-little-endian ( quot -- )
    little-endian swap with-endianness ; inline

: with-native-endian ( quot -- )
    \ native-endianness get-global swap with-endianness ; inline

: seq>native-endianness ( seq n -- seq' )
    native-endianness get-global dup endianness get = [
        2drop
    ] [
        [ [ <groups> ] keep ] dip
        little-endian = [
            '[ be> _ >le ] map
        ] [
            '[ le> _ >be ] map
        ] if concat
    ] if ; inline

