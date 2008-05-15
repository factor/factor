! Copyright (C) 2004, 2008 Slava Pestov, Ivan Tikhonov. 
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings generic kernel math
namespaces threads sequences byte-arrays io.nonblocking
io.binary io.unix.backend io.streams.duplex io.sockets.impl
io.backend io.nonblocking io.files io.files.private
io.encodings.utf8 math.parser continuations libc combinators
system accessors qualified destructors unix ;

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

TUPLE: connect-task < output-task ;

: <connect-task> ( port continuation -- task )
    connect-task <io-task> ;

GENERIC: (wait-to-connect) ( port handle -- ? )

M: integer (wait-to-connect)
    f 0 write 0 < [ defer-error ] [ drop t ] if ;

M: connect-task do-io-task
    port>> dup handle>> (wait-to-connect) ;

M: object wait-to-connect ( client-out fd -- )
    drop
    [ <connect-task> add-io-task ] with-port-continuation
    pending-error ;

M: object ((client)) ( addrspec -- fd )
    [ protocol-family SOCK_STREAM socket-fd ] [ make-sockaddr/size ] bi
    [ 2drop ] [ connect ] 3bi
    zero? err_no EINPROGRESS = or
    [ dup init-client-socket ] [ (io-error) ] if ;

! Server sockets - TCP and Unix domain
: init-server-socket ( fd -- )
    SOL_SOCKET SO_REUSEADDR sockopt ;

TUPLE: accept-task < input-task ;

: <accept-task> ( port continuation  -- task )
    accept-task <io-task> ;

: accept-sockaddr ( port -- fd sockaddr )
    [ handle>> ] [ addr>> sockaddr-type ] bi
    dup <c-object> [ swap heap-size <int> accept ] keep ; inline

: do-accept ( port fd sockaddr -- )
    swapd over addr>> parse-sockaddr >>client-addr (>>client) ;

M: accept-task do-io-task
    io-task-port dup accept-sockaddr
    over 0 >= [ do-accept t ] [ 2drop defer-error ] if ;

: wait-to-accept ( server -- )
    [ <accept-task> add-io-task ] with-port-continuation drop ;

: server-socket-fd ( addrspec type -- fd )
    >r dup protocol-family r> socket-fd
    dup init-server-socket
    dup rot make-sockaddr/size bind
    zero? [ dup close-file (io-error) ] unless ;

M: unix (server) ( addrspec -- handle )
    [
        SOCK_STREAM server-socket-fd
        dup 10 listen io-error
    ] with-destructors ;

M: unix (accept) ( server -- addrspec handle )
    #! Wait for a client connection.
    check-server-port
    [ wait-to-accept ]
    [ pending-error ]
    [ [ client-addr>> ] [ client>> ] bi ] tri ;

! Datagram sockets - UDP and Unix domain
M: unix <datagram>
    [
        [ SOCK_DGRAM server-socket-fd ] keep <datagram-port>
    ] with-destructors ;

SYMBOL: receive-buffer

: packet-size 65536 ; inline

packet-size <byte-array> receive-buffer set-global

: setup-receive ( port -- s buffer len flags from fromlen )
    [ handle>> ] [ addr>> sockaddr-type ] bi
    [ <c-object> ] [ heap-size <int> ] bi
    >r >r receive-buffer get-global packet-size 0 r> r> ;

: do-receive ( s buffer len flags from fromlen -- sockaddr data )
    over >r recvfrom r>
    over -1 = [
        2drop f f
    ] [
        receive-buffer get-global
        rot head
    ] if ;

TUPLE: receive-task < input-task ;

: <receive-task> ( stream continuation  -- task )
    receive-task <io-task> ;

M: receive-task do-io-task
    io-task-port
    dup setup-receive do-receive dup [
        pick set-datagram-port-packet
        over datagram-port-addr parse-sockaddr
        swap set-datagram-port-packet-addr
        t
    ] [
        2drop defer-error
    ] if ;

: wait-receive ( stream -- )
    [ <receive-task> add-io-task ] with-port-continuation drop ;

M: unix receive ( datagram -- packet addrspec )
    check-datagram-port
    [ wait-receive ]
    [ pending-error ]
    [ [ packet>> ] [ packet-addr>> ] bi ] tri ;

: do-send ( socket data sockaddr len -- n )
    >r >r dup length 0 r> r> sendto ;

TUPLE: send-task < output-task packet sockaddr len ;

: <send-task> ( packet sockaddr len stream continuation -- task )
    send-task <io-task> [
        {
            set-send-task-packet
            set-send-task-sockaddr
            set-send-task-len
        } set-slots
    ] keep ;

M: send-task do-io-task
    [ io-task-port port-handle ] keep
    [ send-task-packet ] keep
    [ send-task-sockaddr ] keep
    [ send-task-len do-send ] keep
    swap 0 < [ io-task-port defer-error ] [ drop t ] if ;

: wait-send ( packet sockaddr len stream -- )
    [ <send-task> add-io-task ] with-port-continuation
    2drop 2drop ;

M: unix send ( packet addrspec datagram -- )
    check-datagram-send
    [ >r make-sockaddr/size r> wait-send ] keep
    pending-error ;

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
