! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry hashtables io io.streams.string kernel math sets
namespaces math.parser assocs sequences strings splitting ascii
io.encodings.utf8 io.encodings.string namespaces unicode.case
combinators vectors sorting accessors calendar
calendar.format quotations arrays combinators.lib byte-arrays ;
IN: http

: http-port 80 ; inline

: url-quotable? ( ch -- ? )
    #! In a URL, can this character be used without
    #! URL-encoding?
    {
        [ dup letter? ]
        [ dup LETTER? ]
        [ dup digit? ]
        [ dup "/_-.:" member? ]
    } || nip ; foldable

: push-utf8 ( ch -- )
    1string utf8 encode
    [ CHAR: % , >hex 2 CHAR: 0 pad-left % ] each ;

: url-encode ( str -- str )
    [
        [ dup url-quotable? [ , ] [ push-utf8 ] if ] each
    ] "" make ;

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
    [ 0 swap url-decode-iter ] "" make utf8 decode ;

: crlf "\r\n" write ;

: add-header ( value key assoc -- )
    [ at dup [ "; " rot 3append ] [ drop ] if ] 2keep set-at ;

: header-line ( line -- )
    dup first blank? [
        [ blank? ] left-trim
        "last-header" get
        "header" get
        add-header
    ] [
        ": " split1 dup [
            swap >lower dup "last-header" set
            "header" get add-header
        ] [
            2drop
        ] if
    ] if ;

: read-header-line ( -- )
    readln dup
    empty? [ drop ] [ header-line read-header-line ] if ;

: read-header ( -- assoc )
    H{ } clone [
        "header" [ read-header-line ] with-variable
    ] keep ;

: header-value>string ( value -- string )
    {
        { [ dup number? ] [ number>string ] }
        { [ dup timestamp? ] [ timestamp>http-string ] }
        { [ dup string? ] [ ] }
        { [ dup sequence? ] [ [ header-value>string ] map "; " join ] }
    } cond ;

: check-header-string ( str -- str )
    #! http://en.wikipedia.org/wiki/HTTP_Header_Injection
    dup "\r\n" intersect empty?
    [ "Header injection attack" throw ] unless ;

: write-header ( assoc -- )
    >alist sort-keys [
        swap url-encode write ": " write
        header-value>string check-header-string write crlf
    ] assoc-each crlf ;

: query>assoc ( query -- assoc )
    dup [
        "&" split [
            "=" split1 [ dup [ url-decode ] when ] bi@
        ] H{ } map>assoc
    ] when ;

: assoc>query ( hash -- str )
    [
        [ url-encode ]
        [ dup number? [ number>string ] when url-encode ]
        bi*
        "=" swap 3append
    ] { } assoc>map
    "&" join ;

TUPLE: cookie name value path domain expires http-only ;

: <cookie> ( value name -- cookie )
    cookie new
    swap >>name swap >>value ;

: parse-cookies ( string -- seq )
    [
        f swap

        ";" split [
            [ blank? ] trim "=" split1 swap >lower {
                { "expires" [ >>expires ] }
                { "domain" [ >>domain ] }
                { "path" [ >>path ] }
                { "httponly" [ drop t >>http-only ] }
                { "" [ drop ] }
                [ <cookie> dup , nip ]
            } case
        ] each

        drop
    ] { } make ;

: (unparse-cookie) ( key value -- )
    {
        { f [ drop ] }
        { t [ , ] }
        [ "=" swap 3append , ]
    } case ;

: unparse-cookie ( cookie -- strings )
    [
        dup name>> >lower over value>> (unparse-cookie)
        "path" over path>> (unparse-cookie)
        "domain" over domain>> (unparse-cookie)
        "expires" over expires>> (unparse-cookie)
        "httponly" over http-only>> (unparse-cookie)
        drop
    ] { } make ;

: unparse-cookies ( cookies -- string )
    [ unparse-cookie ] map concat "; " join ;

TUPLE: request
host
port
method
path
query
version
header
post-data
post-data-type
cookies ;

: <request>
    request new
        "1.1" >>version
        http-port >>port
        H{ } clone >>header
        H{ } clone >>query
        V{ } clone >>cookies ;

: query-param ( request key -- value )
    swap query>> at ;

: set-query-param ( request value key -- request )
    pick query>> set-at ;

