! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs combinators generalizations io
io.streams.string kernel make math math.order math.parser
multiline namespaces present quotations sequences splitting
strings strings.parser vocabs.parser ;

IN: interpolate

<PRIVATE

SYMBOL: formatter

HOOK: format formatter ( directive -- quot )

M: f format drop [ present ] ;

TUPLE: named-var name ;

TUPLE: stack-var n ;

TUPLE: anon-var ;

: (parse-interpolate) ( str -- )
    [
        "${" split1-slice [
            [ >string [ ] 2array , ] unless-empty
        ] [
            [
                "}" split1-slice
                [
                    >string ":" split1 [
                        [ string>number ]
                        [ 1 + stack-var boa ]
                        [ [ anon-var new ] [ named-var boa ] if-empty ] ?if
                    ] [ format ] bi* 2array ,
                ]
                [ (parse-interpolate) ] bi*
            ] when*
        ] bi*
    ] unless-empty ;

: deanonymize ( seq -- seq' )
    0 over <reversed> [
        dup first anon-var? [
            [ 1 + dup stack-var boa ] dip second 2array
        ] when
    ] map! 2drop ;

: parse-interpolate ( str -- seq )
    [ (parse-interpolate) ] { } make deanonymize ;

: max-stack-var ( seq -- n/f )
    f [
        first dup stack-var? [ n>> [ or ] keep max ] [ drop ] if
    ] reduce ;

:: (interpolate-quot) ( str quot -- quot' )
    str parse-interpolate :> args
    args max-stack-var    :> vars

    args [
        [
            {
                { [ dup named-var? ] [ name>> quot call '[ _ @ ] ] }
                { [ dup stack-var? ] [ n>> '[ _ npick ] ] }
                [ 1quotation ]
            } cond
        ] dip '[ @ @ write ]
    ] { } assoc>map concat

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

SYNTAX: I" parse-string '[ _ interpolate>string ] append! ;
