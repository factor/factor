! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors fry generalizations io io.streams.string kernel
make math math.order math.parser multiline namespaces present
sequences splitting strings vocabs.parser ;
IN: interpolate

<PRIVATE

TUPLE: named-var name ;

TUPLE: stack-var n ;

TUPLE: anon-var ;

: (parse-interpolate) ( str -- )
    [
        "${" split1-slice [
            [ >string , ] unless-empty
        ] [
            [
                "}" split1-slice
                [
                    >string
                    [ string>number ]
                    [ 1 + stack-var boa ]
                    [ [ anon-var new ] [ named-var boa ] if-empty ] ?if ,
                ]
                [ (parse-interpolate) ] bi*
            ] when*
        ] bi*
    ] unless-empty ;

: deanonymize ( seq -- seq' )
    0 over <reversed> [
        dup anon-var? [
            drop 1 + dup stack-var boa
        ] when
    ] map! 2drop ;

: parse-interpolate ( str -- seq )
    [ (parse-interpolate) ] { } make deanonymize ;

: max-stack-var ( seq -- n/f )
    f [
        dup stack-var? [ n>> [ or ] keep max ] [ drop ] if
    ] reduce ;

:: (interpolate-quot) ( str quot -- quot' )
    str parse-interpolate :> args
    args max-stack-var    :> vars

    args [
        dup named-var? [
            name>> quot call '[ _ @ present write ]
        ] [
            dup stack-var? [
                n>> '[ _ npick present write ]
            ] [
                '[ _ write ]
            ] if
        ] if
    ] map concat

    vars [
        '[ _ ndrop ] append
    ] when* ; inline

PRIVATE>

: interpolate-quot ( str -- quot )
    [ [ get ] ] (interpolate-quot) ;

MACRO: interpolate ( str -- quot )
    interpolate-quot ;

: interpolate>string ( str -- newstr )
    [ interpolate ] with-string-writer ; inline

: interpolate-locals-quot ( str -- quot )
    [ [ search ] [ [ ] ] [ [ get ] ] ?if ] (interpolate-quot) ;

MACRO: interpolate-locals ( str -- quot )
    interpolate-locals-quot ;

: interpolate-locals>string ( str -- newstr )
    [ interpolate-locals ] with-string-writer ; inline

SYNTAX: [I
    "I]" parse-multiline-string
    interpolate-locals-quot append! ;
