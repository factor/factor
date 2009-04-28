! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.vectors memory io io.styles prettyprint
namespaces system sequences splitting grouping assocs strings ;
IN: tools.time

: benchmark ( quot -- runtime )
    micros [ call micros ] dip - ; inline

: time. ( data -- )
    unclip
    "==== RUNNING TIME" print nl 1000000 /f pprint " seconds" print nl
    5 cut*
    "==== GARBAGE COLLECTION" print nl
    [
        6 group
        {
            "GC count:"
            "Cumulative GC time (us):"
            "Longest GC pause (us):"
            "Average GC pause (us):"
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
            "Total GC time (us):"
            "Cards scanned:"
            "Decks scanned:"
            "Card scan time (us):"
            "Code heap literal scans:"
        } swap zip simple-table.
    ] bi* ;

: time ( quot -- )
    gc-reset micros [ call gc-stats micros ] dip - prefix time. ; inline
