! Copyright (C) 2010 Brennan Cheung.
! See https://factorcode.org/license.txt for BSD license.

! This version of the FastCGI library only supports single connections.
! As opposed to multiplexing multiple requests across a single
! connection.
!
! It also expects the following FastCGI parameters to be present:
!     * REQUEST_METHOD
!     * REQUEST_URI
!
! The following are recommended:
!     * HTTP_USER_AGENT
!     * REMOTE_ADDR

USING: accessors alien.enums alien.syntax assocs combinators
combinators.smart endian formatting http http.server
http.server.responses io io.directories
io.encodings.binary io.files io.servers io.sockets
io.streams.byte-array kernel locals math namespaces pack
prettyprint sequences sequences.deep strings threads
urls.encoding ;

IN: fastcgi

SYMBOL: fcgi-server
SYMBOL: fcgi-role
SYMBOL: fcgi-flags
SYMBOL: fcgi-params
SYMBOL: fcgi-request
SYMBOL: stdin-data

CONSTANT: fcgi-version 1
CONSTANT: socket-path "/chroot/web/var/run/factor.sock"

TUPLE: fcgi-header version type request-id content-length
    padding-length reserved ;


ENUM: fcgi-header-types
    { FCGI_BEGIN_REQUEST 1 }
    FCGI_ABORT_REQUEST
    FCGI_END_REQUEST
    FCGI_PARAMS
    FCGI_STDIN
    FCGI_STDOUT
    FCGI_STDERR
    FCGI_DATA
    FCGI_GET_VALUES
    FCGI_GET_VALUES_RESULT
    FCGI_UNKNOWN_TYPE
    { FCGI_MAXTYPE 11 } ;

ENUM: fcgi-roles
    { FCGI_RESPONDER 1 }
    FCGI_AUTHORIZER
    FCGI_FILTER ;

ENUM: fcgi-protocol-status
    { FCGI_REQUEST_COMPLETE 0 }
    FCGI_CANT_MAX_CONN
    FCGI_OVERLOADED
    FCGI_UNKNOWN_ROLE ;

:: debug-print ( print-quot -- )
    [ print-quot call flush ] with-global ; inline

! read either a 1 byte or 4 byte big endian integer
: read-var-int ( -- n/f )
    read1 [
        dup 7 bit?
        [ 127 bitand 3 read swap suffix be> ] when
    ] [ f ] if* ;

:: store-key-value-param ( key value -- )
    request tget value key set-header drop ;

: read-params ( -- )
    [
        read-var-int read-var-int 2dup and
        [
            [ read >string ] bi@
            store-key-value-param
            t
        ] [ 2drop f ] if
    ] loop ;

: make-local-socket ( socket-path -- socket )
    [ ?delete-file ] keep <local> ;

: get-header ( -- header )
    "CCSSCC" read-packed-be
    [ fcgi-header boa ] input<sequence
    dup type>> fcgi-header-types number>enum >>type ;

: get-content-data ( header -- content )
    dup
    [ content-length>> ]
    [ padding-length>> ] bi or 0 > ! because 0 read blocks
    [
        [ content-length>> read ]
        [ padding-length>> read drop ] bi
    ] [ drop f ] if ;

: begin-request-body ( seq -- )
    binary [ "SCCCCCC" read-packed-be ] with-byte-reader
    first2 fcgi-flags tset fcgi-roles
    number>enum fcgi-role tset ;

: process-begin-request ( header -- )
    get-content-data begin-request-body ;

: process-params ( header -- )
    get-content-data binary [ read-params ] with-byte-reader ;

:: make-response-packet ( content -- seq )
    [
        fcgi-version             ! version
        FCGI_STDOUT enum>number  ! type
        1                        ! request id
        content length           ! content length
        0                        ! padding length
        0                        ! reserved
    ] output>array
    "CCSSCC" pack-be content append ;

:: make-end-request-body ( app-status protocol-status -- seq )
    [ app-status protocol-status 0 0 0 ] output>array
    "ICCCC" pack-be ;

: make-end-request ( -- seq )
    [
        fcgi-version                   ! version
        FCGI_END_REQUEST enum>number   ! type
        1                              ! request id
        8                              ! content length (always 8 for end-request-body)
        0                              ! padding length
        0                              ! reserved
        0 0 make-end-request-body
    ] output>array flatten ;

: write-response ( content -- )
    make-response-packet write make-end-request write ;

:: append-stdin-data ( str -- )
    stdin-data [ str append ] tchange ;

! process a header and determine whether we are
! expecting more input
: dispatch-by-header ( header -- ? )
    dup type>>
    {
        { FCGI_BEGIN_REQUEST [ process-begin-request t ] }
        { FCGI_PARAMS [ process-params t ] }
        { FCGI_STDIN [ get-content-data dup append-stdin-data length 0 > ] }  ! keep going until STDIN empty
        { FCGI_DATA [ [ "FCGI_DATA ------------------\n" print ] debug-print get-content-data [ >string . ] debug-print f ] }
        [ [ "unkown packet type" print ] debug-print drop [ . ] debug-print f ]
    } case ;

: make-new-request ( -- )
    <request> request tset ;

: parse-packets ( -- )
    [ get-header dispatch-by-header ] loop ;

: post? ( -- ? ) request tget method>> "POST" = ;

:: handle-post-data* ( post-data data params -- )
    post-data data >>data params >>params
    request tget swap >>post-data drop ;

: handle-post-data ( -- )
    post? [
        request tget dup "CONTENT_TYPE" header
        <post-data> [ >>post-data ] keep nip
        stdin-data tget >string dup query>assoc
        handle-post-data*
    ] when ;

: prepare-request ( -- )
    request tget
    dup "REQUEST_METHOD" header >>method
    dup "REQUEST_URI" header >>url
    handle-post-data
    [ . ] debug-print ;

: fcgi-handler ( -- )
    make-new-request parse-packets
    prepare-request
    "/path" main-responder get call-responder*
    [ content-type>> "\n\n" append ] [ body>> ] bi append write-response ;

: <fastcgi-server> ( addr -- server )
    binary
    <threaded-server>
      swap >>insecure
      "fastcgi-server" >>name
      [ fcgi-handler ] >>handler ;

: test-output ( -- str )
    "<pre>"
    request tget header>> [ "%s => %s\n" sprintf ] { }
    assoc>map concat append
    "</pre>" append ;

TUPLE: test-responder ;
C: <test-responder> test-responder
M: test-responder call-responder* 2drop test-output <html-content> ;

: do-it ( -- )
    <test-responder> main-responder set
    socket-path [ ?delete-file ] keep
    make-local-socket <fastcgi-server> dup fcgi-server set
    start-server drop ;
