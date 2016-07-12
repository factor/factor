! Copyright (C) 2012-2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: byte-arrays combinators combinators.short-circuit kernel
math math.bitwise math.parser sequences splitting ;

IN: ip-parser

ERROR: malformed-ipv4 string ;

ERROR: bad-ipv4-component string ;

<PRIVATE

: octal? ( str -- ? )
    { [ "0" = not ] [ "0" head? ] [ "0x" head? not ] } 1&& ;

: ipv4-component ( str -- n )
    dup dup octal? [ oct> ] [ string>number ] if
    [ ] [ bad-ipv4-component ] ?if ;

: split-ipv4 ( str -- array )
    "." split [ ipv4-component ] map ;

: bubble ( array -- newarray )
    reverse 0 swap [ + 256 /mod ] map reverse nip ;

: ?bubble ( array -- array )
    dup [ 255 > ] any? [ bubble ] when ;

: join-ipv4 ( array -- str )
    [ number>string ] { } map-as "." join ;

PRIVATE>

: parse-ipv4 ( str -- byte-array )
    dup split-ipv4 dup length {
        { 1 [ { 0 0 0 } prepend ] }
        { 2 [ 1 cut { 0 0 } glue ] }
        { 3 [ 2 cut { 0 } glue ] }
        { 4 [ ] }
        [ 2drop malformed-ipv4 ]
    } case ?bubble nip B{ } like ; inline

: normalize-ipv4 ( str -- newstr )
    parse-ipv4 join-ipv4 ;

: ipv4-ntoa ( integer -- ip )
    { -24 -16 -8 0 } [ 8 shift-mod ] with map join-ipv4 ;

: ipv4-aton ( ip -- integer )
    parse-ipv4 { 24 16 8 0 } [ shift ] [ + ] 2map-reduce ;

ERROR: bad-ipv6-component obj ;

ERROR: bad-ipv4-embedded-prefix obj ;

ERROR: more-than-8-components ;

<PRIVATE

: ipv6-component ( str -- n )
    dup hex> [ ] [ bad-ipv6-component ] ?if ;

: split-ipv6 ( string -- seq )
    ":" split CHAR: . over last member? [ unclip-last ] [ f ] if
    [ [ ipv6-component ] map ]
    [ [ parse-ipv4 append ] unless-empty ] bi* ;

: pad-ipv6 ( string1 string2 -- seq )
    2dup [ length ] bi@ + 8 swap -
    dup 0 < [ more-than-8-components ] when
    <byte-array> glue ;

PRIVATE>

: parse-ipv6 ( string -- seq )
    "::" split1 [ [ f ] [ split-ipv6 ] if-empty ] bi@ pad-ipv6 ;
