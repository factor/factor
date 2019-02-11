! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types ascii assocs combinators combinators.smart
endian fry io kernel macros math math.statistics math.vectors
sequences strings ;
IN: pack

GENERIC: >n-byte-array ( obj n -- byte-array )

M: integer >n-byte-array ( m n -- byte-array ) >endian ;

! for doing native, platform-dependent sized values
M: object >n-byte-array ( n string -- byte-array ) heap-size >n-byte-array ;

: s8>byte-array ( n -- byte-array ) 1 >n-byte-array ;
: u8>byte-array ( n -- byte-array ) 1 >n-byte-array ;
: s16>byte-array ( n -- byte-array ) 2 >n-byte-array ;
: u16>byte-array ( n -- byte-array ) 2 >n-byte-array ;
: s24>byte-array ( n -- byte-array ) 3 >n-byte-array ;
: u24>byte-array ( n -- byte-array ) 3 >n-byte-array ;
: s32>byte-array ( n -- byte-array ) 4 >n-byte-array ;
: u32>byte-array ( n -- byte-array ) 4 >n-byte-array ;
: s64>byte-array ( n -- byte-array ) 8 >n-byte-array ;
: u64>byte-array ( n -- byte-array ) 8 >n-byte-array ;
: s128>byte-array ( n -- byte-array ) 16 >n-byte-array ;
: u128>byte-array ( n -- byte-array ) 16 >n-byte-array ;
: write-float ( n -- byte-array ) float>bits 4 >n-byte-array ;
: write-double ( n -- byte-array ) double>bits 8 >n-byte-array ;
: write-c-string ( byte-array -- byte-array ) { 0 } B{ } append-as ;

<PRIVATE

: expand-pack-format ( str -- str' )
    f swap [
        dup digit?
        [ [ 0 or 10 * ] [ ch'0 - ] bi* + f ]
        [ [ 1 or ] [ <string> ] bi* f swap ] if
    ] { } map-as "" concat-as nip ; foldable

CONSTANT: pack-table
    H{
        { ch'c s8>byte-array }
        { ch'C u8>byte-array }
        { ch's s16>byte-array }
        { ch'S u16>byte-array }
        { ch't s24>byte-array }
        { ch'T u24>byte-array }
        { ch'i s32>byte-array }
        { ch'I u32>byte-array }
        { ch'q s64>byte-array }
        { ch'Q u64>byte-array }
        { ch'f write-float }
        { ch'F write-float }
        { ch'd write-double }
        { ch'D write-double }
        { ch'a write-c-string }
    }

CONSTANT: unpack-table
    H{
        { ch'c [ 8 signed-endian> ] }
        { ch'C [ unsigned-endian> ] }
        { ch's [ 16 signed-endian> ] }
        { ch'S [ unsigned-endian> ] }
        { ch't [ 24 signed-endian> ] }
        { ch'T [ unsigned-endian> ] }
        { ch'i [ 32 signed-endian> ] }
        { ch'I [ unsigned-endian> ] }
        { ch'q [ 64 signed-endian> ] }
        { ch'Q [ unsigned-endian> ] }
        { ch'f [ unsigned-endian> bits>float ] }
        { ch'F [ unsigned-endian> bits>float ] }
        { ch'd [ unsigned-endian> bits>double ] }
        { ch'D [ unsigned-endian> bits>double ] }
        ! { ch'a read-c-string }
    }

CONSTANT: packed-length-table
    H{
        { ch'c 1 }
        { ch'C 1 }
        { ch's 2 }
        { ch'S 2 }
        { ch't 3 }
        { ch'T 3 }
        { ch'i 4 }
        { ch'I 4 }
        { ch'q 8 }
        { ch'Q 8 }
        { ch'f 4 }
        { ch'F 4 }
        { ch'd 8 }
        { ch'D 8 }
    }

PRIVATE>

MACRO: pack ( str -- quot )
    expand-pack-format
    [ pack-table at '[ _ execute ] ] { } map-as
    '[ [ [ _ spread ] input<sequence ] B{ } append-outputs-as ] ;

: ch>packed-length ( ch -- n )
    packed-length-table at ; inline

: packed-length ( str -- n )
    [ ch>packed-length ] map-sum ;

: pack-native ( seq str -- seq )
    '[ _ _ pack ] with-native-endian ; inline

: pack-be ( seq str -- seq )
    '[ _ _ pack ] with-big-endian ; inline

: pack-le ( seq str -- seq )
    '[ _ _ pack ] with-little-endian ; inline

<PRIVATE

: start/end ( seq -- seq1 seq2 )
    [ cum-sum0 dup ] keep v+ ; inline

PRIVATE>

MACRO: unpack ( str -- quot )
    expand-pack-format
    [ [ ch>packed-length ] { } map-as start/end ]
    [ [ unpack-table at ] { } map-as ] bi
    [ '[ [ _ _ ] dip <slice> @ ] ] 3map
    '[ [ _ cleave ] output>array ] ;

: unpack-native ( seq str -- seq )
    '[ _ _ unpack ] with-native-endian ; inline

: unpack-be ( seq str -- seq )
    '[ _ _ unpack ] with-big-endian ; inline

: unpack-le ( seq str -- seq )
    '[ _ _ unpack ] with-little-endian ; inline

ERROR: packed-read-fail str bytes ;

<PRIVATE

: read-packed-bytes ( str -- bytes )
    dup packed-length [ read dup length ] keep =
    [ nip ] [ packed-read-fail ] if ; inline

PRIVATE>

: read-packed ( str quot -- seq )
    [ read-packed-bytes ] swap bi ; inline

: read-packed-le ( str -- seq )
    [ unpack-le ] read-packed ; inline

: read-packed-be ( str -- seq )
    [ unpack-be ] read-packed ; inline

: read-packed-native ( str -- seq )
    [ unpack-native ] read-packed ; inline
