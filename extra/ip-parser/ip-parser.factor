! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: arrays combinators combinators.short-circuit
generalizations kernel literals locals math math.bitwise
math.parser sequences sequences.private splitting ;

IN: ip-parser

ERROR: invalid-ipv4 str ;

<PRIVATE

: cleanup-octal ( str -- str )
    dup { [ "0" head? ] [ "0x" head? not ] } 1&&
    [ rest "0o" prepend ] when ;

: split-components ( str -- array )
    "." split [ cleanup-octal string>number ] map! ;

: byte>string ( byte -- str )
    $[ 256 iota [ number>string ] map ] nth-unsafe ; inline

: bubble1 ( m n -- x y )
    [ -8 shift + ] [ 8 bits ] bi ; inline

: bubble ( a b c d -- w x y z )
    bubble1 [ bubble1 ] dip [ bubble1 ] 2dip [ 8 bits ] 3dip ; inline

: join-components ( a b c d -- str )
    [ byte>string ] 4 napply 4array "." join ; inline

: (parse-ipv4) ( str -- a b c d )
    dup split-components dup length {
        { 1 [ nip first-unsafe [ 0 0 0 ] dip ] }
        { 2 [ nip first2-unsafe [ 0 0 ] dip ] }
        { 3 [ nip first3-unsafe [ 0 ] dip ] }
        { 4 [ nip first4-unsafe ] }
        [ drop invalid-ipv4 ]
    } case bubble ; inline

PRIVATE>

: parse-ipv4 ( str -- ip )
    (parse-ipv4) join-components ;

: ipv4-ntoa ( integer -- ip )
    $[ { -24 -16 -8 0 } [ [ 8 shift-mod ] curry ] map ] cleave
    join-components ;

: ipv4-aton ( ip -- integer )
    (parse-ipv4) [ 24 16 8 [ shift ] tri-curry@ tri* ] dip + + + ;
