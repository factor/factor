! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: lexer sets sequences kernel splitting effects
combinators arrays vocabs.parser classes parser ;
IN: effects.parser

DEFER: parse-effect

ERROR: bad-effect ;

: parse-effect-token ( end -- token/f )
    scan [ nip ] [ = ] 2bi [ drop f ] [
        dup { f "(" "((" } member? [ bad-effect ] [
            ":" ?tail [
                scan {
                    { [ dup "(" = ] [ drop ")" parse-effect ] }
                    { [ dup f = ] [ ")" unexpected-eof ] }
                    [ parse-word dup class? [ bad-effect ] unless ]
                } cond 2array
            ] when
        ] if
    ] if ;

: parse-effect-tokens ( end -- tokens )
    [ parse-effect-token dup ] curry [ ] produce nip ;

ERROR: stack-effect-omits-dashes tokens ;

: parse-effect ( end -- effect )
    parse-effect-tokens { "--" } split1 dup
    [ <effect> ] [ drop stack-effect-omits-dashes ] if ;

: complete-effect ( -- effect )
    "(" expect ")" parse-effect ;

: parse-call( ( accum word -- accum )
    [ ")" parse-effect ] dip 2array append! ;

: (:) ( -- word def effect )
    CREATE-WORD
    complete-effect
    parse-definition swap ;
