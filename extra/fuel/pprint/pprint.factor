! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays classes.tuple combinators continuations io
kernel lexer math prettyprint quotations sequences source-files
source-files.errors strings words ;

IN: fuel.pprint

GENERIC: fuel-pprint ( obj -- )

<PRIVATE

: fuel-maybe-scape ( ch -- seq )
    dup "\\\"?#()[]'`;." member? [ CHAR: \ swap 2array ] [ 1array ] if ;

SYMBOL: :restarts

: fuel-restarts ( obj -- seq )
    compute-restarts :restarts prefix ; inline

: fuel-pprint-sequence ( seq open close -- )
    [ write ] dip swap [ bl ] [ fuel-pprint ] interleave write ; inline

PRIVATE>

M: object fuel-pprint pprint ; inline

M: word fuel-pprint
    name>> V{ } clone [ fuel-maybe-scape append ] reduce >string write ;

M: f fuel-pprint drop "nil" write ; inline

M: integer fuel-pprint pprint ; inline

M: string fuel-pprint pprint ; inline

M: sequence fuel-pprint "(" ")" fuel-pprint-sequence ; inline

M: quotation fuel-pprint "[" "]" fuel-pprint-sequence ; inline

M: tuple fuel-pprint pack-tuple fuel-pprint ; inline

M: continuation fuel-pprint drop ":continuation" write ; inline

M: restart fuel-pprint name>> fuel-pprint ; inline

M: condition fuel-pprint
    [ error>> ] [ fuel-restarts ] bi 2array condition prefix fuel-pprint ;

M: lexer-error fuel-pprint
    {
        [ line>> ]
        [ column>> ]
        [ line-text>> ]
        [ fuel-restarts ]
    } cleave 4array lexer-error prefix fuel-pprint ;

M: source-file-error fuel-pprint
    [ path>> ] [ error>> ] bi 2array source-file-error prefix
    fuel-pprint ;

M: source-file fuel-pprint path>> fuel-pprint ;
