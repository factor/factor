! Copyright (C) 2003, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs assocs.extras base64
calendar calendar.format calendar.parser combinators hashtables
http.parsers io io.crlf io.encodings.iana io.encodings.utf8
kernel make math math.parser mime.types present sequences sets
sorting splitting urls ;
IN: http

CONSTANT: max-redirects 10

: process-header ( alist -- assoc )
    [ ] collect-assoc-by
    [  "; " join ] map-values >hashtable ;

: read-header ( -- assoc )
    [ read-?crlf dup f like ]
    [ parse-header-line ] produce nip
    process-header ;

: header-value>string ( value -- string )
    {
        { [ dup timestamp? ] [ timestamp>http-string ] }
        { [ dup array? ] [ [ header-value>string ] map "; " join ] }
        [ present ]
    } cond ;

: check-header-string ( str -- str )
    ! https://en.wikipedia.org/wiki/HTTP_Header_Injection
    dup "\r\n" intersects?
    [ "Header injection attack" throw ] when ;

: write-header ( assoc -- )
    sort-keys [
        [ check-header-string write ": " write ]
        [ header-value>string check-header-string write crlf ] bi*
    ] assoc-each crlf ;

TUPLE: cookie name value version comment path domain expires max-age http-only secure
priority samesite sameparty hostprefix domainprefix ;

: <cookie> ( value name -- cookie )
    cookie new
        swap >>name
        swap >>value ;

: parse-set-cookie ( string -- seq )
    [
        f swap
        (parse-set-cookie)
        [
            swapd pick >lower {
                { "version" [ >>version ] }
                { "comment" [ >>comment ] }
                { "expires" [ [ cookie-string>timestamp >>expires ] unless-empty ] }
                { "max-age" [ string>number seconds >>max-age ] }
                { "domain" [ >>domain ] }
                { "path" [ >>path ] }
                { "httponly" [ drop t >>http-only ] }
                { "secure" [ drop t >>secure ] }
                { "priority" [ >>priority ] }
                { "samesite" [ >>samesite ] }
                { "sameparty" [ >>sameparty ] }
                { "hostprefix" [ >>hostprefix ] }
                { "domainprefix" [ >>domainprefix ] }
                [ drop rot <cookie> dup , ]
            } case nip
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
    dup "=;'\"\r\n" intersects?
    [ "Bad cookie name or value" throw ] when ;

: unparse-cookie-value ( key value -- )
    {
        { f [ drop ] }
        { t [ check-cookie-string , ] }
        [
            {
                { [ dup timestamp? ] [ timestamp>cookie-string ] }
                { [ dup duration? ] [ duration>seconds number>string ] }
                { [ dup real? ] [ number>string ] }
                [ ]
            } cond
            [ check-cookie-string ] bi@ "=" glue ,
        ]
    } case ;

: check-cookie-value ( string -- string )
    [ "Cookie value must not be f" throw ] unless* ;

: (unparse-cookie) ( cookie -- strings )
    [
        dup name>> check-cookie-string
        over value>> check-cookie-value unparse-cookie-value
        "$path" over path>> unparse-cookie-value
        "$domain" over domain>> unparse-cookie-value
        drop
    ] { } make ;

: unparse-cookie ( cookies -- string )
    [ (unparse-cookie) ] map concat "; " join ;

: unparse-set-cookie ( cookie -- string )
    [
        dup name>> check-cookie-string
        over value>> check-cookie-value unparse-cookie-value
        "path" over path>> unparse-cookie-value
        "domain" over domain>> unparse-cookie-value
        "expires" over expires>> unparse-cookie-value
        "max-age" over max-age>> unparse-cookie-value
        "httponly" over http-only>> unparse-cookie-value
        "secure" over secure>> unparse-cookie-value
        "priority" over priority>> unparse-cookie-value
        "samesite" over samesite>> unparse-cookie-value
        "sameparty" over sameparty>> unparse-cookie-value
        "hostprefix" over hostprefix>> unparse-cookie-value
        "domainprefix" over domainprefix>> unparse-cookie-value
        drop
    ] { } make "; " join ;

TUPLE: request
    method
    url
    proxy-url
    version
    header
    post-data
    cookies
    redirects ;

: set-header ( request/response value key -- request/response )
    pick header>> set-at ;

: set-headers ( request/response assoc -- request/response )
    [ swap set-header ] assoc-each ; inline

: delete-header ( request/response key -- request/response )
    over header>> delete-at ;

: bearer-auth ( token -- string ) "Bearer " prepend ;

: set-bearer-auth ( request token -- request )
    bearer-auth "Authorization" set-header ;

: basic-auth ( username password -- str )
    ":" glue >base64 "Basic " "" prepend-as ;

: set-basic-auth ( request username password -- request )
    basic-auth "Authorization" set-header ;

: set-proxy-basic-auth ( request username password -- request )
    basic-auth "Proxy-Authorization" set-header ;

: <request> ( -- request )
    request new
        "1.1" >>version
        <url>
            H{ } clone >>query
        >>url
        <url> >>proxy-url
        H{ } clone >>header
        V{ } clone >>cookies
        "close" "Connection" set-header
        "Factor http.client" "User-Agent" set-header
        max-redirects >>redirects ;

: header ( request/response key -- value )
    swap header>> at ;

TUPLE: response
    version
    code
    message
    header
    cookies
    content-type
    content-charset
    content-encoding
    body ;

: <response> ( -- response )
    response new
        "1.1" >>version
        H{ } clone >>header
        "close" "Connection" set-header
        now timestamp>http-string "Date" set-header
        "Factor http.server" "Server" set-header
        utf8 >>content-encoding
        V{ } clone >>cookies ;

M: response clone
    call-next-method
        [ clone ] change-header
        [ clone ] change-cookies ;

: get-cookie ( request/response name -- cookie/f )
    [ cookies>> ] dip '[ [ _ ] dip name>> = ] find nip ;

: delete-cookie ( request/response name -- )
    over cookies>> [ get-cookie ] dip remove! drop ;

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

TUPLE: post-data data params content-type content-encoding ;

: <post-data> ( content-type -- post-data )
    post-data new
        swap >>content-type ;

: parse-content-type-attributes ( string -- attributes )
    split-words harvest [
        "=" split1
        "\"" ?head drop "\"" ?tail drop
    ] map>alist ;

: parse-content-type ( content-type -- type encoding )
    ";" split1
    parse-content-type-attributes "charset" of
    [ dup mime-type-encoding encoding>name ] unless* ;
