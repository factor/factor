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

! To make this a bit more useful:
! - URL encoding
! - log with date
! - log user agent
! - add a socket timeout
! - if a directory is requested and URL does not end with /, redirect
! - return more header fields, like Content-Length, Last-Modified, and so on
! - HEAD request
! - basic authentication, using httpdAuth function from a config file
! - when string formatting is added, some code can be simplified
! - use nio to handle multiple requests
! - implement an LSP that does an "apropos" search

: httpd-extensions ( -- alist )
    [
        [  "html"   , "text/html"                ]
        [  "txt"    , "text/plain"               ]
                                                 
        [  "gif"    , "image/gif"                ]
        [  "png"    , "image/png"                ]
        [  "jpg"    , "image/jpeg"               ]
        [  "jpeg"   , "image/jpeg"               ]
                    
        [  "jar"    , "application/octet-stream" ]
        [  "zip"    , "application/octet-stream" ]
        [  "tgz"    , "application/octet-stream" ]
        [  "tar.gz" , "application/octet-stream" ]
        [  "gz"     , "application/octet-stream" ]
    ] ;

!!! Support words.
: group1 ( string regex -- string )
    groups dup [ car ] when ;

: httpd-file-extension ( filename -- extension )
    ".*\\.(.*)" group1 ;

: httpd-write ( line -- )
    $client fwrite ;

: httpd-log-error ( error -- )
    "Error: " swap cat2 $log fwriteln ;

: httpd-serve-log ( filename -- )
    "Serving " write $log fwriteln ;

: httpd-client-log ( -- )
    "Accepted connection from " write
    $client [ $socket ] bind . ;

!!! Protocol words.
: httpd-response ( msg content-type -- response )
    [ "HTTP/1.0 " swap "\nContent-Type: " ] dip "\n" cat5 ;

: httpd-response-write ( msg content-type -- )
    httpd-response writeln ;

: httpd-error-body ( error -- body )
    "\n<html><body><h1>" swap "</h1></body></html>" cat3 ;

: httpd-error ( error -- )
    dup httpd-log-error
    [ "text/html" httpd-response ] [ httpd-error-body ] cleave
    cat2
    writeln ;

: httpd-url>path ( uri -- path )
    dup "http://.*?(/.*)" group1 dup [
        nip
    ] [
        drop
    ] ifte
    $httpd-doc-root swap cat2 ;

: httpd-parse-object-name ( filename -- argument filename )
    dup "(.*?)\\?(.*)" groups dup [ nip call ] when swap ;

!!! Serving files.
: httpd-file-header ( filename -- header )
    "200 Document follows" swap httpd-filetype httpd-response ;

: httpd-serve-file ( filename -- )
    dup httpd-file-header writeln <filebr> $client fcopy ;

: httpd-filetype ( filename -- mime-type )
    httpd-file-extension httpd-extensions assoc
    [ "text/plain" ] unless* ;

!!! Serving directories.
: httpd-file>html ( filename -- ... )
    "<li><a href=\"" swap
    !dup directory? [ "/" cat2 ] when
    chars>entities
    "\">" over "</a></li>" ;

: httpd-directory>html ( directory -- html )
    directory [ httpd-file>html ] map cat ;

: httpd-directory-header ( directory -- )
    "200 Document follows" "text/html"
    httpd-response writeln ;

: httpd-list-directory ( directory -- )
    dup httpd-directory-header [
        "<html><head><title>" swap
        "</title></head><body><h1>" over
        "</h1><ul>" over
        httpd-directory>html
        "</ul></body></html>"
    ] cons expand cat write ;

: httpd-serve-directory ( directory -- )
    dup "/index.html" cat2 dup exists? [
        nip httpd-serve-file
    ] [
        drop httpd-list-directory
    ] ifte ;

!!! Serving objects.
: httpd-serve-static ( filename -- )
    dup exists? [
        dup directory? [
            httpd-serve-directory
        ] [
            httpd-serve-file
        ] ifte
    ] [
        drop "404 Not Found" httpd-error
    ] ifte ;

: httpd-serve-script ( argument filename -- )
    <namespace> [ swap @argument run-file ] bind ;

: httpd-serve-object ( argument filename -- )
    dup ".*\\.lhtml" re-matches [
        httpd-serve-script
    ] [
        nip httpd-serve-static
    ] ifte ;

!!! GET request.
: httpd-get-request ( url -- )
    httpd-url>path
    [
        httpd-serve-log
    ] [
        httpd-parse-object-name httpd-serve-object
    ] cleave ;

: httpd-get-path ( request -- file )
    "GET (.*?)( HTTP.*|)" group1 ;

: httpd-get-secure-path ( path -- path )
    dup [
        httpd-get-path dup [
            dup ".*\\.\\.*" re-matches [ drop f ] when
        ] [
            drop f
        ] ifte
    ] [
        drop f
    ] ifte ;

!!! Main loop.
: httpd-request ( request -- )
    httpd-get-secure-path dup [
        httpd-get-request
    ] [
        drop "400 Bad request" httpd-error
    ] ifte ;

: httpd-client ( socket -- )
    <namespace> [
        $stdio @log
        @stdio
        httpd-client-log
        readln [ httpd-request ] when*
    ] bind ;

: httpd-loop ( server -- )
    [
        $httpd-quit not
    ] [
        dup accept dup httpd-client fclose
    ] while ;

!!! Main entry point.
: httpd ( port docroot -- )
    @httpd-doc-root <server> httpd-loop ;
