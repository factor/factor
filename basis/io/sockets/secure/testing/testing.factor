! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors http.server http.server.responses io.servers
io.sockets io.sockets.secure kernel locals math.parser namespaces sequences ;
IN: io.sockets.secure.testing

! Public test credentials for loopback servers, with an explicit client trust
! anchor. Keep certificate and hostname verification enabled.
: <local-test-server-config> ( -- config )
    <secure-config>
        "vocab:io/sockets/secure/testing/server.pem" >>key-file ;

: <local-test-client-config> ( -- config )
    <secure-config>
        "vocab:io/sockets/secure/testing/cert.pem" >>ca-file ;

:: with-local-https-server ( body quot: ( url -- result ) -- result )
    body <text-content> <trivial-responder> main-responder [
        <http-server>
            f >>insecure
            "127.0.0.1" 0 <inet4> >>secure
            <local-test-server-config> >>secure-config [
                <local-test-client-config> [
                    "https://127.0.0.1:" secure-addr port>> number>string
                    append "/" append quot call
                ] with-secure-context
            ] with-threaded-server
    ] with-variable ; inline
