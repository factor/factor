! Copyright (C) 2007, 2008, Slava Pestov, Elie CHAFTARI.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays kernel debugger sequences namespaces math
math.order combinators init alien alien.c-types alien.strings libc
continuations destructors
openssl openssl.libcrypto openssl.libssl
io.files io.ports io.unix.backend io.unix.sockets
io.encodings.ascii io.buffers io.sockets io.sockets.secure
unix system ;
IN: io.unix.sockets.secure

! todo: SSL_pending, rehandshake
! check-certificate at some point
! test on windows

M: ssl-handle handle-fd file>> handle-fd ;

: syscall-error ( r -- * )
    ERR_get_error dup zero? [
        drop
        {
            { -1 [ (io-error) ] }
            { 0 [ "Premature EOF" throw ] }
        } case
    ] [
        nip (ssl-error)
    ] if ;

: check-response ( port r -- port r n )
    over handle>> handle>> over SSL_get_error ; inline

! Input ports
: check-read-response ( port r -- event )
    check-response
    {
        { SSL_ERROR_NONE [ swap buffer>> n>buffer f ] }
        { SSL_ERROR_ZERO_RETURN [ drop eof f ] }
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

M: ssl ((client)) ( addrspec -- handle )
    addrspec>> ((client)) <ssl-socket> ;

M: ssl parse-sockaddr addrspec>> parse-sockaddr <ssl> ;

: check-connect-response ( port r -- event )
    check-response
    {
        { SSL_ERROR_NONE [ 2drop f ] }
        { SSL_ERROR_WANT_READ [ 2drop +input+ ] }
        { SSL_ERROR_WANT_WRITE [ 2drop +output+ ] }
        { SSL_ERROR_SYSCALL [ syscall-error ] }
        { SSL_ERROR_SSL [ (ssl-error) ] }
    } case ;

: do-ssl-connect ( port ssl-handle -- )
    2dup SSL_connect check-connect-response dup
    [ >r over r> wait-for-port do-ssl-connect ] [ 3drop ] if ;

M: ssl-handle (wait-to-connect)
    addrspec>>
    [ >r file>> r> (wait-to-connect) ]
    [ drop handle>> do-ssl-connect ]
    [ drop t >>connected 2drop ]
    3tri ;

M: ssl (server) addrspec>> (server) ;

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
    [ >r dup file>> r> wait-for-fd do-ssl-accept ] [ 2drop ] if ;

M: ssl (accept)
    [
        addrspec>>
        (accept) >r
        |close-handle
        <ssl-socket> |close-handle
        dup do-ssl-accept
        r>
    ] with-destructors ;

: check-shutdown-response ( handle r -- event )
    >r handle>> r> SSL_get_error
    {
        { SSL_ERROR_WANT_READ [ +input+ ] }
        { SSL_ERROR_WANT_WRITE [ +output+ ] }
        { SSL_ERROR_SYSCALL [ -1 syscall-error ] }
        { SSL_ERROR_SSL [ (ssl-error) ] }
    } case ;

M: unix ssl-shutdown
    dup connected>> [
        dup dup handle>> SSL_shutdown check-shutdown-response
        dup [ dupd wait-for-fd ssl-shutdown ] [ 2drop ] if
    ] [ drop ] if ;
