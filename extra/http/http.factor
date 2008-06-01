! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel combinators math namespaces

assocs sequences splitting sorting sets debugger
strings vectors hashtables quotations arrays byte-arrays
math.parser calendar calendar.format

io io.streams.string io.encodings.utf8 io.encodings.string
io.sockets io.sockets.secure io.server

unicode.case unicode.categories qualified

urls html.templates ;

EXCLUDE: fry => , ;

IN: http

: secure-protocol? ( protocol -- ? )
    "https" = ;

: url-addr ( url -- addr )
    [ [ host>> ] [ port>> ] bi <inet> ] [ protocol>> ] bi
    secure-protocol? [ <secure> ] when ;

: protocol-port ( protocol -- port )
    {
        { "http" [ 80 ] }
        { "https" [ 443 ] }
    } case ;

: ensure-port ( url -- url' )
    dup protocol>> '[ , protocol-port or ] change-port ;

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

: read-lf ( -- string )
    "\n" read-until CHAR: \n assert= ;

: read-crlf ( -- string )
    "\r" read-until
    [ CHAR: \r assert= read1 CHAR: \n assert= ] when* ;

: read-header-line ( -- )
    read-crlf dup
    empty? [ drop ] [ header-line read-header-line ] if ;

: read-header ( -- assoc )
    H{ } clone [
        "header" [ read-header-line ] with-variable
    ] keep ;

: header-value>string ( value -- string )
    {
        { [ dup number? ] [ number>string ] }
        { [ dup timestamp? ] [ timestamp>http-string ] }
        { [ dup url? ] [ url>string ] }
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

TUPLE: cookie name value path domain expires max-age http-only ;

: <cookie> ( value name -- cookie )
    cookie new
        swap >>name
        swap >>value ;

: parse-cookies ( string -- seq )
    [
        f swap

        ";" split [
            [ blank? ] trim "=" split1 swap >lower {
                { "expires" [ cookie-string>timestamp >>expires ] }
                { "max-age" [ string>number seconds >>max-age ] }
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
        [
            {
                { [ dup timestamp? ] [ timestamp>cookie-string ] }
                { [ dup duration? ] [ dt>seconds number>string ] }
                [ ]
            } cond
            "=" swap 3append ,
        ]
    } case ;

: unparse-cookie ( cookie -- strings )
    [
        dup name>> >lower over value>> (unparse-cookie)
        "path" over path>> (unparse-cookie)
        "domain" over domain>> (unparse-cookie)
        "expires" over expires>> (unparse-cookie)
        "max-age" over max-age>> (unparse-cookie)
        "httponly" over http-only>> (unparse-cookie)
        drop
    ] { } make ;

: unparse-cookies ( cookies -- string )
    [ unparse-cookie ] map concat "; " join ;

TUPLE: request
method
url
version
header
post-data
post-data-type
cookies ;

: set-header ( request/response value key -- request/response )
    pick header>> set-at ;

: <request>
    request new
        "1.1" >>version
        <url>
            "http" >>protocol
            H{ } clone >>query
        >>url
        H{ } clone >>header
        V{ } clone >>cookies
        "close" "connection" set-header
        "Factor http.client vocabulary" "user-agent" set-header ;

: chop-hostname ( str -- str' )
    ":" split1 "//" ?head drop nip
    CHAR: / over index over length or tail
    dup empty? [ drop "/" ] when ;

: url>path ( url -- path )
    #! Technically, only proxies are meant to support hostnames
    #! in HTTP requests, but IE sends these sometimes so we
    #! just chop the hostname part.
    url-decode
    dup { "http://" "https://" } [ head? ] with contains?
    [ chop-hostname ] when ;

: read-method ( request -- request )
    " " read-until [ "Bad request: method" throw ] unless
    >>method ;

: check-absolute ( url -- url )
    dup path>> "/" head? [ "Bad request: URL" throw ] unless ; inline

: read-url ( request -- request )
    " " read-until [
        dup empty? [ drop read-url ] [ >url check-absolute >>url ] if
    ] [ "Bad request: URL" throw ] if ;

: parse-version ( string -- version )
    "HTTP/" ?head [ "Bad request: version" throw ] unless
    dup { "1.0" "1.1" } member? [ "Bad request: version" throw ] unless ;

: read-request-version ( request -- request )
    read-crlf [ CHAR: \s = ] left-trim
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

: extract-host ( request -- request )
    [ ] [ url>> ] [ "host" header parse-host ] tri
    [ >>host ] [ >>port ] bi*
    ensure-port
    drop ;

: extract-post-data-type ( request -- request )
    dup "content-type" header >>post-data-type ;

: parse-post-data ( request -- request )
    dup post-data-type>> "application/x-www-form-urlencoded" =
    [ dup post-data>> query>assoc >>post-data ] when ;

: extract-cookies ( request -- request )
    dup "cookie" header [ parse-cookies >>cookies ] when* ;

: parse-content-type-attributes ( string -- attributes )
    " " split harvest [ "=" split1 [ >lower ] dip ] { } map>assoc ;

: parse-content-type ( content-type -- type encoding )
    ";" split1 parse-content-type-attributes "charset" swap at ;

: detect-protocol ( request -- request )
    dup url>> remote-address get secure? "https" "http" ? >>protocol drop ;

: read-request ( -- request )
    <request>
    read-method
    read-url
    read-request-version
    read-request-header
    read-post-data
    detect-protocol
    extract-host
    extract-post-data-type
    parse-post-data
    extract-cookies ;

: write-method ( request -- request )
    dup method>> write bl ;

: write-request-url ( request -- request )
    dup url>> relative-url url>string write bl ;

: write-version ( request -- request )
    "HTTP/" write dup request-version write crlf ;

: unparse-post-data ( request -- request )
    dup post-data>> dup sequence? [ drop ] [
        assoc>query >>post-data
        "application/x-www-form-urlencoded" >>post-data-type
    ] if ;

: url-host ( url -- string )
    [ host>> ] [ port>> ] bi dup "http" protocol-port =
    [ drop ] [ ":" swap number>string 3append ] if ;

: write-request-header ( request -- request )
    dup header>> >hashtable
    over url>> host>> [ over url>> url-host "host" pick set-at ] when
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

: request-with-url ( request url -- request )
    '[ , >url derive-url ensure-port ] change-url ;

GENERIC: write-response ( response -- )

GENERIC: write-full-response ( request response -- )

TUPLE: response
version
code
message
header
cookies
content-type
content-charset
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
    read-crlf >>message ;

: read-response-header
    read-header >>header
    extract-cookies
    dup "content-type" header [
        parse-content-type [ >>content-type ] [ >>content-charset ] bi*
    ] when* ;

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

: unparse-content-type ( request -- content-type )
    [ content-type>> "application/octet-stream" or ]
    [ content-charset>> ] bi
    [ "; charset=" swap 3append ] when* ;

: write-response-header ( response -- response )
    dup header>> clone
    over cookies>> f like [ unparse-cookies "set-cookie" pick set-at ] when*
    over unparse-content-type "content-type" pick set-at
    write-header ;

: write-response-body ( response -- response )
    dup body>> call-template ;

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

: get-cookie ( request/response name -- cookie/f )
    [ cookies>> ] dip '[ , _ name>> = ] find nip ;

: delete-cookie ( request/response name -- )
    over cookies>> [ get-cookie ] dip delete ;

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
