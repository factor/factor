! Copyright (C) 2007, 2011, Slava Pestov, Elie CHAFTARI.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors unix byte-arrays kernel sequences namespaces
math math.order combinators init alien alien.c-types
alien.strings libc continuations destructors openssl
openssl.libcrypto openssl.libssl io io.files io.ports
io.backend.unix io.sockets.unix io.encodings.ascii io.buffers
io.sockets io.sockets.private io.sockets.secure
io.sockets.secure.openssl io.timeouts system summary fry
unix.ffi ;
FROM: io.ports => shutdown ;
IN: io.sockets.secure.unix

M: openssl ssl-supported? t ;
M: openssl ssl-certificate-verification-supported? t ;

M: ssl-handle handle-fd file>> handle-fd ;

! Client sockets
: <ssl-socket> ( fd -- ssl )
    [ fd>> BIO_NOCLOSE BIO_new_socket dup ssl-error ] keep <ssl-handle>
    [ handle>> swap dup SSL_set_bio ] keep ;

M: secure ((client)) ( addrspec -- handle )
    addrspec>> ((client)) <ssl-socket> ;

M: secure parse-sockaddr addrspec>> parse-sockaddr <secure> ;

M: secure (get-local-address) addrspec>> (get-local-address) ;

M: secure establish-connection ( client-out remote -- )
    addrspec>> [ establish-connection ] [ secure-connection ] 2bi ;

M: secure (server) addrspec>> (server) ;

M: secure (accept)
    [
        addrspec>> (accept) [ |dispose <ssl-socket> ] dip
    ] with-destructors ;

: check-shutdown-response ( handle r -- event )
    #! We don't do two-step shutdown here because I couldn't
    #! figure out how to do it with non-blocking BIOs. Also, it
    #! seems that SSL_shutdown always returns 0 -- this sounds
    #! like a bug
    over handle>> over SSL_get_error
    {
        { SSL_ERROR_NONE [ 2drop f ] }
        { SSL_ERROR_WANT_READ [ 2drop +input+ ] }
        { SSL_ERROR_WANT_WRITE [ 2drop +output+ ] }
        { SSL_ERROR_SYSCALL [ [ drop f ] [ syscall-error ] if-zero ] }
        { SSL_ERROR_SSL [ (ssl-error) ] }
    } case ;

: (shutdown) ( handle -- )
    dup dup handle>> SSL_shutdown check-shutdown-response
    dup [ dupd wait-for-fd (shutdown) ] [ 2drop ] if ;

M: ssl-handle shutdown
    dup connected>> [
        f >>connected [ (shutdown) ] with-timeout
    ] [ drop ] if ;

: check-buffer ( port -- port )
    dup buffer>> buffer-empty? [ upgrade-buffers-full ] unless ;

: input/output-ports ( -- input output )
    input-stream output-stream
    [ get underlying-port check-buffer ] bi@
    2dup [ handle>> ] bi@ eq? [ upgrade-on-non-socket ] unless ;

: make-input/output-secure ( input output -- )
    dup handle>> fd? [ upgrade-on-non-socket ] unless
    [ <ssl-socket> ] change-handle
    handle>> >>handle drop ;

: (send-secure-handshake) ( output -- )
    remote-address get [ upgrade-on-non-socket ] unless*
    secure-connection ;

M: openssl send-secure-handshake
    input/output-ports
    [ make-input/output-secure ] keep
    [ (send-secure-handshake) ] keep
    remote-address get dup inet? [
        host>> swap handle>> check-certificate
    ] [ 2drop ] if ;

M: openssl accept-secure-handshake
    input/output-ports
    make-input/output-secure ;
