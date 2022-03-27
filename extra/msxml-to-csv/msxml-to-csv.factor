USING: io.files sequences xml xml.traversal io.encodings.ascii kernel ;
IN: msxml-to-csv

: (msxml>csv) ( xml -- table )
    "Table" tag-named
    "Row" tags-named [
        "Cell" tags-named [
            "Data" tag-named children>string
        ] map
    ] map ;

: msxml>csv ( outfile infile -- )
    file>xml (msxml>csv) [ "," join ] map
    swap ascii set-file-lines ;
