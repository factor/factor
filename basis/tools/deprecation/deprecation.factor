! (c)2009 Joe Groff bsd license
USING: accessors arrays assocs combinators.short-circuit
compiler.units debugger init io
io.streams.null kernel namespaces prettyprint sequences
source-files.errors summary tools.crossref
tools.crossref.private tools.errors words ;
IN: tools.deprecation

SYMBOL: +deprecation-note+
SYMBOL: deprecation-notes

deprecation-notes [ H{ } clone ] initialize

TUPLE: deprecation-note < source-file-error ;

M: deprecation-note error-type drop +deprecation-note+ ;

TUPLE: deprecated-usages asset usages ;

: :deprecations ( -- )
    deprecation-notes get-global values errors. ;

T{ error-type
    { type +deprecation-note+ }
    { word ":deprecations" }
    { plural "deprecated word usages" }
    { icon "vocab:ui/tools/error-list/icons/deprecation-note.tiff" }
    { quot [ deprecation-notes get values ] }
    { forget-quot [ deprecation-notes get delete-at ] }
} define-error-type

: <deprecation-note> ( error word -- deprecation-note )
    \ deprecation-note <definition-error> ;

: deprecation-note ( word usages -- )
    [ deprecated-usages boa ]
    [ drop <deprecation-note> ]
    [ drop deprecation-notes get-global set-at ] 2tri ;

: clear-deprecation-note ( word -- )
    deprecation-notes get-global delete-at ;

: check-deprecations ( usage -- )
    dup word? [
        dup { [ "forgotten" word-prop ] [ deprecated? ] } 1||
        [ clear-deprecation-note ] [
            dup def>> uses [ deprecated? ] filter
            [ clear-deprecation-note ] [ >array deprecation-note ] if-empty
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
        get-crossref [ drop deprecated? ] assoc-filter
        values [ keys [ check-deprecations ] each ] each
    ] with-null-writer ;

M: deprecation-observer definitions-changed
    drop keys [ word? ] filter
    dup [ deprecated? ] any? not
    [ [ check-deprecations ] each ]
    [ drop initialize-deprecation-notes ] if ;

[ \ deprecation-observer add-definition-observer ] 
"tools.deprecation" add-startup-hook

initialize-deprecation-notes
