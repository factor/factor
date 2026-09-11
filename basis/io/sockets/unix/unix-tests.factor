USING: accessors alien.strings destructors io.backend.unix
io.encodings io.encodings.binary io.encodings.utf8 io.pathnames
io.sockets io.sockets.private kernel libc locals math namespaces
sequences sets strings tools.test unix.ffi ;
FROM: io.sockets => accept ;
IN: io.sockets.unix

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
