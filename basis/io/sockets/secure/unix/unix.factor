! Copyright (C) 2007, 2011, Slava Pestov, Elie CHAFTARI.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators destructors io.backend.unix
io.files io.sockets.private io.sockets.secure
io.sockets.secure.openssl io.timeouts kernel math openssl
openssl.libssl system ;
FROM: io.ports => shutdown ;
IN: io.sockets.secure.unix

M: openssl ssl-supported? t ;
M: openssl ssl-certificate-verification-supported? t ;

M: ssl-handle handle-fd file>> handle-fd ;

M: unix socket-handle fd>> ;

M: secure remote>handle ( secure -- handle )
    [ addrspec>> remote>handle ] [ hostname>> ] bi <ssl-socket> ;

M: secure parse-sockaddr addrspec>> parse-sockaddr f <secure> ;

M: secure (get-local-address) addrspec>> (get-local-address) ;

M: secure establish-connection ( client-out remote -- )
    addrspec>> [ establish-connection ] [ secure-connection ] 2bi ;

M: secure (accept)
    [
        addrspec>> (accept) [ |dispose f <ssl-socket> ] dip
    ] with-destructors ;

: check-shutdown-response ( handle r -- event )
    ! We don't do two-step shutdown here because I couldn't
    ! figure out how to do it with non-blocking BIOs. Also, it
    ! seems that SSL_shutdown always returns 0 -- this sounds
    ! like a bug
    over handle>> over SSL_get_error
    {
        { SSL_ERROR_NONE [ 2drop f ] }
        { SSL_ERROR_WANT_READ [ 2drop +input+ ] }
        { SSL_ERROR_WANT_WRITE [ 2drop +output+ ] }
        { SSL_ERROR_SYSCALL [ [ drop f ] [ nip syscall-error ] if-zero ] }
        { SSL_ERROR_SSL [ (ssl-error) ] }
    } case ;

: (shutdown) ( handle -- )
    dup dup handle>> SSL_shutdown check-shutdown-response
    [ dupd wait-for-fd (shutdown) ] [ drop ] if* ;

M: ssl-handle shutdown
    dup connected>> [
        f >>connected [ (shutdown) ] with-timeout
    ] [ drop ] if ;

M: unix non-ssl-socket? ( obj -- ? ) fd? ;
