! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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

IN: httpd
USE: combinators
USE: errors
USE: httpd-responder
USE: kernel
USE: lists
USE: logging
USE: logic
USE: namespaces
USE: stack
USE: stdio
USE: streams
USE: strings
USE: threads
USE: url-encoding

: httpd-log-stream ( -- stream )
    #! Set httpd-log-file to save httpd log to a file.
    "httpd-log-file" get dup [
        <filecr>
    ] [
        drop "stdio" get
    ] ifte ;

: url>path ( uri -- path )
    url-decode dup "http://" str-head? dup [
        "/" split1 f "" replace nip nip
    ] [
        drop
    ] ifte ;

: secure-path ( path -- path )
    ".." over str-contains? [ drop f ] when ;

: request-method ( cmd -- method )
    [
        [ "GET" | "get" ]
        [ "POST" | "post" ]
        [ "HEAD" | "head" ]
    ] assoc [ "bad" ] unless* ;

: (handle-request) ( arg cmd -- url method )
    request-method dup "method" set swap
    prepare-url prepare-header ;

: handle-request ( arg cmd -- )
    [ (handle-request) serve-responder ] with-scope ;

: parse-request ( request -- )
    dup log
    " " split1 dup [
        " HTTP" split1 drop url>path secure-path dup [
            swap handle-request
        ] [
            2drop bad-request
        ] ifte
    ] [
        2drop bad-request
    ] ifte ;

: httpd-client ( socket -- )
    [
        [
            "stdio" get "client" set log-client
            read [ parse-request ] when*
        ] with-stream
    ] [
        [ default-error-handler drop ] when*
    ] catch ;

: httpd-connection ( socket -- )
    #! We're single-threaded in Java Factor, and
    #! multi-threaded in CFactor.
    java? [
        httpd-client
    ] [
        [
            httpd-client
        ] in-thread drop
    ] ifte ;

: quit-flag ( -- ? )
    global [ "httpd-quit" get ] bind ;

: clear-quit-flag ( -- )
    global [ "httpd-quit" off ] bind ;

: httpd-loop ( server -- server )
    quit-flag [
        dup dup accept httpd-connection
        httpd-loop
    ] unless ;

: (httpd) ( port -- )
    <server> [
        httpd-loop
    ] [
        swap fclose clear-quit-flag rethrow
    ] catch ;

: httpd ( port -- )
    [ httpd-log-stream "log" set (httpd) ] with-scope ;
