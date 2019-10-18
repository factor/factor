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
] @httpd-extensions

: group1 ( string regex -- string )
    groups dup [ car ] when ;

: httpd-response ( msg content-type -- response )
    [ "HTTP/1.0 " swap "\nContent-Type: " ] dip "\n" cat5 ;

: httpd-file-header ( filename -- header )
    "200 Document follows" swap httpd-filetype httpd-response ;

: httpd-serve-file ( stream filename -- )
    2dup httpd-file-header swap fwriteln <filebr> swap fcopy ;

: httpd-log-error ( error -- )
    "Error: " swap cat2 print ;

: httpd-error-body ( error -- body )
    "\n<html><body><h1>" swap "</h1></body></html>" cat3 ;

: httpd-error ( stream error -- )
    dup httpd-log-error
    [ "text/html" httpd-response ] [ httpd-error-body ] cleave
    cat2
    swap fwriteln ;

: httpd-response-write ( stream msg content-type -- )
    httpd-response swap fwriteln ;

: httpd-file-extension ( filename -- extension )
    ".*\\.(.*)" group1 ;

: httpd-filetype ( filename -- mime-type )
    httpd-file-extension $httpd-extensions assoc
    [ "text/plain" ] unless* ;

: httpd-url>path ( uri -- path )
    dup "http://.*?(/.*)" group1 dup [
        nip
    ] [
        drop
    ] ifte
    $httpd-doc-root swap cat2 ;

: httpd-file>html ( filename -- ... )
    "<li><a href=\"" swap
    !dup directory? [ "/" cat2 ] when
    chars>entities
    "\">" over "</a></li>" ;

: httpd-directory>html ( directory -- html )
    directory [ httpd-file>html ] map cat ;

: httpd-directory-header ( stream directory -- )
    "200 Document follows" "text/html" httpd-response fwriteln ;

: httpd-list-directory ( stream directory -- )
    2dup httpd-directory-header [
        "<html><head><title>" swap
        "</title></head><body><h1>" over
        "</h1><ul>" over
        httpd-directory>html
        "</ul></body></html>"
    ] cons expand cat swap fwrite ;

: httpd-serve-directory ( stream directory -- )
    dup "/index.html" cat2 dup exists? [
        nip httpd-serve-file
    ] [
        drop httpd-list-directory
    ] ifte ;

: httpd-serve-script ( stream argument filename -- )
    <namespace> [ [ @argument @stdio ] dip runFile ] bind ;

: httpd-parse-object-name ( filename -- argument filename )
    dup "(.*?)\\?(.*)" groups dup [ nip call ] when swap ;

: httpd-serve-static ( stream filename -- )
    dup exists? [
        dup directory? [
            httpd-serve-directory
        ] [
            httpd-serve-file
        ] ifte
    ] [
        drop "404 Not Found" httpd-error
    ] ifte ;

: httpd-serve-object ( stream argument filename -- )
    dup ".*\\.lhtml" re-matches [
        httpd-serve-script
    ] [
        nip httpd-serve-static
    ] ifte ;

: httpd-serve-log ( filename -- )
    "Serving " swap cat2 print ;

: httpd-get-request ( stream url -- )
    httpd-url>path dup httpd-serve-log
    httpd-parse-object-name httpd-serve-object ;

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

: httpd-request ( stream request -- )
    httpd-get-secure-path dup [
        httpd-get-request
    ] [
        drop "400 Bad request" httpd-error
    ] ifte ;

: httpd-client-log ( socket -- )
    "Accepted connection from " write [ $socket ] bind . ;

: httpd-client ( socket -- )
    dup httpd-client-log
    dup freadln [ httpd-request ] when* ;

: httpd-loop ( server -- )
    [
        $httpd-quit not
    ] [
        dup accept dup httpd-client fclose
    ] while ;

: httpd ( port docroot -- )
    @httpd-doc-root <server> httpd-loop ;
