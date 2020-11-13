! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types ascii assocs combinators combinators.smart
endian fry io kernel macros math math.statistics math.vectors
sequences strings ;
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
        [ [ 0 or 10 * ] [ char: 0 - ] bi* + f ]
        [ [ 1 or ] [ <string> ] bi* f swap ] if
    ] { } map-as "" concat-as nip ; foldable

CONSTANT: pack-table
    H{
        { char: c s8>byte-array }
        { char: C u8>byte-array }
        { char: s s16>byte-array }
        { char: S u16>byte-array }
        { char: t s24>byte-array }
        { char: T u24>byte-array }
        { char: i s32>byte-array }
        { char: I u32>byte-array }
        { char: q s64>byte-array }
        { char: Q u64>byte-array }
        { char: f write-float }
        { char: F write-float }
        { char: d write-double }
        { char: D write-double }
        { char: a write-c-string }
    }

CONSTANT: unpack-table
    H{
        { char: c [ 8 signed-endian> ] }
        { char: C [ unsigned-endian> ] }
        { char: s [ 16 signed-endian> ] }
        { char: S [ unsigned-endian> ] }
        { char: t [ 24 signed-endian> ] }
        { char: T [ unsigned-endian> ] }
        { char: i [ 32 signed-endian> ] }
        { char: I [ unsigned-endian> ] }
        { char: q [ 64 signed-endian> ] }
        { char: Q [ unsigned-endian> ] }
        { char: f [ unsigned-endian> bits>float ] }
        { char: F [ unsigned-endian> bits>float ] }
        { char: d [ unsigned-endian> bits>double ] }
        { char: D [ unsigned-endian> bits>double ] }
        ! { char: a read-c-string }
    }

CONSTANT: packed-length-table
    H{
        { char: c 1 }
        { char: C 1 }
        { char: s 2 }
        { char: S 2 }
        { char: t 3 }
        { char: T 3 }
        { char: i 4 }
        { char: I 4 }
        { char: q 8 }
        { char: Q 8 }
        { char: f 4 }
        { char: F 4 }
        { char: d 8 }
        { char: D 8 }
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
