! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators combinators.short-circuit formatting kernel
literals locals math math.bitwise math.parser sequences
splitting ;

IN: ip-parser

ERROR: invalid-ipv4 str ;

<PRIVATE

: cleanup-octal ( str -- str )
    dup { [ "0" head? ] [ "0x" head? not ] } 1&&
    [ rest "0o" prepend ] when ;

: split-components ( str -- array )
    "." split [ cleanup-octal string>number ] map ;

: bubble ( array -- array' )
    reverse 0 swap [ + 256 /mod ] map reverse nip ;

: join-components ( array -- str )
    [ number>string ] map "." join ;

: (parse-ipv4) ( str -- array )
    dup split-components dup length {
        { 1 [ { 0 0 0 } prepend ] }
        { 2 [ first2 [| A D | { A 0 0 D } ] call ] }
        { 3 [ first3 [| A B D | { A B 0 D } ] call ] }
        { 4 [ ] }
        [ drop invalid-ipv4 ]
    } case bubble nip ;

PRIVATE>

: parse-ipv4 ( str -- ip )
    (parse-ipv4) join-components ;

: ipv4-ntoa ( integer -- ip )
    $[ { -24 -16 -8 0 } [ [ shift 8 bits ] curry ] map ]
    cleave "%s.%s.%s.%s" sprintf ;

: ipv4-aton ( ip -- integer )
    (parse-ipv4) { 24 16 8 0 } [ shift ] [ + ] 2map-reduce ;
