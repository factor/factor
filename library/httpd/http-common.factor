! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
! Copyright (C) 2004 Chris Double.
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
USE: kernel
USE: lists
USE: logging
USE: namespaces
USE: parser
USE: stdio
USE: streams
USE: strings
USE: unparser

USE: url-encoding

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

: header-line ( alist line -- alist )
    ": " split1 dup [ cons swons ] [ 2drop ] ifte ;

: (read-header) ( alist -- alist )
    read dup
    f-or-"" [ drop ] [ header-line (read-header) ] ifte ;

: read-header ( -- alist )
    [ ] (read-header) ;

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
    content-length dup [ read# query>alist ] when ;

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
