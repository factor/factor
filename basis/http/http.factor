! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel combinators math namespaces make assocs
sequences splitting sorting sets strings vectors hashtables
quotations arrays byte-arrays math.parser calendar
calendar.format present urls fry
io io.encodings io.encodings.iana io.encodings.binary
io.encodings.8-bit io.crlf
unicode.case unicode.categories
http.parsers
base64 ;
IN: http

: (read-header) ( -- alist )
    [ read-crlf dup f like ] [ parse-header-line ] produce nip ;

: collect-headers ( assoc -- assoc' )
    H{ } clone [ '[ _ push-at ] assoc-each ] keep ;

: process-header ( alist -- assoc )
    f swap [ [ swap or dup ] dip swap ] assoc-map nip
    collect-headers [ "; " join ] assoc-map
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
    dup "\r\n\"" intersects?
    [ "Header injection attack" throw ] when ;

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
        dup name>> check-cookie-string >lower
        over value>> check-cookie-value unparse-cookie-value
        "$path" over path>> unparse-cookie-value
        "$domain" over domain>> unparse-cookie-value
        drop
    ] { } make ;

: unparse-cookie ( cookies -- string )
    [ (unparse-cookie) ] map concat "; " join ;

: unparse-set-cookie ( cookie -- string )
    [
        dup name>> check-cookie-string >lower
        over value>> check-cookie-value unparse-cookie-value
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

: set-header ( request/response value key -- request/response )
    pick header>> set-at ;

: set-basic-auth ( request username password -- request )
    ":" glue >base64 "Basic " prepend "Authorization" set-header ;
    
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

: get-cookie ( request/response name -- cookie/f )
    [ cookies>> ] dip '[ [ _ ] dip name>> = ] find nip ;

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

TUPLE: post-data data params content-type content-encoding ;

: <post-data> ( content-type -- post-data )
    post-data new
        swap >>content-type ;

: parse-content-type-attributes ( string -- attributes )
    " " split harvest [ "=" split1 [ >lower ] dip ] { } map>assoc ;

: parse-content-type ( content-type -- type encoding )
    ";" split1
    parse-content-type-attributes "charset" swap at
    [ name>encoding ]
    [ dup "text/" head? latin1 binary ? ] if* ;
