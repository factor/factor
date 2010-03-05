! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: lexer sets sequences kernel splitting effects
combinators arrays make vocabs.parser classes parser ;
IN: effects.parser

DEFER: parse-effect

ERROR: bad-effect ;
ERROR: invalid-effect-variable ;
ERROR: effect-variable-can't-have-type ;
ERROR: stack-effect-omits-dashes ;

SYMBOL: effect-var

: parse-var ( first? var name -- var )
    nip
    [ ":" ?tail [ effect-variable-can't-have-type ] when ] curry
    [ invalid-effect-variable ] if ;

: parse-effect-token ( first? var end -- var more? )
    scan [ nip ] [ = ] 2bi [ drop nip f ] [
        dup { f "(" "((" "--" } member? [ bad-effect ] [
            dup { ")" "))" } member? [ stack-effect-omits-dashes ] [
                ".." ?head [ parse-var t ] [
                    [ drop ] 2dip
                    ":" ?tail [
                        scan {
                            { [ dup "(" = ] [ drop ")" parse-effect ] }
                            { [ dup f = ] [ ")" unexpected-eof ] }
                            [ parse-word dup class? [ bad-effect ] unless ]
                        } cond 2array
                    ] when , t
                ] if
            ] if
        ] if
    ] if ;

: parse-effect-tokens ( end -- var tokens )
    [
        [ t f ] dip [ parse-effect-token [ f ] 2dip ] curry [ ] while nip
    ] { } make ;

: parse-effect ( end -- effect )
    [ "--" parse-effect-tokens ] dip parse-effect-tokens
    <variable-effect> ;

: complete-effect ( -- effect )
    "(" expect ")" parse-effect ;

: parse-call( ( accum word -- accum )
    [ ")" parse-effect ] dip 2array append! ;

: (:) ( -- word def effect )
    CREATE-WORD
    complete-effect
    parse-definition swap ;
