IN: io.sockets.secure.tests
USING: accessors kernel namespaces io io.sockets
io.sockets.secure io.encodings.ascii io.streams.duplex
classes words destructors threads tools.test
concurrency.promises byte-arrays locals ;

\ <secure-config> must-infer
{ 1 0 } [ [ ] with-secure-context ] must-infer-as

[ ] [ <promise> "port" set ] unit-test

: with-test-context
    <secure-config>
        "resource:extra/openssl/test/server.pem" >>key-file
        "resource:extra/openssl/test/root.pem" >>ca-file
        "resource:extra/openssl/test/dh1024.pem" >>dh-file
        "password" >>password
    swap with-secure-context ;

:: server-test ( quot -- )
    [
        [
            "127.0.0.1" 0 <inet4> <secure> ascii <server> [
                dup addr>> addrspec>> port>> "port" get fulfill
                accept [
                    quot call
                ] curry with-stream
            ] with-disposal
        ] with-test-context
    ] "SSL server test" spawn drop ;

: client-test
    <secure-config> [
        "127.0.0.1" "port" get ?promise <inet4> <secure> ascii <client> drop contents
    ] with-secure-context ;

[ ] [ [ class word-name write ] server-test ] unit-test

[ "secure" ] [ client-test ] unit-test

! Now, see what happens if the server closes the connection prematurely
[ ] [ <promise> "port" set ] unit-test

[ ] [
    [
        drop
        input-stream get stream>> handle>> f >>connected drop
        "hello" write flush
    ] server-test
] unit-test

[ client-test ] [ premature-close? ] must-fail-with

! Now, try validating the certificate. This should fail because its
! actually an invalid certificate
[ ] [ <promise> "port" set ] unit-test

[ ] [ [ drop ] server-test ] unit-test

[
    <secure-config> [
        "localhost" "port" get ?promise <inet> <secure> ascii
        <client> drop dispose
    ] with-secure-context
] [ certificate-verify-error? ] must-fail-with
