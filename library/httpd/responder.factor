! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: httpd-responder

USE: hashtables
USE: httpd
USE: kernel
USE: lists
USE: logging
USE: namespaces
USE: stdio
USE: streams
USE: strings

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
    dup f-or-"" [ drop "default-argument" get ] when ;

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
