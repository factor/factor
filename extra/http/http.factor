! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: hashtables io io.streams.string kernel math namespaces
math.parser assocs sequences strings splitting ascii
io.encodings.utf8 assocs.lib namespaces unicode.case combinators
vectors sorting new-slots accessors calendar ;
IN: http

: http-port 80 ; inline

: crlf "\r\n" write ;

: header-line ( line -- )
    ": " split1 dup [ swap >lower insert ] [ 2drop ] if ;

: read-header-line ( -- )
    readln dup
    empty? [ drop ] [ header-line read-header-line ] if ;

: read-header ( -- multi-assoc )
    [ read-header-line ] H{ } make-assoc ;

: write-header ( multi-assoc -- )
    >alist sort-keys
    [
        swap write ": " write {
            { [ dup number? ] [ number>string ] }
            { [ dup timestamp? ] [ timestamp>http-string ] }
            { [ dup string? ] [ ] }
        } cond write crlf
    ] multi-assoc-each crlf ;

: url-quotable? ( ch -- ? )
    #! In a URL, can this character be used without
    #! URL-encoding?
    dup letter?
    over LETTER? or
    over digit? or
    swap "/_-." member? or ; foldable

: push-utf8 ( ch -- )
    1string encode-utf8 [ CHAR: % , >hex 2 CHAR: 0 pad-left % ] each ;

: url-encode ( str -- str )
    [ [
        dup url-quotable? [ , ] [ push-utf8 ] if
    ] each ] "" make ;

: url-decode-hex ( index str -- )
    2dup length 2 - >= [
        2drop
    ] [
        >r 1+ dup 2 + r> subseq  hex> [ , ] when*
    ] if ;

: url-decode-% ( index str -- index str )
    2dup url-decode-hex >r 3 + r> ;

: url-decode-+-or-other ( index str ch -- index str )
    dup CHAR: + = [ drop CHAR: \s ] when , >r 1+ r> ;

: url-decode-iter ( index str -- )
    2dup length >= [
        2drop
    ] [
        2dup nth dup CHAR: % = [
            drop url-decode-%
        ] [
            url-decode-+-or-other
        ] if url-decode-iter
    ] if ;

: url-decode ( str -- str )
    [ 0 swap url-decode-iter ] "" make decode-utf8 ;

: query>assoc ( query -- assoc )
    dup [
        "&" split [
            "=" split1 [ dup [ url-decode ] when ] 2apply
        ] H{ } map>assoc
    ] when ;

: assoc>query ( hash -- str )
    [ [ url-encode ] 2apply "=" swap 3append ] { } assoc>map
    "&" join ;

TUPLE: request
host
port
method
path
query
version
header
post-data
post-data-type ;

: <request>
    request construct-empty
    "1.0" >>version
    http-port >>port ;

: url>path ( url -- path )
    url-decode "http://" ?head
    [ "/" split1 "" or nip ] [ "/" ?head drop ] if ;

: read-method ( request -- request )
    " " read-until [ "Bad request: method" throw ] unless
    >>method ;

: read-query ( request -- request )
    " " read-until
    [ "Bad request: query params" throw ] unless
    query>assoc >>query ;

: read-url ( request -- request )
    " ?" read-until {
        { CHAR: \s [ dup empty? [ drop read-url ] [ url>path >>path ] if ] }
        { CHAR: ? [ url>path >>path read-query ] }
        [ "Bad request: URL" throw ]
    } case ;

: parse-version ( string -- version )
    "HTTP/" ?head [ "Bad version" throw ] unless
    dup { "1.0" "1.1" } member? [ "Bad version" throw ] unless ;

: read-request-version ( request -- request )
    readln [ CHAR: \s = ] left-trim
    parse-version
    >>version ;

: read-request-header ( request -- request )
    read-header >>header ;

SYMBOL: max-post-request

1024 256 * max-post-request set-global

: content-length ( header -- n )
    "content-length" peek-at string>number dup [
        dup max-post-request get > [
            "content-length > max-post-request" throw
        ] when
    ] when ;

: read-post-data ( request -- request )
    dup header>> content-length [ read >>post-data ] when* ;

: parse-host ( string -- host port )
    "." ?tail drop ":" split1
    [ string>number ] [ http-port ] if* ;

: extract-host ( request -- request )
    dup header>> "host" peek-at parse-host >r >>host r> >>port ;

: extract-post-data-type ( request -- request )
    dup header>> "content-type" peek-at >>post-data-type ;

: read-request ( -- request )
    <request>
    read-method
    read-url
    read-request-version
    read-request-header
    read-post-data
    extract-host
    extract-post-data-type ;

: write-method ( request -- request )
    dup method>> write bl ;

: write-url ( request -- request )
    dup path>> url-encode write
    dup query>> dup assoc-empty? [ drop ] [
        "?" write
        assoc>query write
    ] if ;

: write-request-url ( request -- request )
    write-url bl ;

: write-version ( request -- request )
    "HTTP/" write dup request-version write crlf ;

: write-request-header ( request -- request )
    dup header>> >hashtable
    over host>> [ "host" replace-at ] when*
    over post-data>> [ length "content-length" replace-at ] when*
    over post-data-type>> [ "content-type" replace-at ] when*
    write-header ;

: write-post-data ( request -- request )
    dup post-data>> [ write ] when* ;

: write-request ( request -- )
    write-method
    write-url
    write-version
    write-request-header
    write-post-data
    flush
    drop ;

: request-url ( request -- url )
    [
        dup host>> [
            "http://" write
            dup host>> url-encode write
            ":" write
            dup port>> number>string write
        ] when
        "/" write
        write-url
        drop
    ] with-string-writer ;

TUPLE: response
version
code
message
header ;

: <response>
    response construct-empty
    "1.0" >>version
    H{ } clone >>header ;

: read-response-version
    " " read-until
    [ "Bad response: version" throw ] unless
    parse-version
    >>version ;

: read-response-code
    " " read-until [ "Bad response: code" throw ] unless
    string>number [ "Bad response: code" throw ] unless*
    >>code ;

: read-response-message
    readln >>message ;

: read-response-header
    read-header >>header ;

: read-response ( -- response )
    <response>
    read-response-version
    read-response-code
    read-response-message
    read-response-header ;

: write-response-version ( response -- response )
    "HTTP/" write
    dup version>> write bl ;

: write-response-code ( response -- response )
    dup code>> number>string write bl ;

: write-response-message ( response -- response )
    dup message>> write crlf ;

: write-response-header ( response -- response )
    dup header>> write-header ;

: write-response ( respose -- )
    write-response-version
    write-response-code
    write-response-message
    write-response-header
    flush
    drop ;

: set-response-header ( response value key -- response )
    pick header>> -rot replace-at drop ;

: set-content-type ( response content-type -- response )
    "content-type" set-response-header ;
