! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: httpd-responder
USING: hashtables httpd kernel logging namespaces sequences
strings ;

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

: serve-explicit-responder ( method url -- )
    "/" split1 dup [
        swap get-responder call-responder
    ] [
        ! Just a responder name by itself
        drop "request" get "/" cat2 redirect drop
    ] ifte ;

: log-responder ( url -- )
    "Calling responder " swap cat2 log ;

: trim-/ ( url -- url )
    #! Trim a leading /, if there is one.
    "/" ?string-head drop ;

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
