! Copyright (C) 2007, 2008, Slava Pestov, Elie CHAFTARI.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays kernel debugger sequences namespaces math
math.order combinators init alien alien.c-types alien.strings libc
continuations destructors
openssl openssl.libcrypto openssl.libssl
io.files io.ports io.unix.backend io.unix.sockets
io.encodings.ascii io.buffers io.sockets io.sockets.secure
unix system inspector ;
IN: io.unix.sockets.secure

M: ssl-handle handle-fd file>> handle-fd ;

: syscall-error ( r -- * )
    ERR_get_error dup zero? [
        drop
        {
            { -1 [ (io-error) ] }
            { 0 [ premature-close ] }
        } case
    ] [
        nip (ssl-error)
    ] if ;

: check-response ( port r -- port r n )
    over handle>> handle>> over SSL_get_error ; inline

! Input ports
: check-read-response ( port r -- event ) USING: namespaces io prettyprint ;
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
    handle>> ! ssl
    over buffer>>
    [ buffer@ ] ! buf
    [ buffer-length ] bi ! len
    SSL_write
    check-write-response ;

! Client sockets
: <ssl-socket> ( fd -- ssl )
    [ fd>> BIO_NOCLOSE BIO_new_socket dup ssl-error ] keep <ssl-handle>
    [ handle>> swap dup SSL_set_bio ] keep ;

M: secure ((client)) ( addrspec -- handle )
    addrspec>> ((client)) <ssl-socket> ;

M: secure parse-sockaddr addrspec>> parse-sockaddr <secure> ;

M: secure (get-local-address) addrspec>> (get-local-address) ;

: check-connect-response ( port r -- event )
    check-response
    {
        { SSL_ERROR_NONE [ 2drop f ] }
        { SSL_ERROR_WANT_READ [ 2drop +input+ ] }
        { SSL_ERROR_WANT_WRITE [ 2drop +output+ ] }
        { SSL_ERROR_SYSCALL [ syscall-error ] }
        { SSL_ERROR_SSL [ (ssl-error) ] }
    } case ;

: do-ssl-connect ( port -- )
    dup dup handle>> handle>> SSL_connect
    check-connect-response dup
    [ dupd wait-for-port do-ssl-connect ] [ 2drop ] if ;

M: secure establish-connection ( client-out remote -- )
    [ addrspec>> establish-connection ]
    [ drop do-ssl-connect ]
    [ drop handle>> t >>connected drop ]
    2tri ;

M: secure (server) addrspec>> (server) ;

: check-accept-response ( handle r -- event )
    over handle>> over SSL_get_error
    {
        { SSL_ERROR_NONE [ 2drop f ] }
        { SSL_ERROR_WANT_READ [ 2drop +input+ ] }
        { SSL_ERROR_WANT_WRITE [ 2drop +output+ ] }
        { SSL_ERROR_SYSCALL [ syscall-error ] }
        { SSL_ERROR_SSL [ (ssl-error) ] }
    } case ;

: do-ssl-accept ( ssl-handle -- )
    dup dup handle>> SSL_accept check-accept-response dup
    [ >r dup file>> r> wait-for-fd drop do-ssl-accept ] [ 2drop ] if ;

M: secure (accept)
    [
        addrspec>> (accept) >r
        |dispose <ssl-socket> t >>connected |dispose
        dup do-ssl-accept r>
    ] with-destructors ;

: check-shutdown-response ( handle r -- event )
    #! SSL_shutdown always returns 0 due to openssl bugs?
    {
        { 1 [ drop f ] }
        { 0 [
                dup handle>> SSL_want
                {
                    { SSL_NOTHING [ dup handle>> SSL_shutdown check-shutdown-response ] }
                    { SSL_READING [ drop +input+ ] }
                    { SSL_WRITING [ drop +output+ ] }
                } case
        ] }
        { -1 [
            handle>> -1 SSL_get_error
            {
                { SSL_ERROR_WANT_READ [ +input+ ] }
                { SSL_ERROR_WANT_WRITE [ +output+ ] }
                { SSL_ERROR_SYSCALL [ -1 syscall-error ] }
                { SSL_ERROR_SSL [ (ssl-error) ] }
            } case
        ] }
    } case ;

M: unix ssl-shutdown
    dup connected>> [
        dup dup handle>> SSL_shutdown check-shutdown-response
        dup [ dupd wait-for-fd drop ssl-shutdown ] [ 2drop ] if
    ] [ drop ] if ;
