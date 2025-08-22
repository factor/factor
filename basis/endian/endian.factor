! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data byte-arrays
byte-vectors combinators combinators.short-circuit
combinators.smart generalizations grouping hints kernel math
math.bitwise namespaces ranges sequences
sequences.generalizations ;
IN: endian

SINGLETONS: big-endian little-endian ;

: compute-native-endianness ( -- class )
    1 int <ref> char deref 0 = big-endian little-endian ? ; foldable

<PRIVATE

: slow-be> ( seq -- x ) 0 [ [ 8 shift ] dip + ] reduce ;

: slow-le> ( seq -- x ) 0 [ 8 * shift + ] reduce-index ;

ERROR: bad-length bytes n ;

: check-length ( seq n -- seq n )
    2dup [ length ] dip > [ bad-length ] when ; inline

ERROR: invalid-signed-conversion n ;

<<
: convert-signed-quot ( n -- quot )
    {
        { 1 [ [ int8_t <ref> int8_t deref ] ] }
        { 2 [ [ int16_t <ref> int16_t deref ] ] }
        { 4 [ [ int32_t <ref> int32_t deref ] ] }
        { 8 [ [ int64_t <ref> int64_t deref ] ] }
        [ invalid-signed-conversion ]
    } case ; inline
>>

MACRO: byte-reverse ( n signed? -- quot )
    [
        drop
        [
            dup <iota> [
                [ 1 + - -8 * ] [ nip 8 * ] 2bi
                '[ _ shift 0xff bitand _ shift ]
            ] with map
        ] [ 1 - [ bitor ] n*quot ] bi
    ] [
        [ convert-signed-quot ] [ drop [ ] ] if
    ] 2bi '[ _ cleave @ @ ] ;

: ?byte-reverse ( endian n signed? -- )
    [ compute-native-endianness = ] 2dip '[ _ _ byte-reverse ] unless ; inline

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

:: n-be> ( seq n -- x )
    seq n firstn-unsafe n reassemble-be ; inline

:: n-le> ( seq n -- x )
    seq n firstn-unsafe n reassemble-le ; inline

