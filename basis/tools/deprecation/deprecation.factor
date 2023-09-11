! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators.short-circuit
compiler.units debugger init io io.streams.null kernel
namespaces prettyprint sequences sets source-files.errors
summary tools.crossref tools.crossref.private tools.errors
words ;
IN: tools.deprecation

SYMBOL: +deprecation-note+
SYMBOL: deprecation-notes

deprecation-notes [ H{ } clone ] initialize

TUPLE: deprecation-note < source-file-error ;

M: deprecation-note error-type drop +deprecation-note+ ;

TUPLE: deprecated-usages asset usages ;

: :deprecations ( -- )
    deprecation-notes get-global values errors. ;

T{ error-type-holder
    { type +deprecation-note+ }
    { word ":deprecations" }
    { plural "deprecated word usages" }
    { icon "vocab:ui/tools/error-list/icons/deprecation-note.png" }
    { quot [ deprecation-notes get values ] }
    { forget-quot [ deprecation-notes get delete-at ] }
    { fatal? f }
} define-error-type

: <deprecation-note> ( error word -- deprecation-note )
    deprecation-note new-source-file-error ;

: store-deprecation-note ( word usages -- )
    over [ deprecated-usages boa ] dip
    [ <deprecation-note> ]
    [ deprecation-notes get-global set-at ] bi ;

: clear-deprecation-note ( word -- )
    deprecation-notes get-global delete-at ;

: check-deprecations ( usage -- )
    dup word? [
        dup { [ "forgotten" word-prop ] [ deprecated? ] } 1||
        [ clear-deprecation-note ] [
            dup def>> uses [ deprecated? ] filter
            [ clear-deprecation-note ]
            [ store-deprecation-note ] if-empty
        ] if
    ] [ drop ] if ;

M: deprecated-usages summary
    drop "Deprecated words used" ;

M: deprecated-usages error.
    "The definition of " write
    dup asset>> pprint
    " uses these deprecated words:" write nl
    usages>> [ "    " write pprint nl ] each ;

SINGLETON: deprecation-observer

: initialize-deprecation-notes ( -- )
    [
        get-crossref [ deprecated? ] filter-keys
        values [ members [ check-deprecations ] each ] each
    ] with-null-writer ;

M: deprecation-observer definitions-changed
    drop filter-word-defs
    dup [ deprecated? ] none?
    [ [ check-deprecations ] each ]
    [ drop initialize-deprecation-notes ] if ;

STARTUP-HOOK: [ deprecation-observer add-definition-observer ]

initialize-deprecation-notes