: chop-hostname ( str -- str' )
    CHAR: / over index over length or tail
    dup empty? [ drop "/" ] when ;

: url>path ( url -- path )
    #! Technically, only proxies are meant to support hostnames
    #! in HTTP requests, but IE sends these sometimes so we
    #! just chop the hostname part.
    url-decode "http://" ?head [ chop-hostname ] when ;

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

: header ( request/response key -- value )
    swap header>> at ;

SYMBOL: max-post-request

1024 256 * max-post-request set-global

: content-length ( header -- n )
    "content-length" swap at string>number dup [
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
    dup "host" header parse-host >r >>host r> >>port ;

: extract-post-data-type ( request -- request )
    dup "content-type" header >>post-data-type ;

: parse-post-data ( request -- request )
    dup post-data-type>> "application/x-www-form-urlencoded" =
    [ dup post-data>> query>assoc >>post-data ] when ;

: extract-cookies ( request -- request )
    dup "cookie" header [ parse-cookies >>cookies ] when* ;

: read-request ( -- request )
    <request>
    read-method
    read-url
    read-request-version
    read-request-header
    read-post-data
    extract-host
    extract-post-data-type
    parse-post-data
    extract-cookies ;

: write-method ( request -- request )
    dup method>> write bl ;

: (link>string) ( url query -- url' )
    [ url-encode ] [ assoc>query ] bi*
    dup empty? [ drop ] [ "?" swap 3append ] if ;

: write-url ( request -- )
    [ path>> ] [ query>> ] bi (link>string) write ;

: write-request-url ( request -- request )
    dup write-url bl ;

: write-version ( request -- request )
    "HTTP/" write dup request-version write crlf ;

: unparse-post-data ( request -- request )
    dup post-data>> dup sequence? [ drop ] [
        assoc>query >>post-data
        "application/x-www-form-urlencoded" >>post-data-type
    ] if ;

: write-request-header ( request -- request )
    dup header>> >hashtable
    over host>> [ "host" pick set-at ] when*
    over post-data>> [ length "content-length" pick set-at ] when*
    over post-data-type>> [ "content-type" pick set-at ] when*
    over cookies>> f like [ unparse-cookies "cookie" pick set-at ] when*
    write-header ;

: write-post-data ( request -- request )
    dup post-data>> [ write ] when* ;

: write-request ( request -- )
    unparse-post-data
    write-method
    write-request-url
    write-version
    write-request-header
    write-post-data
    flush
    drop ;

: request-url ( request -- url )
    [
        [
            dup host>> [
                [ "http://" write host>> url-encode write ]
                [ ":" write port>> number>string write ]
                bi
            ] [ drop ] if
        ]
        [ path>> "/" head? [ "/" write ] unless ]
        [ write-url ]
        tri
    ] with-string-writer ;

: set-header ( request/response value key -- request/response )
    pick header>> set-at ;

GENERIC: write-response ( response -- )

GENERIC: write-full-response ( request response -- )

TUPLE: response
version
code
message
header
cookies
body ;

: <response>
    response new
    "1.1" >>version
    H{ } clone >>header
    "close" "connection" set-header
    now timestamp>http-string "date" set-header
    V{ } clone >>cookies ;

: read-response-version
    " \t" read-until
    [ "Bad response: version" throw ] unless
    parse-version
    >>version ;

: read-response-code
    " \t" read-until [ "Bad response: code" throw ] unless
    string>number [ "Bad response: code" throw ] unless*
    >>code ;

: read-response-message
    readln >>message ;

: read-response-header
    read-header >>header
    dup "set-cookie" header [ parse-cookies >>cookies ] when* ;

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
    dup header>> clone
    over cookies>> f like
    [ unparse-cookies "set-cookie" pick set-at ] when*
    write-header ;

: body>quot ( body -- quot )
    {
        { [ dup not ] [ drop [ ] ] }
        { [ dup string? ] [ [ write ] curry ] }
        { [ dup callable? ] [ ] }
        [ [ stdio get stream-copy ] curry ]
    } cond ;

: write-response-body ( response -- response )
    dup body>> body>quot call ;

M: response write-response ( respose -- )
    write-response-version
    write-response-code
    write-response-message
    write-response-header
    flush
    drop ;

M: response write-full-response ( request response -- )
    dup write-response
    swap method>> "HEAD" = [ write-response-body ] unless ;

: set-content-type ( request/response content-type -- request/response )
    "content-type" set-header ;

: get-cookie ( request/response name -- cookie/f )
    >r cookies>> r> '[ , _ name>> = ] find nip ;

: delete-cookie ( request/response name -- )
    over cookies>> >r get-cookie r> delete ;

: put-cookie ( request/response cookie -- request/response )
    [ name>> dupd get-cookie [ dupd delete-cookie ] when* ] keep
    over cookies>> push ;

TUPLE: raw-response 
version
code
message
body ;

: <raw-response> ( -- response )
    raw-response new
    "1.1" >>version ;

M: raw-response write-response ( respose -- )
    write-response-version
    write-response-code
    write-response-message
    write-response-body
    drop ;

M: raw-response write-full-response ( response -- )
    write-response nip ;
