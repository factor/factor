! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io kernel macros make multiline namespaces parser
present sequences strings splitting fry accessors ;
IN: interpolate

TUPLE: interpolate-var name ;

: (parse-interpolate) ( string -- )
    [
        "${" split1-slice [ >string , ] [
            [
                "}" split1-slice
                [ >string interpolate-var boa , ]
                [ (parse-interpolate) ] bi*
            ] when*
        ] bi*
    ] unless-empty ;

: parse-interpolate ( string -- seq )
    [ (parse-interpolate) ] { } make ;

MACRO: interpolate ( string -- )
    parse-interpolate [
        dup interpolate-var?
        [ name>> '[ _ get present write ] ]
        [ '[ _ write ] ]
        if
    ] map [ ] join ;

: interpolate-locals ( string -- quot )
    parse-interpolate [
        dup interpolate-var?
        [ name>> search '[ _ present write ] ]
        [ '[ _ write ] ]
        if
    ] map [ ] join ;

: I[ "]I" parse-multiline-string
    interpolate-locals parsed \ call parsed ; parsing
