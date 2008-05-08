! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.vectors memory io io.styles prettyprint
namespaces system sequences splitting assocs strings ;
IN: tools.time

: benchmark ( quot -- gctime runtime )
    millis >r call millis r> - ; inline

: simple-table. ( values -- )
    standard-table-style [
        [
            [
                [
                    dup string?
                    [ [ write ] with-cell ]
                    [ pprint-cell ]
                    if
                ] each
            ] with-row
        ] each
    ] tabular-output ;

: time. ( data -- )
    unclip
    "==== RUNNING TIME" print nl pprint " ms" print nl
    4 cut*
    "==== GARBAGE COLLECTION" print nl
    [
        6 group
        {
            "GC count:"
            "Cumulative GC time (ms):"
            "Longest GC pause (ms):"
            "Average GC pause (ms):"
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
            "Total GC time (ms):"
            "Cards scanned:"
            "Decks scanned:"
            "Code heap literal scans:"
        } swap zip simple-table.
    ] bi* ;

: time ( quot -- )
    gc-reset millis >r call gc-stats millis r> - prefix time. ; inline
