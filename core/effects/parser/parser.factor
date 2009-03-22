! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: lexer sets sequences kernel splitting effects
combinators arrays ;
IN: effects.parser

DEFER: parse-effect

ERROR: bad-effect ;

: parse-effect-token ( end -- token/f )
    scan [ nip ] [ = ] 2bi [ drop f ] [
        dup { f "(" "((" } member? [ bad-effect ] [
            ":" ?tail [
                scan {
                    { "(" [ ")" parse-effect ] }
                    { f [ ")" unexpected-eof ] }
                } case 2array
            ] when
        ] if
    ] if ;

: parse-effect-tokens ( end -- tokens )
    [ parse-effect-token dup ] curry [ ] produce nip ;

: parse-effect ( end -- effect )
    parse-effect-tokens { "--" } split1 dup
    [ <effect> ] [ "Stack effect declaration must contain --" throw ] if ;

: complete-effect ( -- effect )
    "(" expect ")" parse-effect ;

: parse-call( ( accum word -- accum )
    [ ")" parse-effect ] dip 2array over push-all ;