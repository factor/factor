! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel combinators math namespaces
assocs assocs.lib sequences splitting sorting sets debugger
strings vectors hashtables quotations arrays byte-arrays
math.parser calendar calendar.format present

io io.encodings io.encodings.iana io.encodings.binary
io.encodings.8-bit

unicode.case unicode.categories qualified

urls html.templates xml xml.data xml.writer

http.parsers ;

EXCLUDE: fry => , ;

IN: http

: crlf ( -- ) "\r\n" write ;

: read-crlf ( -- bytes )
    "\r" read-until
    [ CHAR: \r assert= read1 CHAR: \n assert= ] when* ;

: (read-header) ( -- alist )
    [ read-crlf dup f like ] [ parse-header-line ] [ drop ] unfold ;

: process-header ( alist -- assoc )
    f swap [ [ swap or dup ] dip swap ] assoc-map nip
    [ ?push ] histogram [ "; " join ] assoc-map
    >hashtable ;

: read-header ( -- assoc )
    (read-header) process-header ;

: header-value>string ( value -- string )
    {
        { [ dup timestamp? ] [ timestamp>http-string ] }
        { [ dup array? ] [ [ header-value>string ] map "; " join ] }
        [ present ]
    } cond ;

: check-header-string ( str -- str )
    #! http://en.wikipedia.org/wiki/HTTP_Header_Injection
    dup "\r\n\"" intersect empty?
    [ "Header injection attack" throw ] unless ;

: write-header ( assoc -- )
    >alist sort-keys [
        [ check-header-string write ": " write ]
        [ header-value>string check-header-string write crlf ] bi*
    ] assoc-each crlf ;

TUPLE: cookie name value version comment path domain expires max-age http-only secure ;

: <cookie> ( value name -- cookie )
    cookie new
        swap >>name
        swap >>value ;

: parse-set-cookie ( string -- seq )
    [
        f swap
        (parse-set-cookie)
        [
            swap {
                { "version" [ >>version ] }
                { "comment" [ >>comment ] }
                { "expires" [ cookie-string>timestamp >>expires ] }
                { "max-age" [ string>number seconds >>max-age ] }
                { "domain" [ >>domain ] }
                { "path" [ >>path ] }
                { "httponly" [ drop t >>http-only ] }
                { "secure" [ drop t >>secure ] }
                [ <cookie> dup , nip ]
            } case
        ] assoc-each
        drop
    ] { } make ;

: parse-cookie ( string -- seq )
    [
        f swap
        (parse-cookie)
        [
            swap {
                { "$version" [ >>version ] }
                { "$domain" [ >>domain ] }
                { "$path" [ >>path ] }
                [ <cookie> dup , nip ]
            } case
        ] assoc-each
        drop
    ] { } make ;

: check-cookie-string ( string -- string' )
    dup "=;'\"\r\n" intersect empty?
    [ "Bad cookie name or value" throw ] unless ;

: unparse-cookie-value ( key value -- )
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

: (unparse-cookie) ( cookie -- strings )
    [
        dup name>> check-cookie-string >lower
        over value>> unparse-cookie-value
        "$path" over path>> unparse-cookie-value
        "$domain" over domain>> unparse-cookie-value
        drop
    ] { } make ;

: unparse-cookie ( cookies -- string )
    [ (unparse-cookie) ] map concat "; " join ;

: unparse-set-cookie ( cookie -- string )
    [
        dup name>> check-cookie-string >lower
        over value>> unparse-cookie-value
        "path" over path>> unparse-cookie-value
        "domain" over domain>> unparse-cookie-value
        "expires" over expires>> unparse-cookie-value
        "max-age" over max-age>> unparse-cookie-value
        "httponly" over http-only>> unparse-cookie-value
        "secure" over secure>> unparse-cookie-value
        drop
    ] { } make "; " join ;

TUPLE: request
method
url
version
header
post-data
cookies ;

: check-url ( string -- url )
    >url dup path>> "/" head? [ "Bad request: URL" throw ] unless ; inline

: read-request-line ( request -- request )
    read-crlf parse-request-line first3
    [ >>method ] [ check-url >>url ] [ >>version ] tri* ;

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

: check-absolute ( url -- url )
    dup path>> "/" head? [ "Bad request: URL" throw ] unless ; inline

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
    dup "cookie" header [ parse-cookie >>cookies ] when* ;

: parse-content-type-attributes ( string -- attributes )
    " " split harvest [ "=" split1 [ >lower ] dip ] { } map>assoc ;

: parse-content-type ( content-type -- type encoding )
    ";" split1 parse-content-type-attributes "charset" swap at ;

: read-request ( -- request )
    <request>
    read-request-line
    read-request-header
    read-post-data
    extract-host
    extract-cookies ;

: write-request-line ( request -- request )
    dup
    [ method>> write bl ]
    [ url>> relative-url present write bl ]
    [ "HTTP/" write version>> write crlf ]
    tri ;

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
    over cookies>> f like [ unparse-cookie "cookie" pick set-at ] when*
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
    write-request-line
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

: read-response-line ( response -- response )
    read-crlf parse-response-line first3
    [ >>version ] [ >>code ] [ >>message ] tri* ;

: read-response-header ( response -- response )
    read-header >>header
    dup "set-cookie" header parse-set-cookie >>cookies
    dup "content-type" header [
        parse-content-type
        [ >>content-type ]
        [ name>encoding binary or >>content-charset ] bi*
    ] when* ;

: read-response ( -- response )
    <response>
    read-response-line
    read-response-header ;

: write-response-line ( response -- response )
    dup
    [ "HTTP/" write version>> write bl ]
    [ code>> present write bl ]
    [ message>> write crlf ]
    tri ;

: unparse-content-type ( request -- content-type )
    [ content-type>> "application/octet-stream" or ]
    [ content-charset>> encoding>name ]
    bi
    [ "; charset=" swap 3append ] when* ;

: ensure-domain ( cookie -- cookie )
    [
        request get url>>
        host>> dup "localhost" =
        [ drop ] [ or ] if
    ] change-domain ;

: write-response-header ( response -- response )
    #! We send one set-cookie header per cookie, because that's
    #! what Firefox expects.
    dup header>> >alist >vector
    over unparse-content-type "content-type" pick set-at
    over cookies>> [
        ensure-domain unparse-set-cookie
        "set-cookie" swap 2array over push
    ] each
    write-header ;

: write-response-body ( response -- response )
    dup body>> call-template ;

M: response write-response ( respose -- )
    write-response-line
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
    write-response-line
    write-response-body
    drop ;

M: raw-response write-full-response ( response -- )
    write-response nip ;
