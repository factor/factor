USING: accessors alien alien.data classes.struct io.files io.ports io.sockets io.sockets.private io.sockets.unix kernel locals math system unix.ffi ;
IN: io.sockets.unix.haiku
M: haiku init-sockaddr dup byte-length >>len ;

! Stock Haiku AF_UNIX can return zero before a reply has arrived, leaving
! its output sockaddr untouched (AF_UNSPEC). This is not a received packet.
! A real zero-length packet with a populated sender, including an anonymous
! AF_UNIX sender, remains a successful receive.
:: haiku-receive ( n buf datagram -- count address )
    n buf datagram (receive-loop) :> ( count address )
    n 0 > datagram addr>> local? and
    count zero? address family>> AF_UNSPEC = and and [
        datagram +input+ wait-for-port
        n buf datagram haiku-receive
    ] [ count address ] if ;

M: haiku (receive-unsafe) haiku-receive ;
