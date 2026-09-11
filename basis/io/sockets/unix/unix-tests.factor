USING: accessors alien.strings calendar continuations destructors
io.backend io.backend.unix io.encodings io.encodings.binary
io.encodings.utf8 io.files io.files.unix io.pathnames io.ports
io.sockets io.sockets.private io.timeouts kernel libc locals math
namespaces sequences sets strings tools.annotations tools.test unix.ffi ;
FROM: io.sockets => accept ;
IN: io.sockets.unix

SYMBOL: freed-address-lists
TUPLE: freed-address-counter n ;

: count-freed-address-list ( addrinfo -- addrinfo )
    freed-address-lists get [ [ 1 + ] change-n drop ] when* ;

! getaddrinfo transfers a native allocation to the caller. Release it
! even when converting the returned addresses to Factor objects fails.
{ 1 } [
    0 freed-address-counter boa freed-address-lists [
        [
            \ freeaddrinfo [ [ count-freed-address-list ] swap compose ] annotate
            \ parse-addrinfo-list [ drop [ drop "address conversion failed" throw ] ] annotate
            [ "localhost" resolve-host drop ]
            [ "address conversion failed" = ] must-fail-with
            freed-address-lists get n>>
        ] [
            \ parse-addrinfo-list reset
            \ freeaddrinfo reset
        ] finally
    ] with-variable
] unit-test

! A zero-byte datagram is a message, not a would-block result.
{ B{ } } [
    "127.0.0.1" 0 <inet4> <datagram> [| port |
        1 seconds port set-timeout
        B{ } port addr>> port send
        B{ 42 } port addr>> port send
        port receive drop
    ] with-disposal
] unit-test

SINGLETON: failing-connectionless-backend

M: failing-connectionless-backend (datagram)
    global [ (datagram) ] with-variables ;

M: failing-connectionless-backend (raw)
    ! A UDP handle is sufficient to exercise raw-port construction failure.
    global [ (datagram) ] with-variables ;

M: failing-connectionless-backend (broadcast)
    drop "broadcast option failed" throw ;

{ t } [
    disposables get cardinality
    [
        failing-connectionless-backend io-backend [
            "127.0.0.1" 0 <inet4> <broadcast> dispose
        ] with-variable
    ] [ "broadcast option failed" = ] must-fail-with
    disposables get cardinality =
] unit-test

! Preserve recvfrom's error instead of waiting on an invalid socket.
[
    [| path |
        path open-read <fd> init-fd datagram-port <port>
        "127.0.0.1" 0 <inet4> >>addr [ receive 2drop ] with-disposal
    ] with-test-file
] [ dup libc-error? [ errno>> ENOTSOCK = ] [ drop f ] if ] must-fail-with

{ t } [
    [
        EMFILE set-errno
        EAI_SYSTEM addrinfo-error-string
        EMFILE strerror swap subseq?
    ] preserve-errno
] unit-test

SINGLETON: failing-socket-encoding

M: failing-socket-encoding <encoder>
    2drop "socket encoder failed" throw ;

: open-socket-fds ( -- n )
    disposables get members [ fd? ] count ;

TUPLE: failing-server-address address ;

M: failing-server-address (server) address>> (server) ;

M: failing-server-address (get-local-address)
    2drop "socket address failed" throw ;

{ t } [
    disposables get cardinality
    [
        "127.0.0.1" 0 <inet4> failing-server-address boa
        binary <server> dispose
    ] [ "socket address failed" = ] must-fail-with
    disposables get cardinality =
] unit-test

TUPLE: failing-datagram-address < inet4 ;

M: failing-datagram-address (get-local-address)
    2drop "datagram address failed" throw ;

{ t } [
    disposables get cardinality
    [ "127.0.0.1" 0 failing-datagram-address boa <datagram> dispose ]
    [ "datagram address failed" = ] must-fail-with
    disposables get cardinality =
] unit-test

{ t } [
    disposables get cardinality
    [
        failing-connectionless-backend io-backend [
            "127.0.0.1" 0 failing-datagram-address boa <raw> dispose
        ] with-variable
    ] [ "datagram address failed" = ] must-fail-with
    disposables get cardinality =
] unit-test

! Failure to wrap connected or accepted sockets must close their fd.
{ t } [
    "127.0.0.1" 0 <inet4> binary <server> [| server |
        open-socket-fds
        [ server addr>> failing-socket-encoding <client> 2drop ]
        [ "socket encoder failed" = ] must-fail-with
        server accept drop dispose
        open-socket-fds =
    ] with-disposal
] unit-test

{ t } [
    "127.0.0.1" 0 <inet4> failing-socket-encoding <server> [| server |
        server addr>> binary <client> drop [
            drop open-socket-fds
            [ server accept 2drop ]
            [ "socket encoder failed" = ] must-fail-with
            open-socket-fds =
        ] with-disposal
    ] with-disposal
] unit-test

! sockaddr-un has a fixed-size byte array, including the terminating NUL.
{ t t } [
    "/factor-socket" <local> make-sockaddr path>>
    [ length max-un-path = ]
    [ utf8 alien>string "/factor-socket" = ] bi
] unit-test

{ t } [
    max-un-path 2 - CHAR: a <string> "/" prepend
    dup <local> make-sockaddr path>> utf8 alien>string =
] unit-test

[
    max-un-path 1 - CHAR: a <string> "/" prepend
    <local> make-sockaddr drop
] [ "Path too long" = ] must-fail-with

! Check the encoded byte length: a multibyte path can fit by character
! count while overflowing the native socket address field.
[
    max-un-path 2 /i CHAR: é <string> "/" prepend
    <local> make-sockaddr drop
] [ "Path too long" = ] must-fail-with

[
    ! Ask the OS for an ephemeral port, then close the listener before
    ! connecting. A fixed port could already have a service listening.
    "127.0.0.1" 0 <inet4> binary <server>
    [ addr>> ] with-disposal
    binary [ ] with-client
] [
    message>> "Connection refused" =
] must-fail-with
