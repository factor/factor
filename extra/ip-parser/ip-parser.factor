! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators combinators.short-circuit kernel locals math
math.parser sequences splitting ;

IN: ip-parser

<PRIVATE

: cleanup-octal ( str -- str )
    dup { [ "0" head? ] [ "0x" head? not ] } 1&&
    [ 1 tail "0o" prepend ] when ;

: split-components ( str -- array )
    "." split [ cleanup-octal string>number ] map ;

: bubble ( array -- array' )
    reverse 0 swap [ + 256 /mod ] map reverse nip ;

: join-components ( array -- str )
    bubble [ number>string ] map "." join ;

PRIVATE>

ERROR: invalid-ipv4 str ;

: parse-ipv4 ( str -- ip )
    dup split-components dup length {
        { 1 [ { 0 0 0 } prepend ] }
        { 2 [ first2 [| A D | { A 0 0 D } ] call ] }
        { 3 [ first3 [| A B D | { A B 0 D } ] call ] }
        { 4 [ ] }
        [ drop invalid-ipv4 ]
    } case join-components nip ;
