! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: lexer sets sequences kernel splitting effects
combinators arrays parser ;
IN: effects.parser

DEFER: parse-effect

ERROR: bad-effect ;

: parse-effect-token ( end -- token/f )
    scan [ nip ] [ = ] 2bi [ drop f ] [
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
    [ parse-effect-token dup ] curry [ ] produce nip ;

: parse-effect ( end -- effect )
    parse-effect-tokens { "--" } split1 dup
    [ <effect> ] [ "Stack effect declaration must contain --" throw ] if ;
