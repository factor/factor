! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry hashtables io kernel macros make
math.parser multiline namespaces present sequences
sequences.generalizations splitting strings vocabs.parser ;
IN: interpolate

<PRIVATE

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

: (interpolate) ( string quot -- quot' )
    [ parse-interpolate ] dip '[
        dup interpolate-var?
        [ name>> @ '[ _ @ present write ] ]
        [ '[ _ write ] ]
        if
    ] map [ ] join ; inline

PRIVATE>

MACRO: interpolate ( string -- )
    [ [ get ] ] (interpolate) ;

: interpolate-locals ( string -- quot )
    [ search [ ] ] (interpolate) ;

SYNTAX: I[
    "]I" parse-multiline-string
    interpolate-locals append! ;

MACRO: ninterpolate ( str n -- quot )
    swap '[
        _ narray [ number>string swap 2array ] map-index
        >hashtable [ _ interpolate ] with-variables
    ] ;
