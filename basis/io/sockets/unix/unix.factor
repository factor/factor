! Copyright (C) 2004, 2008 Slava Pestov, Ivan Tikhonov. 
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings generic kernel math threads
sequences byte-arrays io.binary io.backend.unix io.streams.duplex
io.backend io.pathnames io.files.private io.encodings.utf8 math.parser
continuations libc combinators system accessors destructors unix
locals init ;

EXCLUDE: namespaces => bind ;
EXCLUDE: io => read write ;
EXCLUDE: io.sockets => accept ;

IN: io.sockets.unix

: socket-fd ( domain type -- fd )
    0 socket dup io-error <fd> init-fd |dispose ;

: set-socket-option ( fd level opt -- )
    [ handle-fd ] 2dip 1 <int> "int" heap-size setsockopt io-error ;

M: unix addrinfo-error ( n -- )
    dup zero? [ drop ] [ gai_strerror throw ] if ;

! Client sockets - TCP and Unix domain
M: object (get-local-address) ( handle remote -- sockaddr )
    [ handle-fd ] dip empty-sockaddr/size <int>
    [ getsockname io-error ] 2keep drop ;

M: object (get-remote-address) ( handle local -- sockaddr )
    [ handle-fd ] dip empty-sockaddr/size <int>
    [ getpeername io-error ] 2keep drop ;

: init-client-socket ( fd -- )
    SOL_SOCKET SO_OOBINLINE set-socket-option ;

: wait-to-connect ( port -- )
    dup handle>> handle-fd f 0 write
    {
        { [ 0 = ] [ drop ] }
        { [ errno EAGAIN = ] [ dup +output+ wait-for-port wait-to-connect ] }
        { [ errno EINTR = ] [ wait-to-connect ] }
        [ (io-error) ]
    } cond ;

M: object establish-connection ( client-out remote -- )
    [ drop ] [ [ handle>> handle-fd ] [ make-sockaddr/size ] bi* connect ] 2bi
    {
        { [ 0 = ] [ drop ] }
        { [ errno EINPROGRESS = ] [
            [ +output+ wait-for-port ] [ wait-to-connect ] bi
        ] }
        [ (io-error) ]
    } cond ;

M: object ((client)) ( addrspec -- fd )
    protocol-family SOCK_STREAM socket-fd dup init-client-socket ;

! Server sockets - TCP and Unix domain
: init-server-socket ( fd -- )
    SOL_SOCKET SO_REUSEADDR set-socket-option ;

: server-socket-fd ( addrspec type -- fd )
    [ dup protocol-family ] dip socket-fd
    dup init-server-socket
    dup handle-fd rot make-sockaddr/size bind io-error ;

M: object (server) ( addrspec -- handle )
    [
        SOCK_STREAM server-socket-fd
        dup handle-fd 128 listen io-error
    ] with-destructors ;

: do-accept ( server addrspec -- fd sockaddr )
    [ handle>> handle-fd ] [ empty-sockaddr/size <int> ] bi*
    [ accept ] 2keep drop ; inline

M: object (accept) ( server addrspec -- fd sockaddr )
    2dup do-accept
    {
        { [ over 0 >= ] [ [ 2nip <fd> init-fd ] dip ] }
        { [ errno EINTR = ] [ 2drop (accept) ] }
        { [ errno EAGAIN = ] [
            2drop
            [ drop +input+ wait-for-port ]
            [ (accept) ]
            2bi
        ] }
        [ (io-error) ]
    } cond ;

! Datagram sockets - UDP and Unix domain
M: unix (datagram)
    [ SOCK_DGRAM server-socket-fd ] with-destructors ;

SYMBOL: receive-buffer

CONSTANT: packet-size 65536

[ packet-size malloc receive-buffer set-global ] "io.sockets.unix" add-init-hook

:: do-receive ( port -- packet sockaddr )
    port addr>> empty-sockaddr/size [| sockaddr len |
        port handle>> handle-fd ! s
        receive-buffer get-global ! buf
        packet-size ! nbytes
        0 ! flags
        sockaddr ! from
        len <int> ! fromlen
        recvfrom dup 0 >= [
            receive-buffer get-global swap memory>byte-array sockaddr
        ] [
            drop f f
        ] if
    ] call ;

M: unix (receive) ( datagram -- packet sockaddr )
    dup do-receive dup [ [ drop ] 2dip ] [
        2drop [ +input+ wait-for-port ] [ (receive) ] bi
    ] if ;

:: do-send ( packet sockaddr len socket datagram -- )
    socket handle-fd packet dup length 0 sockaddr len sendto
    0 < [
        errno EINTR = [
            packet sockaddr len socket datagram do-send
        ] [
            errno EAGAIN = [
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

M: local sockaddr-size drop "sockaddr-un" heap-size ;

M: local empty-sockaddr drop "sockaddr-un" <c-object> ;

M: local make-sockaddr
    path>> (normalize-path)
    dup length 1 + max-un-path > [ "Path too long" throw ] when
    "sockaddr-un" <c-object>
    AF_UNIX over set-sockaddr-un-family
    dup sockaddr-un-path rot utf8 string>alien dup length memcpy ;

M: local parse-sockaddr
    drop
    sockaddr-un-path utf8 alien>string <local> ;
