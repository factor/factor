!:folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003 Slava Pestov.
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
! - make httpdFiletype generic, specify file types in a list of comma pairs
! - basic authentication, using httpdAuth function from a config file
! - when string formatting is added, some code can be simplified
! - use nio to handle multiple requests
! - implement an LSP that does an "apropos" search

: httpdGetPath ( request -- file )
    dup ".*\\.\\.*" re-matches [
        f
    ] [
        dup [ "GET (.*?)( HTTP.*|)" groups dup [ car ] when ] when
    ] ifte ;

: httpdResponse (stream msg contentType --)
    [ "HTTP/1.0 " over fwrite ] 2dip
    [ over fwriteln "Content-type: " over fwriteln ] dip
    swap fwriteln ;

: httpdError (stream error --)
    "Error: " write dup print
    2dup "text/html" httpdResponse
    "\n<html><body><h1>" swap "</h1></body></html>" cat3 swap fwriteln ;

: httpdFiletype (filename -- mime-type)
    [
        [ ".*\.gif"  re-matches ] [ drop "image/gif"                ]
        [ ".*\.png"  re-matches ] [ drop "image/png"                ]
        [ ".*\.html" re-matches ] [ drop "text/html"                ]
        [ ".*\.txt"  re-matches ] [ drop "text/plain"               ]
        [ ".*\.lsd"  re-matches ] [ drop "text/plain"               ]
        [ t ]                     [ drop "application/octet-stream" ]
    ] cond ;

: httpdUriToPath (uri -- path)
    $httpdDocRoot swap
    dup "http://.*?(/.*)" groups [ car ] when*
    cat2 ;

: httpdPathToAbsolute (path -- absolute)
    $httpdDocRoot swap cat2
    "Serving " over cat2 print
    dup directory? [ "/index.html" cat2 ] when ;

: httpdServeFile (stream argument filename --)
    nip
    2dup "200 Document follows" swap httpdFiletype httpdResponse
    [ "" over fwriteln ] dip
    <filebr> swap fcopy ;

: httpdListDirectory (stream directory -- string)
    [ "<html><head><title>" over fwrite ] dip
    2dup swap fwrite
    [ "</title></head><body><h1>" over fwrite ] dip
    2dup swap fwrite
    [ "</h1><ul>" over fwrite ] dip
    directory [
        chars>entities
        dup directory? [ "/" cat2 ] when
        [ "<li><a href=\"" over fwrite ] dip
        2dup swap fwrite
        [ "\">" over fwrite ] dip
        2dup swap fwrite
        [ "</a></li>" over fwrite ] dip
        drop
    ] each
    "</ul></body></html>" swap fwrite ;

: httpdServeDirectory (stream argument directory --)
    dup "/index.html" cat2 dup exists? [
        nip httpdServeFile
    ] [
        drop nip
        over "200 Document follows" "text/plain" httpdResponse
        [ "" over fwriteln ] dip
        httpdListDirectory
    ] ifte ;

: httpdServeScript (stream argument filename --)
    <namespace> [ [ @argument @stdio ] dip runFile ] bind ;

: httpdParseObjectName ( filename -- argument filename )
    dup "(.*?)\\?(.*)" groups dup [ nip push ] when swap ;

: httpdServeObject (stream filename --)
    "Serving " write dup print
    httpdParseObjectName
    dup exists? [
        dup directory? [
            httpdServeDirectory
        ] [
            dup ".*\.lhtml" re-matches [
                httpdServeScript
            ] [
                httpdServeFile
            ] ifte
        ] ifte
    ] [
        2drop "404 Not Found" httpdError
    ] ifte ;

: httpdRequest (stream request --)
    httpdGetPath dup [
        httpdUriToPath httpdServeObject
    ] [
        drop "400 Bad request" httpdError
    ] ifte ;

: httpdClient (socket --)
    "Accepted connection from " write dup [ $socket ] bind .
    [ dup freadln httpdRequest ] [ fclose ] cleave ;

: httpdLoop (server --)
    dup accept httpdClient $httpdQuit [ fclose ] [ httpdLoop ] ifte ;

: httpd (port docroot --)
    @httpdDocRoot <server> httpdLoop ;
