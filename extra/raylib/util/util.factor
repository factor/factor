USING: accessors alien alien.parser classes generic kernel lexer parser
quotations sequences slots specialized-arrays specialized-arrays.private
vocabs.parser words ;

IN: raylib.util

: array-word ( c-type -- str )
    name>> "-array" append parse-word ;

: array-direct-like ( c-type -- quot: ( alien len -- array ) )
    array-word "prototype" word-prop '[ _ direct-like ] ;

: ?use-vocab ( vocab -- )
    dup using-vocab? [ drop ] [ use-vocab ] if ;

: use-specialized-array ( c-type -- direct-constructor )
    [ define-array-vocab ?use-vocab ]
    [ array-direct-like ] bi ;

! TODO: setter?

:: define-array-slot ( struct-class element-type pointer-slot length-quot accessor -- )
    element-type use-specialized-array :> cons-quot
    accessor [ define-protocol-slot ] [ reader-word ] bi :> reader
    struct-class reader create-method :> reader-method
    pointer-slot reader-word 1quotation length-quot cons-quot
    '[ [ @ >c-ptr ] _ bi @ ] reader-method swap define ;

! ARRAY-SLOT: struct-class element-type-class pointer-slot length-quotation new-accessor
SYNTAX: ARRAY-SLOT: scan-class scan-c-type scan-token scan-object quotation check-instance scan-token define-array-slot ;
