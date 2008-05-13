! Copyright (C) 2007, 2008, Slava Pestov, Elie CHAFTARI.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays kernel debugger sequences namespaces math
math.order combinators init alien alien.c-types alien.strings libc
continuations destructors
openssl openssl.libcrypto openssl.libssl
io.files io.nonblocking io.unix.backend io.unix.sockets
io.encodings.ascii io.buffers io.sockets io.sockets.secure
unix.ffi ;
IN: io.unix.sockets.secure

! todo: SSL_pending, rehandshake
! do we call write twice, wth 0 bytes at the end?

M: ssl-handle handle-fd file>> ;

: syscall-error ( port r -- )
    ERR_get_error dup zero? [
        drop
        {
            { -1 [ err_no strerror ] }
            { 0 [ "Premature EOF" ] }
        } case
    ] [
        nip (ssl-error-string)
    ] if swap report-error ;

: check-response ( port r -- port r n )
    over handle>> handle>> over SSL_get_error ; inline

! Input ports
: report-ssl-error ( port r -- )
    drop ssl-error-string swap report-error ;

: check-read-response ( port r -- ? )
    check-response
    {
        { SSL_ERROR_NONE [ swap buffer>> n>buffer t ] }
        { SSL_ERROR_ZERO_RETURN [ drop reader-eof t ] }
        { SSL_ERROR_WANT_READ [ 2drop f ] }
        { SSL_ERROR_WANT_WRITE [ 2drop f ] } ! XXX
        { SSL_ERROR_SYSCALL [ syscall-error t ] }
        { SSL_ERROR_SSL [ report-ssl-error t ] }
    } case ;

M: ssl-handle refill
    drop
    dup buffer>> buffer-empty? [
        dup
        [ handle>> handle>> ] ! ssl
        [ buffer>> buffer-end ] ! buf
        [ buffer>> buffer-capacity ] tri ! len
        SSL_read
        check-read-response
    ] [ drop t ] if ;

! Output ports
: check-write-response ( port r -- ? )
    check-response
    {
        { SSL_ERROR_NONE [ swap buffer>> buffer-consume f ] }
        ! { SSL_ERROR_ZERO_RETURN [ drop reader-eof ] } ! XXX
        { SSL_ERROR_WANT_READ [ 2drop f ] } ! XXX
        { SSL_ERROR_WANT_WRITE [ 2drop f ] }
        { SSL_ERROR_SYSCALL [ syscall-error t ] }
        { SSL_ERROR_SSL [ report-ssl-error t ] }
    } case ;

M: ssl-handle drain
    drop
    dup
    [ handle>> handle>> ] ! ssl
    [ buffer>> buffer@ ] ! buf
    [ buffer>> buffer-length ] tri ! len
    SSL_write
    check-write-response ;

! Client sockets
M: ssl ((client)) ( addrspec -- handle )
    [ addrspec>> ((client)) <ssl-socket> ] with-destructors ;

: check-connect-response ( port r -- ? )
    check-response
    {
        { SSL_ERROR_NONE [ 2drop t ] }
        { SSL_ERROR_WANT_READ [ 2drop f ] } ! XXX
        { SSL_ERROR_WANT_WRITE [ 2drop f ] } ! XXX
        { SSL_ERROR_SYSCALL [ syscall-error t ] }
        { SSL_ERROR_SSL [ report-ssl-error t ] }
    } case ;

M: ssl-handle (wait-to-connect)
    handle>> ! ssl
    SSL_connect
    check-connect-response ;
