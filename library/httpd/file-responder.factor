!:folding=indent:collapseFolds=0:

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

IN: file-responder
USE: combinators
USE: html
USE: kernel
USE: lists
USE: namespaces
USE: parser
USE: regexp
USE: stack
USE: stdio
USE: streams
USE: strings

USE: httpd
USE: httpd-responder

!!! Support words.
: mime-types ( -- alist )
    [
        [  "html"   | "text/html"                ]
        [  "txt"    | "text/plain"               ]
                                                
        [  "gif"    | "image/gif"                ]
        [  "png"    | "image/png"                ]
        [  "jpg"    | "image/jpeg"               ]
        [  "jpeg"   | "image/jpeg"               ]
                    
        [  "jar"    | "application/octet-stream" ]
        [  "zip"    | "application/octet-stream" ]
        [  "tgz"    | "application/octet-stream" ]
        [  "tar.gz" | "application/octet-stream" ]
        [  "gz"     | "application/octet-stream" ]
    ] ;

: mime-type ( filename -- mime-type )
    file-extension mime-types assoc [ "text/plain" ] unless* ;

!!! Serving files.
: file-header ( filename -- header )
    "200 Document follows" swap mime-type response ;

: serve-file ( filename -- )
    dup file-header print <filebr> "stdio" get fcopy ;

!!! Serving directories.
: file>html ( filename -- ... )
    "<li><a href=\"" swap
    !dup directory? [ "/" cat2 ] when
    chars>entities
    "\">" over "</a></li>" ;

: directory>html ( directory -- html )
    directory [ file>html ] map cat ;

: list-directory ( directory -- )
    serving-html
    [
        "<html><head><title>" swap
        "</title></head><body><h1>" over
        "</h1><ul>" over
        directory>html
        "</ul></body></html>"
    ] cons expand cat write ;

: serve-directory ( directory -- )
    dup "/index.html" cat2 dup exists? [
        nip serve-file
    ] [
        drop list-directory
    ] ifte ;

!!! Serving objects.
: serve-static ( filename -- )
    dup directory? [
        serve-directory
    ] [
        serve-file
    ] ifte ;

: serve-script ( argument filename -- )
    <namespace> [ swap "argument" set run-file ] bind ;

: parse-object-name ( filename -- argument filename )
    dup [
        dup #"(.*?)\?(.*)" groups dup [ nip call ] when swap
    ] [
        drop f "/"
    ] ifte ;

: file-responder ( filename -- )
    "doc-root" get [
        parse-object-name "doc-root" get swap cat2
        dup exists? [
            dup file-extension "lhtml" = [
                serve-script
            ] [
                nip serve-static
            ] ifte
        ] [
            2drop "404 not found" httpd-error
        ] ifte
    ] [
        drop "404 doc-root not set" httpd-error
    ] ifte ;
