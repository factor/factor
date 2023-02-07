! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: base64.private ip-parser kernel literals math
math.bitwise sequences ;

IN: proquint

! https://arxiv.org/html/0901.4016

<PRIVATE
<<
CONSTANT: consonant "bdfghjklmnprstvz"
CONSTANT: vowel "aiou"
>>
PRIVATE>

: >quint16 ( m -- str )
    5 [
        even? [
            [ -4 shift ] [ 4 bits consonant nth ] bi
        ] [
            [ -2 shift ] [ 2 bits vowel nth ] bi
        ] if
    ] "" map-integers-as reverse nip ;

: >quint32 ( m -- str )
    [ -16 shift ] keep [ 16 bits >quint16 ] bi@ "-" glue ;

: >quint48 ( m -- str )
    { -32 -16 0 } [ 16 shift-mod >quint16 ] with map "-" join ;

: >quint64 ( m -- str )
    { -48 -32 -16 0 } [ 16 shift-mod >quint16 ] with map "-" join ;

: >quint128 ( m -- str )
    { -112 -96 -80 -64 -48 -32 -16 0 } [ 16 shift-mod >quint16 ] with map "-" join ;

: quint> ( str -- m )
    0 [
        dup $[ consonant alphabet-inverse ] nth [
            nip [ 4 shift ] [ + ] bi*
        ] [
            dup $[ vowel alphabet-inverse ] nth [
                nip [ 2 shift ] [ + ] bi*
            ] [
                CHAR: - assert=
            ] if*
        ] if*
    ] reduce ;

: quint-password ( -- quint )
    48 random-bits >quint48 ;

: ipv4>quint ( ipv4 -- str )
    ipv4-aton >quint32 ;

: quint>ipv4 ( str -- ipv4 )
    quint> ipv4-ntoa ;

: ipv6>quint ( ipv6 -- str )
    ipv6-aton >quint128 ;

: quint>ipv6 ( str -- ipv6 )
    quint> ipv6-ntoa ;
