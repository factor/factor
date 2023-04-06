! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs combinators http http.client json
kernel sequences splitting urls ;
IN: chrome-tools

: trim-squotes ( string -- string' ) [ CHAR: ' = ] trim ;
: trim-dquotes ( string -- string' ) [ CHAR: " = ] trim ;
: parse-key-value ( string -- value key ) trim-squotes ": " split1 swap ;

: trim-curl-command ( string -- string' )
    string-lines
    [ [ "\\ "  member? ] trim-tail ] map
    [ [ " " member? ] trim-head ] map ;

: parse-curl-command ( string method -- request )
    [ trim-curl-command ]
    [ <request> swap >>method ] bi* swap
    [
        " " split1 swap
        {
            { [ dup "curl" = ] [ drop trim-squotes >url '[ _ >>url ] ] }
            { [ dup "-H" = ] [ drop parse-key-value dup "if-modified-since" = [ 2drop f ] [ '[ _ _ set-header ] ] if ] }
            { [ dup "--compressed" = ] [ 2drop f ] }
            { [ dup "--data-raw" = ] [ drop trim-squotes '[ _ >>post-data ] ] }
            [ 2drop f ]
        } cond
    ] map [ ] concat-as curry call( -- request ) ;

: curl-get-request ( string -- response data )
    "GET" parse-curl-command http-request ;

: curl-post-request ( string -- response data )
    "POST" parse-curl-command http-request ;


: parse-fetch-command ( string -- request )
    [ blank? ] trim
    "fetch(" ?head drop
    ", " split1 [ <request> swap trim-dquotes >url >>url ] dip
    ");" ?tail drop json>
    [
        swap
        {
            { "method" [ '[ _ >>method ] ] }
            { "headers" [
                [
                    ! Remove this header so we get the data
                    swap dup "if-modified-since" = [
                        2drop f
                    ] [
                        '[ _ _ set-header ]
                    ] if
                ] { } assoc>map [ ] concat-as
            ] }
            { "body" [ '[ _ dup json-null = [ drop ] [ >>post-data ] if ] ] }
            [ 2drop f ]
        } case
    ] { } assoc>map [ ] concat-as curry call( -- request ) ;

: fetch-request ( string -- response data )
    parse-fetch-command http-request ;