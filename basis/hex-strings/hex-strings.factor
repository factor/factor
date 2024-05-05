! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays combinators.short-circuit kernel math
math.order math.parser sequences sequences.private strings ;
IN: hex-strings

: hex-digit? ( ch -- ? )
    {
        [ CHAR: A CHAR: F between? ]
        [ CHAR: a CHAR: f between? ]
        [ CHAR: 0 CHAR: 9 between? ]
    } 1|| ;

: hex-string? ( str -- ? )
    [ hex-digit? ] all? ;

: md5-string? ( str -- ? ) { [ length 32 = ] [ hex-string? ] } 1&& ;
: sha1-string? ( str -- ? ) { [ length 40 = ] [ hex-string? ] } 1&& ;
: sha224-string? ( str -- ? ) { [ length 56 = ] [ hex-string? ] } 1&& ;
: sha256-string? ( str -- ? ) { [ length 64 = ] [ hex-string? ] } 1&& ;
: sha384-string? ( str -- ? ) { [ length 96 = ] [ hex-string? ] } 1&& ;
: sha512-string? ( str -- ? ) { [ length 128 = ] [ hex-string? ] } 1&& ;

ERROR: invalid-hex-string-length n ;

: hex-string>bytes ( hex-string -- bytes )
    dup length dup even? [ invalid-hex-string-length ] unless 2/ <byte-array> [
        [
            [ digit> ] 2dip over even? [
                [ 16 * ] [ 2/ ] [ set-nth-unsafe ] tri*
            ] [
                [ 2/ ] [ [ + ] change-nth-unsafe ] bi*
            ] if
        ] curry each-index
    ] keep ;

: bytes>hex-string ( bytes -- hex-string )
    dup length 2 * CHAR: 0 <string> [
        [
            [ 16 /mod [ >digit ] bi@ ]
            [ 2 * dup 1 + ]
            [ [ set-nth-unsafe ] curry bi-curry@ bi* ] tri*
        ] curry each-index
    ] keep ;
