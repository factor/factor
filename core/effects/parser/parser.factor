! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: lexer sets sequences kernel splitting effects ;
IN: effects.parser

: parse-effect ( end -- effect )
    parse-tokens dup { "(" "((" } intersect empty? [
        { "--" } split1 dup [
            <effect>
        ] [
            "Stack effect declaration must contain --" throw
        ] if
    ] [
        "Stack effect declaration must not contain ( or ((" throw
    ] if ;
