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
USE: format
USE: kernel
USE: lists
USE: logging
USE: namespaces
USE: parser
USE: regexp
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
    [ "text/html" response ] [ error-body ] cleave
    cat2
    print ;

: read-header-iter ( alist -- alist )
    read dup "" = [
        drop
    ] [
        "(.+?): (.+)" groups [ uncons car cons swons ]  when*
        read-header-iter
    ] ifte ;

: read-header ( -- alist )
    [ ] read-header-iter ;

: content-length ( alist -- length )
    "Content-Length" swap assoc parse-number ;

: read-post-request ( -- string )
    read-header content-length dup [ read# url-decode ] when ;
