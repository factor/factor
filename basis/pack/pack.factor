! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types ascii assocs combinators combinators.smart
endian io kernel math math.statistics math.vectors sequences
strings ;
IN: pack

GENERIC: >n-byte-array ( obj n -- byte-array )

M: integer >n-byte-array >endian ;

! for doing native, platform-dependent sized values
M: object >n-byte-array heap-size >n-byte-array ;

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
        [ [ 0 or 10 * ] [ CHAR: 0 - ] bi* + f ]
        [ [ 1 or ] [ <string> ] bi* f swap ] if
    ] { } map-as "" concat-as nip ; foldable

CONSTANT: pack-table
    H{
        { CHAR: c s8>byte-array }
        { CHAR: C u8>byte-array }
        { CHAR: s s16>byte-array }
        { CHAR: S u16>byte-array }
        { CHAR: t s24>byte-array }
        { CHAR: T u24>byte-array }
        { CHAR: i s32>byte-array }
        { CHAR: I u32>byte-array }
        { CHAR: q s64>byte-array }
        { CHAR: Q u64>byte-array }
        { CHAR: f write-float }
        { CHAR: F write-float }
        { CHAR: d write-double }
        { CHAR: D write-double }
        { CHAR: a write-c-string }
    }

CONSTANT: unpack-table
    H{
        { CHAR: c [ signed-endian> ] }
        { CHAR: C [ unsigned-endian> ] }
        { CHAR: s [ signed-endian> ] }
        { CHAR: S [ unsigned-endian> ] }
        { CHAR: t [ signed-endian> ] }
        { CHAR: T [ unsigned-endian> ] }
        { CHAR: i [ signed-endian> ] }
        { CHAR: I [ unsigned-endian> ] }
        { CHAR: q [ signed-endian> ] }
        { CHAR: Q [ unsigned-endian> ] }
        { CHAR: f [ unsigned-endian> bits>float ] }
        { CHAR: F [ unsigned-endian> bits>float ] }
        { CHAR: d [ unsigned-endian> bits>double ] }
        { CHAR: D [ unsigned-endian> bits>double ] }
        ! { CHAR: a read-c-string }
    }

CONSTANT: packed-length-table
    H{
        { CHAR: c 1 }
        { CHAR: C 1 }
        { CHAR: s 2 }
        { CHAR: S 2 }
        { CHAR: t 3 }
        { CHAR: T 3 }
        { CHAR: i 4 }
        { CHAR: I 4 }
        { CHAR: q 8 }
        { CHAR: Q 8 }
        { CHAR: f 4 }
        { CHAR: F 4 }
        { CHAR: d 8 }
        { CHAR: D 8 }
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

: pack-native ( seq str -- bytes )
    '[ _ _ pack ] with-native-endian ; inline

: pack-be ( seq str -- bytes )
    '[ _ _ pack ] with-big-endian ; inline

: pack-le ( seq str -- bytes )
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
    '[ _ cleave>array ] ;

: unpack-native ( bytes str -- seq )
    '[ _ _ unpack ] with-native-endian ; inline

: unpack-be ( bytes str -- seq )
    '[ _ _ unpack ] with-big-endian ; inline

: unpack-le ( bytes str -- seq )
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
