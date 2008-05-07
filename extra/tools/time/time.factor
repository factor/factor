! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.vectors memory io io.styles prettyprint
namespaces system sequences assocs ;
IN: tools.time

: benchmark ( quot -- gctime runtime )
    millis >r call millis r> - ; inline

: stats. ( data -- )
    {
        "Run time"
        "GC time"
        "Nursery collections"
        "Aging collections"
        "Tenured collections"
        "Cards checked"
        "Cards scanned"
        "Code literal collections"
    } swap zip [ nip 0 > ] assoc-filter
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
