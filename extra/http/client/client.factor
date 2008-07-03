! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel math math.parser namespaces
sequences io io.sockets io.streams.string io.files io.timeouts
strings splitting calendar continuations accessors vectors
math.order hashtables byte-arrays prettyprint
io.encodings
io.encodings.string
io.encodings.ascii
io.encodings.8-bit
io.encodings.binary
io.streams.duplex
fry debugger summary ascii urls present
http http.parsers ;
IN: http.client

: write-request-line ( request -- request )
    dup
    [ method>> write bl ]
    [ url>> relative-url present write bl ]
    [ "HTTP/" write version>> write crlf ]
    tri ;

: url-host ( url -- string )
    [ host>> ] [ port>> ] bi dup "http" protocol-port =
    [ drop ] [ ":" swap number>string 3append ] if ;

: write-request-header ( request -- request )
    dup header>> >hashtable
    over url>> host>> [ over url>> url-host "host" pick set-at ] when
    over post-data>> [
        [ raw>> length "content-length" pick set-at ]
        [ content-type>> "content-type" pick set-at ]
        bi
    ] when*
    over cookies>> f like [ unparse-cookie "cookie" pick set-at ] when*
    write-header ;

GENERIC: >post-data ( object -- post-data )

M: post-data >post-data ;

M: string >post-data "application/octet-stream" <post-data> ;

M: byte-array >post-data "application/octet-stream" <post-data> ;

M: assoc >post-data assoc>query "application/x-www-form-urlencoded" <post-data> ;

M: f >post-data ;

: unparse-post-data ( request -- request )
    [ >post-data ] change-post-data ;

: write-post-data ( request -- request )
    dup method>> "POST" = [ dup post-data>> raw>> write ] when ; 

: write-request ( request -- )
    unparse-post-data
    write-request-line
    write-request-header
    write-post-data
    flush
    drop ;

: read-response-line ( response -- response )
    read-crlf parse-response-line first3
    [ >>version ] [ >>code ] [ >>message ] tri* ;

: read-response-header ( response -- response )
    read-header >>header
    dup "set-cookie" header parse-set-cookie >>cookies
    dup "content-type" header [
        parse-content-type
        [ >>content-type ]
        [ >>content-charset ] bi*
    ] when* ;

: read-response ( -- response )
    <response>
    read-response-line
    read-response-header ;

: max-redirects 10 ;

ERROR: too-many-redirects ;

M: too-many-redirects summary
    drop
    [ "Redirection limit of " % max-redirects # " exceeded" % ] "" make ;

DEFER: (http-request)

<PRIVATE

SYMBOL: redirects

: redirect-url ( request url -- request )
    '[ , >url ensure-port derive-url ensure-port ] change-url ;

: do-redirect ( response data -- response data )
    over code>> 300 399 between? [
        drop
        redirects inc
        redirects get max-redirects < [
            request get
            swap "location" header redirect-url
            "GET" >>method (http-request)
        ] [
            too-many-redirects
        ] if
    ] when ;

PRIVATE>

: read-chunk-size ( -- n )
    read-crlf ";" split1 drop [ blank? ] right-trim
    hex> [ "Bad chunk size" throw ] unless* ;

: read-chunks ( -- )
    read-chunk-size dup zero?
    [ drop ] [ read % read-crlf B{ } assert= read-chunks ] if ;

: read-response-body ( response -- response data )
    dup "transfer-encoding" header "chunked" = [
        binary decode-input
        [ read-chunks ] B{ } make
        over content-charset>> decode
    ] [
        dup content-charset>> decode-input
        input-stream get contents
    ] if ;

: (http-request) ( request -- response data )
    dup request [
        dup url>> url-addr ascii [
            1 minutes timeouts
            write-request
            read-response
            read-response-body
        ] with-client
        do-redirect
    ] with-variable ;

: success? ( code -- ? ) 200 = ;

ERROR: download-failed response body ;

M: download-failed error.
    "HTTP download failed:" print nl
    [ response>> . nl ] [ body>> write ] bi ;

: check-response ( response data -- response data )
    over code>> success? [ download-failed ] unless ;

: http-request ( request -- response data )
    (http-request) check-response ;

: <get-request> ( url -- request )
    <request>
        "GET" >>method
        swap >url ensure-port >>url ;

: http-get ( url -- response data )
    <get-request> http-request ;

: download-name ( url -- name )
    present file-name "?" split1 drop "/" ?tail drop ;

: download-to ( url file -- )
    #! Downloads the contents of a URL to a file.
    swap http-get
    [ content-charset>> ] [ '[ , write ] ] bi*
    with-file-writer ;

: download ( url -- )
    dup download-name download-to ;

: <post-request> ( post-data url -- request )
    <request>
        "POST" >>method
        swap >url ensure-port >>url
        swap >>post-data ;

: http-post ( post-data url -- response data )
    <post-request> http-request ;
