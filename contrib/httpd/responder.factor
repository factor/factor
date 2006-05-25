! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: httpd
USING: arrays hashtables http kernel math namespaces
parser sequences io strings ;

! Variables
SYMBOL: vhosts
SYMBOL: responders

: print-header ( alist -- )
    [ swap write ": " write url-encode print ] hash-each ;

: response ( header msg -- )
    "HTTP/1.0 " write print print-header ;

: error-body ( error -- body )
    "<html><body><h1>" swap "</h1></body></html>" append3 print ;

: error-head ( error -- )
    dup log-error
    H{ { "Content-Type" "text/html" } } over response ;

: httpd-error ( error -- )
    #! This must be run from handle-request
    error-head
    "head" "method" get = [ drop ] [ terpri error-body ] if ;

: bad-request ( -- )
    [
        ! Make httpd-error print a body
        "get" "method" set
        "400 Bad request" httpd-error
    ] with-scope ;

: serving-content ( mime -- )
    "Content-Type" associate
    "200 Document follows" response terpri ;

: serving-html "text/html" serving-content ;

: serving-text "text/plain" serving-content ;

: redirect ( to -- )
    "Location" associate
    "301 Moved Permanently" response terpri ;

: directory-no/ ( -- )
    [
        "request" get % CHAR: / ,
        "raw-query" get [ CHAR: ? , % ] when*
    ] "" make redirect ;

: query>hash ( query -- hash )
    dup [
        "&" split [
            "=" split1 [ dup [ url-decode ] when ] 2apply 2array
        ] map
    ] when alist>hash ;

: read-post-request ( header -- hash )
    "Content-Length" swap hash dup
    [ string>number read query>hash ] when ;

: log-headers ( hash -- )
    [
        drop { "User-Agent" "X-Forwarded-For" "Host" } member?
    ] hash-subset [ ": " swap append3 log-message ] hash-each ;

: prepare-url ( url -- url )
    #! This is executed in the with-request namespace.
    "?" split1
    dup "raw-query" set query>hash "query" set
    dup "request" set ;

: prepare-header ( -- )
    read-header dup "header" set
    dup log-headers
    read-post-request "response" set ;

! Responders are called in a new namespace with these
! variables:

! - method -- one of get, post, or head.
! - request -- the entire URL requested, including responder
!              name
! - raw-query -- raw query string
! - query -- a hashtable of query parameters, eg
!            foo.bar?a=b&c=d becomes
!            H{ { "a" "b" } { "c" "d" } }
! - header -- a hashtable of headers from the user's client
! - response -- a hashtable of the POST request response

: add-responder ( responder -- )
    #! Add a responder object to the list.
    "responder" over hash  responders get set-hash ;

: make-responder ( quot -- responder )
    [
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
        
        call
    ] make-hash add-responder ;

: vhost ( name -- responder )
    vhosts get hash [ "default" vhost ] unless* ;

: responder ( name -- responder )
    responders get hash [ "404" responder ] unless* ;

: set-default-responder ( name -- )
    responder "default" responders get set-hash ;

: call-responder ( method argument responder -- )
    over "argument" set [ swap get call ] bind ;

: serve-default-responder ( method url -- )
    "default" responder call-responder ;

: log-responder ( path -- )
    "Calling responder " swap append log-message ;

: trim-/ ( url -- url )
    #! Trim a leading /, if there is one.
    "/" ?head drop ;

: serve-explicit-responder ( method url -- )
    "/" split1 dup [
        swap responder call-responder
    ] [
        ! Just a responder name by itself
        drop "request" get "/" append redirect drop
    ] if ;

: serve-responder ( method path host -- )
    #! Responder paths come in two forms:
    #! /foo/bar... - default responder used
    #! /responder/foo/bar - responder foo, argument bar
    vhost [
        dup log-responder trim-/ "responder/" ?head [
            serve-explicit-responder
        ] [
            serve-default-responder
        ] if
    ] bind ;

: no-such-responder ( -- )
    "404 No such responder" httpd-error ;
