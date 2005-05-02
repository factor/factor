! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: httpd
USING: hashtables http kernel lists namespaces parser sequences
stdio streams strings ;

: print-header ( alist -- )
    [ unswons write ": " write url-encode print ] each ;

: response ( header msg -- )
    "HTTP/1.0 " write print print-header ;

: error-body ( error -- body )
    "<html><body><h1>" swap "</h1></body></html>" cat3 print ;

: error-head ( error -- )
    dup log-error
    [ [[ "Content-Type" "text/html" ]] ] over response ;

: httpd-error ( error -- )
    #! This must be run from handle-request
    error-head
    "head" "method" get = [ terpri error-body ] unless ;

: bad-request ( -- )
    [
        ! Make httpd-error print a body
        "get" "method" set
        "400 Bad request" httpd-error
    ] with-scope ;

: serving-html ( -- )
    [ [[ "Content-Type" "text/html" ]] ]
    "200 Document follows" response terpri ;

: serving-text ( -- )
    [ [[ "Content-Type" "text/plain" ]] ]
    "200 Document follows" response terpri ;

: redirect ( to -- )
    "Location" swons unit
    "301 Moved Permanently" response terpri ;

: directory-no/ ( -- )
    [
        "request" get , CHAR: / ,
        "raw-query" get [ CHAR: ? , , ] when*
    ] make-string redirect ;

: content-length ( alist -- length )
    "Content-Length" swap assoc parse-number ;

: query>alist ( query -- alist )
    dup [
        "&" split [
            "=" split1
            dup [ url-decode ] when swap
            dup [ url-decode ] when swap cons
        ] map
    ] when ;

: read-post-request ( header -- alist )
    content-length dup [ read query>alist ] when ;

: log-user-agent ( alist -- )
    "User-Agent" swap assoc* [
        unswons [ , ": " , , ] make-string log
    ] when* ;

: prepare-url ( url -- url )
    #! This is executed in the with-request namespace.
    "?" split1
    dup "raw-query" set query>alist "query" set
    dup "request" set ;

: prepare-header ( -- )
    read-header dup "header" set
    dup log-user-agent
    read-post-request "response" set ;

! Responders are called in a new namespace with these
! variables:

! - method -- one of get, post, or head.
! - request -- the entire URL requested, including responder
!              name
! - raw-query -- raw query string
! - query -- an alist of query parameters, eg
!            foo.bar?a=b&c=d becomes
!            [ [[ "a" "b" ]] [[ "c" "d" ]] ]
! - header -- an alist of headers from the user's client
! - response -- an alist of the POST request response

: <responder> ( -- responder )
    <namespace> [
        ( url -- )
        [
            drop "GET method not implemented" httpd-error
        ] "get" set
        ( url -- )
        [
            drop "POST method not implemented" httpd-error
        ] "post" set
        ( url -- )
        [
            drop "HEAD method not implemented" httpd-error
        ] "head" set
        ( url -- )
        [
            drop bad-request
        ] "bad" set
    ] extend ;

: get-responder ( name -- responder )
    "httpd-responders" get hash [
        "404" "httpd-responders" get hash
    ] unless* ;

: default-responder ( -- responder )
    "default" get-responder ;

: set-default-responder ( name -- )
    get-responder "default" "httpd-responders" get set-hash ;

: responder-argument ( argument -- argument )
    dup empty? [ drop "default-argument" get ] when ;

: call-responder ( method argument responder -- )
    [ responder-argument swap get call ] bind ;

: serve-default-responder ( method url -- )
    default-responder call-responder ;

: log-responder ( url -- )
    "Calling responder " swap cat2 log ;

: trim-/ ( url -- url )
    #! Trim a leading /, if there is one.
    "/" ?string-head drop ;

: serve-explicit-responder ( method url -- )
    "/" split1 dup [
        swap get-responder call-responder
    ] [
        ! Just a responder name by itself
        drop "request" get "/" cat2 redirect drop
    ] ifte ;

: serve-responder ( method url -- )
    #! Responder URLs come in two forms:
    #! /foo/bar... - default-responder used
    #! /responder/foo/bar - responder foo, argument bar
    dup log-responder trim-/ "responder/" ?string-head [
        serve-explicit-responder
    ] [
        serve-default-responder
    ] ifte ;

: no-such-responder ( -- )
    "404 No such responder" httpd-error ;

: add-responder ( responder -- )
    #! Add a responder object to the list.
    "responder" over hash  "httpd-responders" get set-hash ;
