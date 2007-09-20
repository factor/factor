USING: io io.files sequences xml xml.utilities ;
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
    <file-writer> [
        file>xml (msxml>csv) print-csv
    ] with-stream ;
