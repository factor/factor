!:folding=indent:collapseFolds=1:

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
USE: arithmetic
USE: combinators
USE: errors
USE: lists
USE: logging
USE: logic
USE: namespaces
USE: regexp
USE: stack
USE: stdio
USE: streams
USE: strings

USE: httpd-responder
USE: url-encoding

: bad-request ( -- )
    "400 Bad request" httpd-error ;

: url>path ( uri -- path )
    url-decode dup "http://.*?(/.*)" group1 dup [
        nip
    ] [
        drop
    ] ifte ;

: secure-path ( request -- path )
    dup [
        "(.*?)( HTTP.*|)" group1 dup [
            dup #".*\.\.+" re-matches [ drop f ] when
        ] when
    ] when ;

: httpd-request ( request -- )
    dup log
    secure-path dup [
        url>path

        [
            [ "GET (.+)"  | [ car "get"  serve-responder ] ]
            [ "POST (.+)" | [ car "post" serve-responder ] ]
            [ t           | [ drop bad-request           ] ]
        ] re-cond
    ] [
        drop bad-request
    ] ifte ;

: httpd-client ( socket -- )
    [
        "stdio" get "client" set log-client
        read [ httpd-request ] when*
    ] with-stream ;

: quit-flag ( -- ? )
    "httpd-quit" get ;

: clear-quit-flag ( -- )
    "httpd-quit" off ;

: httpd-loop ( server -- server )
    [
        quit-flag not
    ] [
        dup accept httpd-client
    ] while ;

: httpd ( port -- )
    [
        <server> [
            httpd-loop
        ] [
            swap fclose clear-quit-flag rethrow
        ] catch
    ] with-logging ;
