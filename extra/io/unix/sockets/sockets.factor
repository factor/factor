! Copyright (C) 2004, 2008 Slava Pestov, Ivan Tikhonov. 
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings generic kernel math
namespaces threads sequences byte-arrays io.ports
io.binary io.unix.backend io.streams.duplex
io.backend io.ports io.files io.files.private
io.encodings.utf8 math.parser continuations libc combinators
system accessors qualified destructors unix locals ;

EXCLUDE: io => read write close ;
EXCLUDE: io.sockets => accept ;

IN: io.unix.sockets

: socket-fd ( domain type -- socket )
    0 socket
    dup io-error
    dup close-later
    dup init-handle ;

: sockopt ( fd level opt -- )
    1 <int> "int" heap-size setsockopt io-error ;

M: unix addrinfo-error ( n -- )
    dup zero? [ drop ] [ gai_strerror throw ] if ;

! Client sockets - TCP and Unix domain
: init-client-socket ( fd -- )
    SOL_SOCKET SO_OOBINLINE sockopt ;

: get-socket-name ( fd addrspec -- sockaddr )
    empty-sockaddr/size [ getsockname io-error ] 2keep drop ;

M: integer (wait-to-connect)
    >r >r +output+ wait-for-port r> r> get-socket-name ;

M: object ((client)) ( addrspec -- fd )
    [ protocol-family SOCK_STREAM socket-fd ] [ make-sockaddr/size ] bi
    [ 2drop ] [ connect ] 3bi
    zero? err_no EINPROGRESS = or
    [ dup init-client-socket ] [ (io-error) ] if ;

! Server sockets - TCP and Unix domain
: init-server-socket ( fd -- )
    SOL_SOCKET SO_REUSEADDR sockopt ;

: server-socket-fd ( addrspec type -- fd )
    >r dup protocol-family r> socket-fd
    dup init-server-socket
    dup rot make-sockaddr/size bind io-error ;

M: object (server) ( addrspec -- handle sockaddr )
    [
        [
            SOCK_STREAM server-socket-fd
            dup 10 listen io-error
            dup
        ] keep
        get-socket-name
    ] with-destructors ;

: do-accept ( server -- fd sockaddr )
    [ handle>> ] [ addr>> empty-sockaddr/size ] bi
    [ accept ] 2keep drop ; inline

M: unix (accept) ( server -- fd sockaddr )
    dup do-accept
    {
        { [ over 0 >= ] [ rot drop ] }
        { [ err_no EINTR = ] [ 2drop do-accept ] }
        { [ err_no EAGAIN = ] [
            2drop
            [ +input+ wait-for-port ]
            [ do-accept ] bi
        ] }
        [ (io-error) ]
    } cond ;

! Datagram sockets - UDP and Unix domain
M: unix (datagram)
    [ SOCK_DGRAM server-socket-fd ] with-destructors ;

SYMBOL: receive-buffer

: packet-size 65536 ; inline

packet-size <byte-array> receive-buffer set-global

:: do-receive ( port -- packet sockaddr )
    port addr>> empty-sockaddr/size [| sockaddr len |
        port handle>> ! s
        receive-buffer get-global ! buf
        packet-size ! nbytes
        0 ! flags
        sockaddr ! from
        len ! fromlen
        recvfrom dup 0 >= [
            receive-buffer get-global swap head sockaddr
        ] [
            drop f f
        ] if
    ] call ;

M: unix (receive) ( datagram -- packet sockaddr )
    dup do-receive dup [ rot drop ] [
        2drop [ +input+ wait-for-port ] [ (receive) ] bi
    ] if ;

:: do-send ( packet sockaddr len socket datagram -- )
    socket packet dup length 0 sockaddr len sendto
    0 < [
        err_no EINTR = [
            packet sockaddr len socket datagram do-send
        ] [
            err_no EAGAIN = [
                datagram +output+ wait-for-port
                packet sockaddr len socket datagram do-send
            ] [
                (io-error)
            ] if
        ] if
    ] when ;

M: unix (send) ( packet addrspec datagram -- )
    [ make-sockaddr/size ] [ [ handle>> ] keep ] bi* do-send ;

! Unix domain sockets
M: local protocol-family drop PF_UNIX ;

M: local sockaddr-type drop "sockaddr-un" c-type ;

M: local make-sockaddr
    path>> (normalize-path)
    dup length 1 + max-un-path > [ "Path too long" throw ] when
    "sockaddr-un" <c-object>
    AF_UNIX over set-sockaddr-un-family
    dup sockaddr-un-path rot utf8 string>alien dup length memcpy ;

M: local parse-sockaddr
    drop
    sockaddr-un-path utf8 alien>string <local> ;
