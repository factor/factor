USING:
    accessors
    alien alien.c-types alien.data
    combinators
    fry
    io.buffers
    io.files
    io.ports
    io.sockets.private io.sockets.secure io.sockets.secure.openssl
    io.timeouts
    kernel
    namespaces
    openssl openssl.libcrypto openssl.libssl ;
IN: io.sockets.secure.windows

! Most of this vocab is duplicated code from io.sockets.secure.unix so
! you could probably unify them.
M: openssl ssl-supported? t ;
M: openssl ssl-certificate-verification-supported? f ;

: check-response ( port r -- port r n )
    over handle>> handle>> over SSL_get_error ; inline

: check-read-response ( port r -- event )
    check-response
    {
        { SSL_ERROR_NONE [ swap buffer>> n>buffer f ] }
        { SSL_ERROR_ZERO_RETURN [ 2drop f ] }
        { SSL_ERROR_WANT_READ [ 2drop "input" ] }
        { SSL_ERROR_WANT_WRITE [ 2drop "output" ] }
        { SSL_ERROR_SYSCALL [ syscall-error ] }
        { SSL_ERROR_SSL [ (ssl-error) ] }
    } case ;

: maybe-handshake ( ssl-handle -- )
    dup connected>> [ drop ] [
        t >>connected
        [ do-ssl-accept ] with-timeout
    ] if ;

M: ssl-handle refill
    dup maybe-handshake
    handle>> ! ssl
    over buffer>>
    [ buffer-end ] ! buf
    [ buffer-capacity ] bi ! len
    SSL_read
    check-read-response ;

: check-write-response ( port r -- event )
    check-response
    {
        { SSL_ERROR_NONE [ swap buffer>> buffer-consume f ] }
        { SSL_ERROR_WANT_READ [ 2drop "input!" ] }
        { SSL_ERROR_WANT_WRITE [ 2drop "output!" ] }
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

M: ssl-handle timeout
    drop secure-socket-timeout get ;

: <ssl-socket> ( winsock -- ssl )
    [ handle>> alien-address BIO_NOCLOSE BIO_new_socket ] keep <ssl-handle>
    [ handle>> swap dup SSL_set_bio ] keep ;

M: secure ((client)) ( addrspec -- handle )
    addrspec>> ((client)) <ssl-socket> ;

M: secure (get-local-address) ( handle remote -- sockaddr )
    [ file>> ] [ addrspec>> ] bi* (get-local-address) ;

M: secure parse-sockaddr addrspec>> parse-sockaddr <secure> ;

! The error codes needs to be handled properly.
: check-connect-response ( ssl-handle r -- event )
    over handle>> over SSL_get_error
    {
        { SSL_ERROR_NONE [ 2drop f ] }
        {
            SSL_ERROR_WANT_READ
            [ 2drop "input route" ]
        }
        {
            SSL_ERROR_WANT_WRITE
            [ 2drop "output route" ]
        }
        {
            SSL_ERROR_SYSCALL
            [ 2drop "syscall error" ]
        }
        { SSL_ERROR_SSL [ (ssl-error) ] }
    } case ;

: do-ssl-connect ( ssl-handle -- )
    dup dup handle>> SSL_connect check-connect-response dup
    [ dupd 2drop do-ssl-connect ] [ 2drop ] if ;

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
    [
        [ handle>> file>> <output-port> ] [ addrspec>> ] bi* establish-connection
    ]
    [ secure-connection ] 2bi ;
