USING: io io.files sequences xml xml.utilities io.encodings.utf8 ;
IN: msxml-to-csv

: print-csv ( table -- ) [ "," join print ] each ;

: (msxml>csv) ( xml -- table )
    "Worksheet" tag-named
    "Table" tag-named
    "Row" tags-named [
        "Cell" tags-named [
            "Data" tag-named children>string
        ] map
    ] map ;

: msxml>csv ( infile outfile -- )
    utf8 [
        file>xml (msxml>csv) print-csv
    ] with-file-writer ;
