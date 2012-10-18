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

: components ( str -- n )
    [ CHAR: . = ] count ;

: parse-1 ( str -- ip )
    split-components { 0 0 0 } prepend ;

: parse-2 ( str -- ip )
    split-components first2 [| A D | { A 0 0 D } ] call ;

: parse-3 ( str -- ip )
    split-components first3 [| A B D | { A B 0 D } ] call ;

: parse-4 ( str -- ip )
    split-components ;

PRIVATE>

ERROR: invalid-ipv4 str ;

: parse-ipv4 ( str -- ip )
    dup components {
        { 0 [ parse-1 ] }
        { 1 [ parse-2 ] }
        { 2 [ parse-3 ] }
        { 3 [ parse-4 ] }
        [ invalid-ipv4 ]
    } case join-components ;
