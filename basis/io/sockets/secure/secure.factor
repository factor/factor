! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces continuations destructors io
debugger io.sockets io.sockets.private sequences summary
calendar delegate system vocabs.loader combinators present ;
IN: io.sockets.secure

SYMBOL: secure-socket-timeout

1 minutes secure-socket-timeout set-global

SYMBOL: secure-socket-backend

SINGLETONS: SSLv2 SSLv23 SSLv3 TLSv1 ;

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
        SSLv23 >>method
        1024 >>ephemeral-key-bits
        "vocab:openssl/cacert.pem" >>ca-file
        t >>verify ;

TUPLE: secure-context < disposable config handle ;

HOOK: <secure-context> secure-socket-backend ( config -- context )

: with-secure-context ( config quot -- )
    [
        [ <secure-context> ] [ [ secure-context set ] prepose ] bi*
        with-disposal
    ] with-scope ; inline

TUPLE: secure addrspec ;

C: <secure> secure

M: secure present addrspec>> present " (secure)" append ;

CONSULT: inet secure addrspec>> ;

M: secure resolve-host ( secure -- seq )
    addrspec>> resolve-host [ <secure> ] map ;

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

ERROR: common-name-verify-error expected got ;

M: common-name-verify-error summary
    drop "Common name verification failed" ;

ERROR: upgrade-on-non-socket ;

M: upgrade-on-non-socket summary
    drop
    "send-secure-handshake can only be used if input-stream and" print
    "output-stream are a socket" ;

ERROR: upgrade-buffers-full ;

M: upgrade-buffers-full summary
    drop
    "send-secure-handshake can only be used if buffers are empty" ;

HOOK: send-secure-handshake secure-socket-backend ( -- )

HOOK: accept-secure-handshake secure-socket-backend ( -- )

{
    { [ os unix? ] [ "io.sockets.secure.unix" require ] }
    { [ os windows? ] [ "openssl" require ] }
} cond
