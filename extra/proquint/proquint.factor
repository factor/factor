! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: base64.private ip-parser kernel literals make math
math.bitwise random sequences ;

IN: proquint

! https://arxiv.org/html/0901.4016

<PRIVATE

<<
CONSTANT: consonant "bdfghjklmnprstvz"

CONSTANT: vowel "aiou"
>>

: >quint16 ( m -- str )
    5 [
        even? [
            [ -4 shift ] [ 4 bits consonant nth ] bi
        ] [
            [ -2 shift ] [ 2 bits vowel nth ] bi
        ] if
    ] "" map-integers-as reverse nip ;

PRIVATE>

: >quint ( m bits -- str )
    [
        [ dup 0 > ] [
            [ [ 16 bits >quint16 , ] [ -16 shift ] bi ] dip 16 -
        ] while 2drop
    ] { } make reverse "-" join ;

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

: quint-password ( bits -- quint )
    [ random-bits ] [ >quint ] bi ;

: ipv4>quint ( ipv4 -- str )
    ipv4-aton 32 >quint ;

: quint>ipv4 ( str -- ipv4 )
    quint> ipv4-ntoa ;

: ipv6>quint ( ipv6 -- str )
    ipv6-aton 128 >quint ;

: quint>ipv6 ( str -- ipv6 )
    quint> ipv6-ntoa ;
