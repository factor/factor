! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math memory io io.styles prettyprint
namespaces system sequences splitting grouping assocs strings
generic.single combinators ;
IN: tools.time

: benchmark ( quot -- runtime )
    micros [ call micros ] dip - ; inline

: time. ( time -- )
    "== Running time ==" print nl 1000000 /f pprint " seconds" print ;

: dispatch-stats. ( stats -- )
    "== Megamorphic caches ==" print nl
    { "Hits" "Misses" } swap zip simple-table. ;

: inline-cache-stats. ( stats -- )
    "== Polymorphic inline caches ==" print nl
    3 cut
    [
        "- Transitions:" print
        { "Cold to monomorphic" "Mono to polymorphic" "Poly to megamorphic" } swap zip
        simple-table. nl
    ] [
        "- Type check stubs:" print
        { "Tag only" "Hi-tag" "Tuple" "Hi-tag and tuple" } swap zip
        simple-table.
    ] bi* ;

: time ( quot -- )
    reset-dispatch-stats
    reset-inline-cache-stats
    benchmark dispatch-stats inline-cache-stats
    [ time. nl ]
    [ dispatch-stats. nl ]
    [ inline-cache-stats. ]
    tri* ; inline
