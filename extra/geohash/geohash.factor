! Copyright (C) 2019 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: byte-arrays fry kernel literals math math.bitwise
sequences ;

IN: geohash

<PRIVATE

: quantize ( lat lon -- lat' lon' )
    [ 90.0 + 180.0 / ] [ 180.0 + 360.0 / ] bi*
    [ 32 2^ * >integer 32 bits ] bi@ ;

: spread-bits ( m -- n )
    dup 16 shift bitor 0x0000ffff0000ffff bitand
    dup 8 shift bitor 0x00ff00ff00ff00ff bitand
    dup 4 shift bitor 0x0f0f0f0f0f0f0f0f bitand
    dup 2 shift bitor 0x3333333333333333 bitand
    dup 1 shift bitor 0x5555555555555555 bitand ;

: interleave-bits ( x y -- z )
    [ spread-bits ] bi@ 1 shift bitor ;

: dequantize ( lat lon -- lat' lon' )
    [ 32 2^ /f ] bi@ [ 180.0 * 90 - ] [ 360.0 * 180.0 - ] bi* ;

: squash-bits ( m -- n )
    0x5555555555555555 bitand
    dup -1 shift bitor 0x3333333333333333 bitand
    dup -2 shift bitor 0x0f0f0f0f0f0f0f0f bitand
    dup -4 shift bitor 0x00ff00ff00ff00ff bitand
    dup -8 shift bitor 0x0000ffff0000ffff bitand
    dup -16 shift bitor 0x00000000ffffffff bitand ;

: deinterleave-bits ( z -- x y )
    dup -1 shift [ squash-bits ] bi@ ;

<<
CONSTANT: base32-alphabet $[ "0123456789bcdefghjkmnpqrstuvwxyz" >byte-array ]
>>
CONSTANT: base32-inverse $[ 256 [ base32-alphabet index 0xff or ] B{ } map-integers-as ]

: base32-encode ( x -- str )
    -59 12 [
        dupd [ shift 5 bits base32-alphabet nth ] keep 5 + swap
    ] "" replicate-as 2nip ;

: base32-decode ( str -- x )
    [ 0 59 ] dip [
        base32-inverse nth swap [ shift bitor ] keep 5 -
    ] each drop ;

PRIVATE>

: >geohash ( lat lon -- geohash )
    quantize interleave-bits base32-encode ;

: geohash> ( geohash -- lat lon )
    base32-decode deinterleave-bits dequantize ;
