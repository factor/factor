USING: kernel namespaces sequences math math.parser strings io io.streams.string ascii combinators ;

IN: csexp

GENERIC: write-csexp ( obj -- )

SINGLETON: end-of-list

ERROR: csexp-error ;

M: string write-csexp
    dup length number>string write
    CHAR: : write1
    write ;

M: sequence write-csexp
    CHAR: ( write1
    [ write-csexp ] each
    CHAR: ) write1 ;

: >csexp ( obj -- string )
    [ write-csexp ] with-string-writer ;

: digit>num ( digit -- num )
    CHAR: 0 - ;

: add-digit-to-num ( num digit -- num )
    [ 10 * ] [ digit>num ] bi* + ;

: read-string ( size -- string )
    read1 {
        { [ dup CHAR: : = ] [ drop dup 0 = [ drop "" ] [ read ] if ] }
        { [ dup digit? ] [ add-digit-to-num read-string ] }
        [ drop csexp-error ]
    } cond ;

DEFER: read-csexp-with-eol

: read-list ( acc -- obj )
    read-csexp-with-eol dup end-of-list? [ drop ] [ over push read-list ] if ;

: read-csexp-with-eol ( -- obj )
    read1 {
        { [ dup CHAR: ( = ] [ drop V{ } clone read-list ] }
        { [ dup CHAR: ) = ] [ drop end-of-list ] }
        { [ dup digit? ] [ digit>num read-string ] }
        [ drop csexp-error ]
    } cond ;

: read-csexp ( -- obj )
    read-csexp-with-eol dup end-of-list? [ csexp-error ] when ;

: csexp> ( string -- obj )
    [ read-csexp ] with-string-reader ;
