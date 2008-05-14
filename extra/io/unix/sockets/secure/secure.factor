! Copyright (C) 2007, 2008, Slava Pestov, Elie CHAFTARI.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays kernel debugger sequences namespaces math
math.order combinators init alien alien.c-types alien.strings libc
continuations destructors
openssl openssl.libcrypto openssl.libssl
io.files io.ports io.unix.backend io.unix.sockets
io.encodings.ascii io.buffers io.sockets io.sockets.secure
unix ;
IN: io.unix.sockets.secure

! todo: SSL_pending, rehandshake
! do we call write twice, wth 0 bytes at the end?
! check-certificate at some point
! test on windows

M: ssl-handle handle-fd file>> ;

: syscall-error ( port r -- * )
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
M: ssl ((client)) ( addrspec -- handle )
    [ addrspec>> ((client)) <ssl-socket> ] with-destructors ;

: check-connect-response ( port r -- event )
    check-response
    {
        { SSL_ERROR_NONE [ 2drop f ] }
        { SSL_ERROR_WANT_READ [ 2drop +input+ ] }
        { SSL_ERROR_WANT_WRITE [ 2drop +output+ ] }
        { SSL_ERROR_SYSCALL [ syscall-error ] }
        { SSL_ERROR_SSL [ (ssl-error) ] }
    } case ;

: do-ssl-connect ( port ssl -- )
    2dup SSL_connect check-connect-response dup
    [ nip wait-for-port ] [ 3drop ] if ;

M: ssl-handle (wait-to-connect)
    [ file>> (wait-to-connect) ]
    [ handle>> do-ssl-connect ] 2bi ;
