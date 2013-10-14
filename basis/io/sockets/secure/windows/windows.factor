USING:
    accessors
    alien alien.c-types alien.data
    combinators
    fry
    io io.sockets.private io.sockets.secure io.sockets.secure.openssl io.sockets.windows
    io.timeouts
    kernel
    openssl openssl.libcrypto openssl.libssl
    windows.winsock ;
IN: io.sockets.secure.windows

! Most of this vocab is duplicated code from io.sockets.secure.unix so
! you could probably unify them.
M: openssl ssl-supported? t ;
M: openssl ssl-certificate-verification-supported? f ;

: <ssl-socket> ( winsock -- ssl )
    [ handle>> alien-address BIO_NOCLOSE BIO_new_socket ] keep <ssl-handle>
    [ handle>> swap dup SSL_set_bio ] keep ;

M: secure ((client)) ( addrspec -- handle )
    addrspec>> ((client)) <ssl-socket> ;

M: secure (get-local-address) ( handle remote -- sockaddr )
    [ file>> handle>> ] [ addrspec>> empty-sockaddr/size int <ref> ] bi*
    [ getsockname socket-error ] 2keep drop ;

: establish-ssl-connection ( client-out remote -- )
    make-sockaddr/size <ConnectEx-args>
    swap >>port
    dup port>> handle>> file>> handle>> >>s dup
    s>> get-ConnectEx-ptr >>ptr dup
    call-ConnectEx wait-for-socket drop ;

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
    addrspec>> [ establish-ssl-connection ] [ secure-connection ] 2bi ;
