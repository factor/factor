IN: tools
USING: parser errors kernel namespaces sequences definitions
io ;

TUPLE: no-edit-hook ;

SYMBOL: edit-hook

: edit-location ( file line -- )
    >r ?resource-path r>
    edit-hook get [ call ] [ <no-edit-hook> throw ] if* ;

: edit-file ( file -- ) ?resource-path 0 edit-location ;

: edit ( defspec -- )
    where [
        first2 edit-location
    ] [
        "Not from a source file" throw
    ] if* ;
