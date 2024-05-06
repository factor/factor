! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: colors.private grouping hex-strings kernel lexer math
sequences splitting ;

IN: colors.flex-hex

<PRIVATE

: hex-only ( str -- str' )
    [ dup hex-digit? [ drop CHAR: 0 ] unless ] map ;

: pad-length ( str -- n )
    length dup 3 mod [ 3 swap - + ] unless-zero ;

: three-groups ( str -- array )
    dup pad-length [ CHAR: 0 pad-tail ] [ 3 / group ] bi ;

: hex-rgb ( array -- array' )
    [
        8 index-or-length tail*
        2 index-or-length head
        2 CHAR: 0 pad-head
    ] map ;

PRIVATE>

: flex-hex ( str -- hex )
    "#" ?head drop hex-only three-groups hex-rgb "" join ;

: flex-hex>rgba ( str -- rgba )
    flex-hex hex>rgba ;

SYNTAX: FLEXHEXCOLOR: scan-token flex-hex>rgba suffix! ;
