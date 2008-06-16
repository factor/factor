! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel combinators math namespaces

assocs sequences splitting sorting sets debugger
strings vectors hashtables quotations arrays byte-arrays
math.parser calendar calendar.format present

io io.encodings io.encodings.iana io.encodings.binary
io.encodings.8-bit

unicode.case unicode.categories qualified

urls html.templates xml xml.data xml.writer ;

EXCLUDE: fry => , ;

IN: http

: crlf ( -- ) "\r\n" write ;

: add-header ( value key assoc -- )
    [ at dup [ "; " rot 3append ] [ drop ] if ] 2keep set-at ;

: header-line ( line -- )
    dup first blank? [
        [ blank? ] left-trim
        "last-header" get
        "header" get
        add-header
    ] [
        ":" split1 dup [
            [ blank? ] left-trim
            swap >lower dup "last-header" set
            "header" get add-header
        ] [
            2drop
        ] if
    ] if ;

: read-lf ( -- bytes )
    "\n" read-until CHAR: \n assert= ;

: read-crlf ( -- bytes )
    "\r" read-until
    [ CHAR: \r assert= read1 CHAR: \n assert= ] when* ;

: (read-header) ( -- )
    read-crlf dup
    empty? [ drop ] [ header-line (read-header) ] if ;

: read-header ( -- assoc )
    H{ } clone [
        "header" [ (read-header) ] with-variable
    ] keep ;

: header-value>string ( value -- string )
    {
        { [ dup timestamp? ] [ timestamp>http-string ] }
        { [ dup array? ] [ [ header-value>string ] map "; " join ] }
        [ present ]
    } cond ;

: check-header-string ( str -- str )
    #! http://en.wikipedia.org/wiki/HTTP_Header_Injection
    dup "\r\n" intersect empty?
    [ "Header injection attack" throw ] unless ;

: write-header ( assoc -- )
    >alist sort-keys [
        swap
        check-header-string write ": " write
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

: check-cookie-string ( string -- string' )
    dup "=;'\"" intersect empty?
    [ "Bad cookie name or value" throw ] unless ;

: (unparse-cookie) ( key value -- )
    {
        { f [ drop ] }
        { t [ check-cookie-string , ] }
        [
            {
                { [ dup timestamp? ] [ timestamp>cookie-string ] }
                { [ dup duration? ] [ dt>seconds number>string ] }
                { [ dup real? ] [ number>string ] }
                [ ]
            } cond
            check-cookie-string "=" swap check-cookie-string 3append ,
        ]
    } case ;

: unparse-cookie ( cookie -- strings )
    [
        dup name>> check-cookie-string >lower
        over value>> (unparse-cookie)
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
cookies ;

: set-header ( request/response value key -- request/response )
    pick header>> set-at ;

: <request> ( -- request )
    request new
        "1.1" >>version
        <url>
            H{ } clone >>query
        >>url
        H{ } clone >>header
        V{ } clone >>cookies
        "close" "connection" set-header
        "Factor http.client" "user-agent" set-header ;

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

TUPLE: post-data raw content content-type ;

: <post-data> ( raw content-type -- post-data )
    post-data new
        swap >>content-type
        swap >>raw ;

: parse-post-data ( post-data -- post-data )
    [ ] [ raw>> ] [ content-type>> ] tri {
        { "application/x-www-form-urlencoded" [ query>assoc ] }
        { "text/xml" [ string>xml ] }
        [ drop ]
    } case >>content ;

: read-post-data ( request -- request )
    dup method>> "POST" = [
        [ ]
        [ "content-length" header string>number read ]
        [ "content-type" header ] tri
        <post-data> parse-post-data >>post-data
    ] when ;

: extract-host ( request -- request )
    [ ] [ url>> ] [ "host" header parse-host ] tri
    [ >>host ] [ >>port ] bi*
    drop ;

: extract-cookies ( request -- request )
    dup "cookie" header [ parse-cookies >>cookies ] when* ;

: parse-content-type-attributes ( string -- attributes )
    " " split harvest [ "=" split1 [ >lower ] dip ] { } map>assoc ;

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
    extract-cookies ;

: write-method ( request -- request )
    dup method>> write bl ;

: write-request-url ( request -- request )
    dup url>> relative-url present write bl ;

: write-version ( request -- request )
    "HTTP/" write dup request-version write crlf ;

: url-host ( url -- string )
    [ host>> ] [ port>> ] bi dup "http" protocol-port =
    [ drop ] [ ":" swap number>string 3append ] if ;

: write-request-header ( request -- request )
    dup header>> >hashtable
    over url>> host>> [ over url>> url-host "host" pick set-at ] when
    over post-data>> [
        [ raw>> length "content-length" pick set-at ]
        [ content-type>> "content-type" pick set-at ]
        bi
    ] when*
    over cookies>> f like [ unparse-cookies "cookie" pick set-at ] when*
    write-header ;

GENERIC: >post-data ( object -- post-data )

M: post-data >post-data ;

M: string >post-data "application/octet-stream" <post-data> ;

M: byte-array >post-data "application/octet-stream" <post-data> ;

M: xml >post-data xml>string "text/xml" <post-data> ;

M: assoc >post-data assoc>query "application/x-www-form-urlencoded" <post-data> ;

M: f >post-data ;

: unparse-post-data ( request -- request )
    [ >post-data ] change-post-data ;

: write-post-data ( request -- request )
    dup method>> "POST" = [ dup post-data>> raw>> write ] when ; 

: write-request ( request -- )
    unparse-post-data
    write-method
    write-request-url
    write-version
    write-request-header
    write-post-data
    flush
    drop ;

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

: <response> ( -- response )
    response new
        "1.1" >>version
        H{ } clone >>header
        "close" "connection" set-header
        now timestamp>http-string "date" set-header
        "Factor http.server" "server" set-header
        latin1 >>content-charset
        V{ } clone >>cookies ;

M: response clone
    call-next-method
        [ clone ] change-header
        [ clone ] change-cookies ;

: read-response-version ( response -- response )
    " \t" read-until
    [ "Bad response: version" throw ] unless
    parse-version
    >>version ;

: read-response-code ( response -- response )
    " \t" read-until [ "Bad response: code" throw ] unless
    string>number [ "Bad response: code" throw ] unless*
    >>code ;

: read-response-message ( response -- response )
    read-crlf >>message ;

: read-response-header ( response -- response )
    read-header >>header
    dup "set-cookie" header parse-cookies >>cookies
    dup "content-type" header [
        parse-content-type
        [ >>content-type ]
        [ name>encoding binary or >>content-charset ] bi*
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
    [ content-charset>> encoding>name ]
    bi
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
    swap method>> "HEAD" = [
        [ content-charset>> encode-output ]
        [ write-response-body ]
        bi
    ] unless ;

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
