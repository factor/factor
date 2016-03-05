! Copyright (C) 2012-2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: combinators combinators.short-circuit kernel math
math.bitwise math.parser math.vectors sequences splitting ;

IN: ip-parser

ERROR: invalid-ipv4 str ;

<PRIVATE

: cleanup-octal ( str -- str )
    dup { [ "0" = not ] [ "0" head? ] [ "0x" head? not ] } 1&&
    [ rest "0o" prepend ] when ;

: split-components ( str -- array )
    "." split [ cleanup-octal string>number ] map ;

: bubble ( array -- newarray )
    reverse 0 swap [ + 256 /mod ] map reverse nip ;

: join-components ( array -- str )
    [ number>string ] map "." join ;

: (parse-ipv4) ( str -- array )
    dup split-components dup length {
        { 1 [ { 0 0 0 } prepend ] }
        { 2 [ 1 cut { 0 0 } glue ] }
        { 3 [ 2 cut { 0 } glue ] }
        { 4 [ ] }
        [ drop invalid-ipv4 ]
    } case bubble nip ; inline

PRIVATE>

: parse-ipv4 ( str -- ip )
    (parse-ipv4) join-components ;

: ipv4-ntoa ( integer -- ip )
    { -24 -16 -8 0 } [ 8 shift-mod ] with map join-components ;

: ipv4-aton ( ip -- integer )
    (parse-ipv4) { 24 16 8 0 } [ shift ] [ + ] 2map-reduce ;
