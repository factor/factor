! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.libraries calendar combinators delegate
destructors io io.sockets io.sockets.private kernel memoize namespaces
openssl.libssl present sequences summary system vocabs ;
IN: io.sockets.secure

SYMBOL: secure-socket-timeout

1 minutes secure-socket-timeout set-global

SYMBOL: secure-socket-backend

HOOK: ssl-supported? secure-socket-backend ( -- ? )
HOOK: ssl-certificate-verification-supported? secure-socket-backend ( -- ? )

M: object ssl-supported? f ;
M: object ssl-certificate-verification-supported? f ;

SINGLETONS: TLSv1 TLSv1.1 TLSv1.2 ;

ERROR: no-tls-supported ;

MEMO: best-tls-method ( -- class )
    {
        { [ "TLSv1_2_method" "libssl" dlsym? ] [ TLSv1.2 ] }
        { [ "TLSv1_1_method" "libssl" dlsym? ] [ TLSv1.1 ] }
        { [ "TLSv1_method" "libssl" dlsym? ] [ TLSv1 ] }
        [ no-tls-supported ]
    } cond ;

TUPLE: secure-config
method
key-file password
verify
verify-depth
ca-file ca-path
dh-file
ephemeral-key-bits ;

: <secure-config> ( -- config )
    secure-config new
        best-tls-method >>method
        1024 >>ephemeral-key-bits
        ssl-certificate-verification-supported? >>verify ;

TUPLE: secure-context < disposable config handle ;

HOOK: <secure-context> secure-socket-backend ( config -- context )

: with-secure-context ( config quot -- )
    [
        [ <secure-context> ] [ [ secure-context set ] prepose ] bi*
        with-disposal
    ] with-scope ; inline

TUPLE: secure
    { addrspec read-only }
    { hostname read-only } ;

C: <secure> secure

M: secure present addrspec>> present " (secure)" append ;

M: secure (server) addrspec>> (server) ;

CONSULT: inet secure addrspec>> ;

M: secure resolve-host ( secure -- seq )
    [ addrspec>> resolve-host ] [ hostname>> ] bi
    [ <secure> ] curry map ;

HOOK: check-certificate secure-socket-backend ( host handle -- )

PREDICATE: secure-inet < secure addrspec>> inet? ;

<PRIVATE

M: secure-inet (client)
    [
        [ resolve-host (client) [ |dispose ] dip ] keep
        addrspec>> host>> pick handle>> check-certificate
    ] with-destructors ;

PRIVATE>

ERROR: premature-close ;

M: premature-close summary
    drop "Connection closed prematurely - potential truncation attack" ;

ERROR: certificate-verify-error result ;

M: certificate-verify-error summary
    drop "Certificate verification failed" ;

ERROR: subject-name-verify-error expected got ;

M: subject-name-verify-error summary
    drop "Subject name verification failed" ;

ERROR: certificate-missing-error ;

M: certificate-missing-error summary
    drop "Host did not present any certificate" ;

ERROR: upgrade-on-non-socket ;

M: upgrade-on-non-socket summary
    drop
    "send-secure-handshake can only be used if input-stream and" print
    "output-stream are a socket" ;

ERROR: upgrade-buffers-full ;

M: upgrade-buffers-full summary
    drop
    "send-secure-handshake can only be used if buffers are empty" ;

HOOK: non-ssl-socket? os ( obj -- ? )

HOOK: socket-handle os ( obj -- ? )

HOOK: send-secure-handshake secure-socket-backend ( -- )

HOOK: accept-secure-handshake secure-socket-backend ( -- )

{
    { [ os unix? ] [ "io.sockets.secure.unix" require ] }
    { [ os windows? ] [ "io.sockets.secure.windows" require ] }
} cond
