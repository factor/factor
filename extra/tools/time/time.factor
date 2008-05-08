! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.vectors memory io io.styles prettyprint
namespaces system sequences assocs ;
IN: tools.time

: benchmark ( quot -- gctime runtime )
    millis >r call millis r> - ; inline

: stats. ( data -- )
    {
        "Run time (ms):"
        "Nursery GC time (ms):"
        "Nursery GC #:"
        "Aging GC time (ms):"
        "Aging GC #:"
        "Tenured GC time (ms):"
        "Tenured GC #:"
        "Cards scanned:"
        "Decks scanned:"
        "Code literal GC #:"
        "Bytes copied:"
        "Bytes collected:"
    } swap zip
    standard-table-style [
        [
            [
                [ [ write ] with-cell ] [ pprint-cell ] bi*
            ] with-row
        ] assoc-each
    ] tabular-output ;

: stats gc-stats millis prefix ;

: time ( quot -- )
    stats >r call stats r> v- stats. ; inline
