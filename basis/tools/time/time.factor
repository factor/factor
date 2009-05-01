! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.vectors memory io io.styles prettyprint
namespaces system sequences splitting grouping assocs strings
generic.single combinators ;
IN: tools.time

: benchmark ( quot -- runtime )
    micros [ call micros ] dip - ; inline

: time. ( time -- )
    "== Running time ==" print nl 1000000 /f pprint " seconds" print ;

: gc-stats. ( stats -- )
    5 cut*
    "== Garbage collection ==" print nl
    "Times are in microseconds." print nl
    [
        6 group
        {
            "GC count:"
            "Total GC time:"
            "Longest GC pause:"
            "Average GC pause:"
            "Objects copied:"
            "Bytes copied:"
        } prefix
        flip
        { "" "Nursery" "Aging" "Tenured" } prefix
        simple-table.
    ]
    [
        nl
        {
            "Total GC time:"
            "Cards scanned:"
            "Decks scanned:"
            "Card scan time:"
            "Code heap literal scans:"
        } swap zip simple-table.
    ] bi* ;

: dispatch-stats. ( stats -- )
    "== Megamorphic caches ==" print nl
    { "Hits" "Misses" } swap zip simple-table. ;

: inline-cache-stats. ( stats -- )
    nl "== Polymorphic inline caches ==" print nl
    3 cut
    [
        "Transitions:" print
        { "Cold to monomorphic" "Mono to polymorphic" "Poly to megamorphic" } swap zip
        simple-table. nl
    ] [
        "Type check stubs:" print
        { "Tag only" "Hi-tag" "Tuple" "Hi-tag and tuple" } swap zip
        simple-table.
    ] bi* ;

: time ( quot -- )
    gc-reset
    reset-dispatch-stats
    reset-inline-cache-stats
    benchmark gc-stats dispatch-stats inline-cache-stats
    H{ { table-gap { 20 20 } } } [
        [
            [ [ time. ] 3dip ] with-cell
            [ ] with-cell
        ] with-row
        [
            [ [ gc-stats. ] 2dip ] with-cell
            [ [ dispatch-stats. ] [ inline-cache-stats. ] bi* ] with-cell
        ] with-row
    ] tabular-output nl ; inline
