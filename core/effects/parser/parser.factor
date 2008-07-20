! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: lexer sets sequences kernel splitting effects summary
combinators debugger arrays parser ;
IN: effects.parser

DEFER: parse-effect

ERROR: bad-effect ;

M: bad-effect summary
    drop "Bad stack effect declaration" ;

: parse-effect-token ( end -- token/f )
    scan tuck = [ drop f ] [
        dup { f "(" "((" } member? [ bad-effect ] [
            ":" ?tail [
                scan-word {
                    { \ ( [ ")" parse-effect ] }
                    [ ]
                } case 2array
            ] when
        ] if
    ] if ;

: parse-effect-tokens ( end -- tokens )
    [ parse-effect-token dup ] curry [ ] [ drop ] produce ;

: parse-effect ( end -- effect )
    parse-effect-tokens { "--" } split1 dup
    [ <effect> ] [ "Stack effect declaration must contain --" throw ] if ;
