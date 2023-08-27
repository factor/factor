! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.tuple combinators.short-circuit
effects.parser fry generalizations gml.runtime kernel
kernel.private lexer locals macros namespaces parser
prettyprint sequences system words ;
IN: gml.macros

TUPLE: macro macro-id timestamp log ;

SYMBOL: next-macro-id
next-macro-id [ 0 ] initialize

SYMBOL: macros
macros [ H{ } clone ] initialize

SYMBOL: current-macro

: <macro> ( -- macro )
    macro new
        next-macro-id [ get ] [ inc ] bi >>macro-id
        nano-count >>timestamp
        V{ } clone >>log ; inline

: save-euler-op ( euler-op -- ) current-macro get log>> push ;

MACRO:: log-euler-op ( class def inputs -- quot )
    class inputs def inputs '[ [ current-macro get [ _ boa save-euler-op ] [ _ ndrop ] if ] _ _ nbi ] ;

SYNTAX: LOG-GML:
    [let
        (GML:) :> ( word name effect def )

        name "-record" append create-word-in :> record-class
        record-class tuple effect in>> define-tuple-class

        record-class def effect in>> length
        '[ _ _ _ log-euler-op ] :> logging-def

        word name effect logging-def define-gml-primitive
    ] ;
