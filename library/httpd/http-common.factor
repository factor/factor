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
USE: combinators
USE: format
USE: kernel
USE: lists
USE: logging
USE: namespaces
USE: parser
USE: stack
USE: stdio
USE: streams
USE: strings
USE: unparser

USE: url-encoding

: response ( msg content-type -- response )
    swap <% "HTTP/1.0 " % % "\nContent-Type: " % % "\n" % %> ;

: response-write ( msg content-type -- )
    response print ;

: error-body ( error -- body )
    "\n<html><body><h1>" swap "</h1></body></html>" cat3 ;

: httpd-error ( error -- )
    dup log-error
    <% dup "text/html" response % error-body % %> print ;

: serving-html ( -- )
    "200 Document follows" "text/html" response print ;

: serving-text ( -- )
    "200 Document follows" "text/plain" response print ;

: redirect ( to -- )
    "301 Moved Permanently" "text/plain" response write
    "Location: " write write
    terpri terpri
    "The resource has moved." print ;

: header-line ( alist line -- alist )
    ": " split1 dup [ transp acons ] [ 2drop ] ifte ;

: (read-header) ( alist -- alist )
    read dup
    f-or-"" [ drop ] [ header-line (read-header) ] ifte ;

: read-header ( -- alist )
    [ ] (read-header) ;

: content-length ( alist -- length )
    "Content-Length" swap assoc dec> ;

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
        unswons <% % ": " % % %> log
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

: with-request ( url quot -- )
    #! The quotation is called with the URL on the stack.
    [ swap prepare-url swap prepare-header call ] with-scope ;
