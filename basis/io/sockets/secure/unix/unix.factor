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

M: ssl-handle handle-fd file>> handle-fd ;

: syscall-error ( handle r -- event )
    nip
    ERR_get_error [
        {
            { -1 [ errno ECONNRESET = [ premature-close ] [ (io-error) ] if ] }
            ! OpenSSL docs say this it is an error condition for
            ! a server to not send a close notify, but web
            ! servers in the wild don't seem to do this, for
            ! example https://www.google.com.
            { 0 [ f ] }
        } case
    ] [ nip (ssl-error) ] if-zero ;

: check-accept-response ( handle r -- event )
    over handle>> over SSL_get_error
    {
        { SSL_ERROR_NONE [ 2drop f ] }
        { SSL_ERROR_WANT_READ [ 2drop +input+ ] }
        { SSL_ERROR_WANT_ACCEPT [ 2drop +input+ ] }
        { SSL_ERROR_WANT_WRITE [ 2drop +output+ ] }
        { SSL_ERROR_SYSCALL [ syscall-error ] }
        { SSL_ERROR_ZERO_RETURN [ (ssl-error) ] }
        { SSL_ERROR_SSL [ (ssl-error) ] }
    } case ;

: do-ssl-accept ( ssl-handle -- )
    dup dup handle>> SSL_accept check-accept-response dup
    [ [ dup file>> ] dip wait-for-fd do-ssl-accept ] [ 2drop ] if ;

: maybe-handshake ( ssl-handle -- )
    dup connected>> [ drop ] [
        t >>connected
        [ do-ssl-accept ] with-timeout
    ] if ;

: check-response ( port r -- port r n )
    over handle>> handle>> over SSL_get_error ; inline

! Input ports
: check-read-response ( port r -- event )
    check-response
    {
        { SSL_ERROR_NONE [ swap buffer>> n>buffer f ] }
        { SSL_ERROR_ZERO_RETURN [ 2drop f ] }
        { SSL_ERROR_WANT_READ [ 2drop +input+ ] }
        { SSL_ERROR_WANT_WRITE [ 2drop +output+ ] }
        { SSL_ERROR_SYSCALL [ syscall-error ] }
        { SSL_ERROR_SSL [ (ssl-error) ] }
    } case ;

M: ssl-handle refill
    dup maybe-handshake
    handle>> ! ssl
    over buffer>>
    [ buffer-end ] ! buf
    [ buffer-capacity ] bi ! len
    SSL_read
    check-read-response ;

! Output ports
: check-write-response ( port r -- event )
    check-response
    {
        { SSL_ERROR_NONE [ swap buffer>> buffer-consume f ] }
        { SSL_ERROR_WANT_READ [ 2drop +input+ ] }
        { SSL_ERROR_WANT_WRITE [ 2drop +output+ ] }
        { SSL_ERROR_SYSCALL [ syscall-error ] }
        { SSL_ERROR_SSL [ (ssl-error) ] }
    } case ;

M: ssl-handle drain
    dup maybe-handshake
    handle>> ! ssl
    over buffer>>
    [ buffer@ ] ! buf
    [ buffer-length ] bi ! len
    SSL_write
    check-write-response ;

M: ssl-handle cancel-operation
    file>> cancel-operation ;

M: ssl-handle timeout
    drop secure-socket-timeout get ;

! Client sockets
: <ssl-socket> ( fd -- ssl )
    [ fd>> BIO_NOCLOSE BIO_new_socket dup ssl-error ] keep <ssl-handle>
    [ handle>> swap dup SSL_set_bio ] keep ;

M: secure ((client)) ( addrspec -- handle )
    addrspec>> ((client)) <ssl-socket> ;

M: secure parse-sockaddr addrspec>> parse-sockaddr <secure> ;

M: secure (get-local-address) addrspec>> (get-local-address) ;

: check-connect-response ( ssl-handle r -- event )
    over handle>> over SSL_get_error
    {
        { SSL_ERROR_NONE [ 2drop f ] }
        { SSL_ERROR_WANT_READ [ 2drop +input+ ] }
        { SSL_ERROR_WANT_WRITE [ 2drop +output+ ] }
        { SSL_ERROR_SYSCALL [ syscall-error ] }
        { SSL_ERROR_SSL [ (ssl-error) ] }
    } case ;

: do-ssl-connect ( ssl-handle -- )
    dup dup handle>> SSL_connect check-connect-response dup
    [ dupd wait-for-fd do-ssl-connect ] [ 2drop ] if ;

: resume-session ( ssl-handle ssl-session -- )
    [ [ handle>> ] dip SSL_set_session ssl-error ]
    [ drop do-ssl-connect ]
    2bi ;

: begin-session ( ssl-handle addrspec -- )
    [ drop do-ssl-connect ]
    [ [ handle>> SSL_get1_session ] dip save-session ]
    2bi ;

: secure-connection ( client-out addrspec -- )
    [ handle>> ] dip
    [
        '[
            _ dup get-session
            [ resume-session ] [ begin-session ] ?if
        ] with-timeout
    ] [ drop t >>connected drop ] 2bi ;

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
