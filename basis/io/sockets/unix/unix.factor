! Copyright (C) 2004, 2008 Slava Pestov, Ivan Tikhonov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.c-types alien.data alien.strings
byte-arrays classes.struct combinators destructors
io.backend.unix io.encodings.ascii io.encodings.utf8 io.files
io.pathnames io.ports io.sockets io.sockets.private kernel libc
locals math namespaces sequences system unix unix.ffi vocabs ;

IN: io.sockets.unix

: socket-fd ( domain type protocol -- fd )
    socket dup io-error <fd> init-fd |dispose ;

: get-socket-option ( fd level opt -- val )
    [ handle-fd ] 2dip -1 int <ref> [
        dup byte-length int <ref> getsockopt io-error
    ] keep int deref ;

: set-socket-option ( fd level opt -- )
    [ handle-fd ] 2dip 1 int <ref> dup byte-length setsockopt io-error ;

M: unix addrinfo-error-string
    gai_strerror ;

M: unix sockaddr-of-family
    {
        { AF_INET [ sockaddr-in memory>struct ] }
        { AF_INET6 [ sockaddr-in6 memory>struct ] }
        { AF_UNIX [ sockaddr-un memory>struct ] }
        [ 2drop f ]
    } case ;

M: unix addrspec-of-family
    {
        { AF_INET [ T{ ipv4 } ] }
        { AF_INET6 [ T{ ipv6 } ] }
        { AF_UNIX [ T{ local } ] }
        [ drop f ]
    } case ;

! Client sockets - TCP and Unix domain
M: object (get-local-address)
    [ handle-fd ] dip empty-sockaddr/size int <ref>
    [ getsockname io-error ] keepd ;

M: object (get-remote-address)
    [ handle-fd ] dip empty-sockaddr/size int <ref>
    [ getpeername io-error ] keepd ;

: init-client-socket ( fd -- )
    SOL_SOCKET SO_OOBINLINE set-socket-option ;

: wait-to-connect ( port -- )
    dup +output+ wait-for-port
    dup handle>> SOL_SOCKET SO_ERROR get-socket-option
    [ drop ] [ (throw-errno) ] if-zero ; inline

M: object establish-connection
    2dup
    [ handle>> handle-fd ] [ make-sockaddr/size ] bi*
    connect 0 = [ 2drop ] [
        errno {
            { EINTR [ establish-connection ] }
            { EINPROGRESS [ drop wait-to-connect ] }
            [ (throw-errno) ]
        } case
    ] if ;

: ?bind-client ( socket -- )
    bind-local-address get [
        [ fd>> ] dip make-sockaddr/size
        [ bind ] unix-system-call drop
    ] [
        drop
    ] if* ; inline

M: object remote>handle
    [ protocol-family SOCK_STREAM ] [ protocol ] bi socket-fd
    [ init-client-socket ] [ ?bind-client ] [ ] tri ;

! Server sockets - TCP and Unix domain
: init-server-socket ( fd -- )
    SOL_SOCKET SO_REUSEADDR set-socket-option ;

: server-socket-fd ( addrspec type -- fd )
    [ dup protocol-family ] dip pick protocol socket-fd
    [ init-server-socket ] keep
    [ handle-fd swap make-sockaddr/size [ bind ] unix-system-call drop ] keep ;

M: object (server)
    [
        SOCK_STREAM server-socket-fd
        dup handle-fd 128 [ listen ] unix-system-call drop
    ] with-destructors ;

: do-accept ( server addrspec -- fd sockaddr )
    [ handle>> handle-fd ] [ empty-sockaddr/size int <ref> ] bi*
    [ unix.ffi:accept ] keepd ; inline

M: object (accept)
    2dup do-accept over 0 >= [
        [ 2nip <fd> init-fd ] dip
    ] [
        errno {
            { EINTR [ 2drop (accept) ] }
            { EAGAIN [
                2drop
                [ drop +input+ wait-for-port ]
                [ (accept) ]
                2bi
            ] }
            [ (throw-errno) ]
        } case
    ] if ;

! Datagram sockets - UDP and Unix domain
M: unix (datagram)
    [ SOCK_DGRAM server-socket-fd ] with-destructors ;

M: unix (raw)
    [ SOCK_RAW server-socket-fd ] with-destructors ;

M: unix (broadcast)
    dup handle>> SOL_SOCKET SO_BROADCAST set-socket-option ;

:: do-receive ( n buf port -- count sockaddr )
    port addr>> empty-sockaddr/size :> ( sockaddr len )
    port handle>> handle-fd ! s
    buf ! buf
    n ! nbytes
    0 ! flags
    sockaddr ! from
    len int <ref> ! fromlen
    recvfrom sockaddr ; inline

: (receive-loop) ( n buf datagram -- count sockaddr )
    3dup do-receive over 0 > [ 3nipd ] [
        2drop [ +input+ wait-for-port ] [ (receive-loop) ] bi
    ] if ; inline recursive

M: unix (receive-unsafe)
    (receive-loop) ;

:: do-send ( packet sockaddr len socket datagram -- )
    socket handle-fd packet dup length 0 sockaddr len sendto
    0 < [
        errno {
            { EINTR [
                packet sockaddr len socket datagram do-send
            ] }
            { EAGAIN [
                datagram +output+ wait-for-port
                packet sockaddr len socket datagram do-send
            ] }
            [ (throw-errno) ]
        } case
    ] when ; inline recursive

M: unix (send)
    [ make-sockaddr/size-outgoing ] [ [ handle>> ] keep ] bi* do-send ;

! Unix domain sockets
M: local protocol-family drop PF_UNIX ;

M: local sockaddr-size drop sockaddr-un heap-size ;

M: local empty-sockaddr drop sockaddr-un new ;

M: local make-sockaddr
    path>> absolute-path
    dup length 1 + max-un-path > [ "Path too long" throw ] when
    sockaddr-un new
        AF_UNIX >>family
        swap utf8 string>alien >>path ;

M: local parse-sockaddr
    drop
    path>> utf8 alien>string <local> ;

M: unix host-name
    256 [ <byte-array> dup ] keep gethostname io-error
    ascii alien>string ;

os linux? [ "io.sockets.unix.linux" require ] when