: if-c-ptr ( seq c-ptr-quot not-c-ptr-quot -- )
    [
        dup { [ byte-array? ] [ byte-vector? ] } 1|| [ t ] [
            dup { [ slice? ] [ seq>> ] } 1&& [
                { [ byte-array? ] [ byte-vector? ] } 1||
            ] [ f ] if*
        ] if
    ] 2dip [ '[ >c-ptr @ ] ] dip if ; inline

: 1be> ( seq -- x )
    [ uint8_t deref big-endian 1 f ?byte-reverse ] [ 1 n-be> ] if-c-ptr ;

: 2be> ( seq -- x )
    [ uint16_t deref big-endian 2 f ?byte-reverse ] [ 2 n-be> ] if-c-ptr ;

: 4be> ( seq -- x )
    [ uint32_t deref big-endian 4 f ?byte-reverse ] [ 4 n-be> ] if-c-ptr ;

: 8be> ( seq -- x )
    [ uint64_t deref big-endian 8 f ?byte-reverse ] [ 8 n-be> ] if-c-ptr ;

: 1le> ( seq -- x )
    [ uint8_t deref little-endian 1 f ?byte-reverse ] [ 1 n-be> ] if-c-ptr ;

: 2le> ( seq -- x )
    [ uint16_t deref little-endian 2 f ?byte-reverse ] [ 2 n-be> ] if-c-ptr ;

: 4le> ( seq -- x )
    [ uint32_t deref little-endian 4 f ?byte-reverse ] [ 4 n-be> ] if-c-ptr ;

: 8le> ( seq -- x )
    [ uint64_t deref little-endian 8 f ?byte-reverse ] [ 8 n-be> ] if-c-ptr ;

PRIVATE>

: be> ( seq -- x )
    dup length {
        { 1 [ 1be> ] }
        { 2 [ 2be> ] }
        { 4 [ 4be> ] }
        { 8 [ 8be> ] }
        [ drop slow-be> ]
    } case ;

: le> ( seq -- x )
    dup length {
        { 1 [ 1le> ] }
        { 2 [ 2le> ] }
        { 4 [ 4le> ] }
        { 8 [ 8le> ] }
        [ drop slow-le> ]
    } case ;

<PRIVATE

: signed> ( x seq -- n )
    length 8 * 2dup 1 - bit? [ 2^ - ] [ drop ] if ; inline

: slow-signed-le> ( seq -- x ) [ le> ] [ signed> ] bi ;

: slow-signed-be> ( seq -- x ) [ be> ] [ signed> ] bi ;

: 1signed-be> ( seq -- x )
    [ int8_t deref big-endian 1 t ?byte-reverse ] [ slow-signed-be> ] if-c-ptr ;

: 2signed-be> ( seq -- x )
    [ int16_t deref big-endian 2 t ?byte-reverse ] [ slow-signed-be> ] if-c-ptr ;

: 4signed-be> ( seq -- x )
    [ int32_t deref big-endian 4 t ?byte-reverse ] [ slow-signed-be> ] if-c-ptr ;

: 8signed-be> ( seq -- x )
    [ int64_t deref big-endian 8 t ?byte-reverse ] [ slow-signed-be> ] if-c-ptr ;

: 1signed-le> ( seq -- x )
    [ int8_t deref little-endian 1 t ?byte-reverse ] [ slow-signed-be> ] if-c-ptr ;

: 2signed-le> ( seq -- x )
    [ int16_t deref little-endian 2 t ?byte-reverse ] [ slow-signed-be> ] if-c-ptr ;

: 4signed-le> ( seq -- x )
    [ int32_t deref little-endian 4 t ?byte-reverse ] [ slow-signed-be> ] if-c-ptr ;

: 8signed-le> ( seq -- x )
    [ int64_t deref little-endian 8 t ?byte-reverse ] [ slow-signed-be> ] if-c-ptr ;

PRIVATE>

: signed-be> ( seq -- x )
    dup length {
        { 1 [ 1signed-be> ] }
        { 2 [ 2signed-be> ] }
        { 4 [ 4signed-be> ] }
        { 8 [ 8signed-be> ] }
        [ drop slow-signed-be> ]
    } case ;

: signed-le> ( seq -- x )
    dup length {
        { 1 [ 1signed-le> ] }
        { 2 [ 2signed-le> ] }
        { 4 [ 4signed-le> ] }
        { 8 [ 8signed-le> ] }
        [ drop slow-signed-le> ]
    } case ;

: nth-byte ( x n -- b ) -8 * shift 0xff bitand ; inline

<PRIVATE

: map-bytes ( x seq -- byte-array )
    [ nth-byte ] with B{ } map-as ; inline

: >slow-be ( x n -- byte-array )
    integer>fixnum-strict <iota> <reversed> map-bytes ;

: >slow-le ( x n -- byte-array )
    integer>fixnum-strict <iota> map-bytes ;

PRIVATE>

: >be ( x n -- byte-array )
    {
        { 2 [ big-endian 2 f ?byte-reverse int16_t <ref> ] }
        { 4 [ big-endian 4 f ?byte-reverse int32_t <ref> ] }
        { 8 [ big-endian 8 f ?byte-reverse int64_t <ref> ] }
        [ >slow-be ]
    } case ;

: >le ( x n -- byte-array )
    {
        { 2 [ little-endian 2 f ?byte-reverse int16_t <ref> ] }
        { 4 [ little-endian 4 f ?byte-reverse int32_t <ref> ] }
        { 8 [ little-endian 8 f ?byte-reverse int64_t <ref> ] }
        [ >slow-le ]
    } case ;

SYMBOL: native-endianness
native-endianness [ compute-native-endianness ] initialize

HOOK: >native-endian native-endianness ( x n -- byte-array )

M: big-endian >native-endian >be ;

M: little-endian >native-endian >le ;

HOOK: unsigned-native-endian> native-endianness ( x -- byte-array )

M: big-endian unsigned-native-endian> be> ;

M: little-endian unsigned-native-endian> le> ;

SYMBOL: endianness
endianness [ native-endianness get-global ] initialize

: signed-native-endian> ( x n -- byte-array )
    [ unsigned-native-endian> ] dip >signed ;

HOOK: >endian endianness ( x n -- byte-array )

M: big-endian >endian >be ;

M: little-endian >endian >le ;

HOOK: endian> endianness ( seq -- n )

M: big-endian endian> be> ;

M: little-endian endian> le> ;

HOOK: unsigned-endian> endianness ( seq -- n )

M: big-endian unsigned-endian> be> ;

M: little-endian unsigned-endian> le> ;

HOOK: signed-endian> endianness ( seq -- n )

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

HINTS: n-be> { byte-array object } ;
HINTS: n-le> { byte-array object } ;

{ >le >be } [
    { { fixnum fixnum } { bignum fixnum } }
    set-specializer
] each

{ le> be> } [
    { byte-array } set-specializer
] each
