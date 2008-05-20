! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel combinators math namespaces

assocs sequences splitting sorting sets debugger
strings vectors hashtables quotations arrays byte-arrays
math.parser calendar calendar.format

io io.streams.string io.encodings.utf8 io.encodings.string
io.sockets io.sockets.secure

unicode.case unicode.categories qualified ;

EXCLUDE: fry => , ;

IN: http

SINGLETON: http

SINGLETON: https

GENERIC: http-port ( protocol -- port )

M: http http-port drop 80 ;

M: https http-port drop 443 ;

GENERIC: protocol>string ( protocol -- string )

M: http protocol>string drop "http" ;

M: https protocol>string drop "https" ;

: string>protocol ( string -- protocol )
    {
        { "http" [ http ] }
        { "https" [ https ] }
        [ "Unknown protocol: " swap append throw ]
    } case ;

: absolute-url? ( url -- ? )
    [ "http://" head? ] [ "https://" head? ] bi or ;

: url-quotable? ( ch -- ? )
    #! In a URL, can this character be used without
    #! URL-encoding?
    {
        { [ dup letter? ] [ t ] }
        { [ dup LETTER? ] [ t ] }
        { [ dup digit? ] [ t ] }
        { [ dup "/_-.:" member? ] [ t ] }
        [ f ]
    } cond nip ; foldable

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

: add-query-param ( value key assoc -- )
    [
        at [
            {
                { [ dup string? ] [ swap 2array ] }
                { [ dup array? ] [ swap suffix ] }
                { [ dup not ] [ drop ] }
            } cond
        ] when*
    ] 2keep set-at ;

: query>assoc ( query -- assoc )
    dup [
        "&" split H{ } clone [
            [
                >r "=" split1 [ dup [ url-decode ] when ] bi@ swap r>
                add-query-param
            ] curry each
        ] keep
    ] when ;

: assoc>query ( hash -- str )
    [
        {
            { [ dup number? ] [ number>string 1array ] }
            { [ dup string? ] [ 1array ] }
            { [ dup sequence? ] [ ] }
        } cond
    ] assoc-map
    [
        [
            >r url-encode r>
            [ url-encode "=" swap 3append , ] with each
        ] assoc-each
    ] { } make "&" join ;

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
protocol
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

: set-header ( request/response value key -- request/response )
    pick header>> set-at ;

: <request>
    request new
        "1.1" >>version
        http >>protocol
        H{ } clone >>header
        H{ } clone >>query
        V{ } clone >>cookies
        "close" "connection" set-header ;

: query-param ( request key -- value )
    swap query>> at ;

: set-query-param ( request value key -- request )
    pick query>> set-at ;

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

: parse-host ( string -- host port )
    "." ?tail drop ":" split1
    dup [ string>number ] when ;

: extract-host ( request -- request )
    dup [ "host" header parse-host ] keep protocol>> http-port or
    [ >>host ] [ >>port ] bi* ;

: extract-post-data-type ( request -- request )
    dup "content-type" header >>post-data-type ;

: parse-post-data ( request -- request )
    dup post-data-type>> "application/x-www-form-urlencoded" =
    [ dup post-data>> query>assoc >>post-data ] when ;

: extract-cookies ( request -- request )
    dup "cookie" header [ parse-cookies >>cookies ] when* ;

: parse-content-type-attributes ( string -- attributes )
    " " split harvest [ "=" split1 >r >lower r> ] { } map>assoc ;

: parse-content-type ( content-type -- type encoding )
    ";" split1 parse-content-type-attributes "charset" swap at ;

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

GENERIC: protocol-addr ( request protocol -- addr )

M: object protocol-addr
    drop [ host>> ] [ port>> ] bi <inet> ;

M: https protocol-addr
    call-next-method <secure> ;

: request-addr ( request -- addr )
    dup protocol>> protocol-addr ;

: request-host ( request -- string )
    [ host>> ] [ port>> ] bi dup http http-port =
    [ drop ] [ ":" swap number>string 3append ] if ;

: write-request-header ( request -- request )
    dup header>> >hashtable
    over host>> [ over request-host "host" pick set-at ] when
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

: request-with-path ( request path -- request )
    [ "/" prepend ] [ "/" ] if*
    "?" split1 [ >>path ] [ dup [ query>assoc ] when >>query ] bi* ;

: request-with-url ( request url -- request )
    ":" split1
    [ string>protocol >>protocol ]
    [
        "//" ?head [ "Invalid URL" throw ] unless
        "/" split1
        [
            parse-host [ >>host ] [ >>port ] bi*
            dup protocol>> http-port '[ , or ] change-port
        ]
        [ request-with-path ]
        bi*
    ] bi* ;

: request-url ( request -- url )
    [
        [
            dup host>> [
                [ protocol>> protocol>string write "://" write ]
                [ host>> url-encode write ":" write ]
                [ [ port>> ] [ protocol>> http-port or ] bi number>string write ]
                tri
            ] [ drop ] if
        ]
        [ path>> "/" head? [ "/" write ] unless ]
        [ write-url ]
        tri
    ] with-string-writer ;

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

GENERIC: write-response-body* ( body -- )

M: f write-response-body* drop ;

M: string write-response-body* write ;

M: callable write-response-body* call ;

M: object write-response-body* output-stream get stream-copy ;

: write-response-body ( response -- response )
    dup body>> write-response-body* ;

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
