IN: io.sockets.secure.tests
USING: accessors kernel namespaces io io.sockets
io.sockets.secure io.encodings.ascii io.streams.duplex
classes words destructors threads tools.test
concurrency.promises byte-arrays ;

\ <secure-config> must-infer
{ 1 0 } [ [ ] with-secure-context ] must-infer-as

[ ] [ <promise> "port" set ] unit-test

[ ] [
    [
        <secure-config>
            "resource:extra/openssl/test/server.pem" >>key-file
            "resource:extra/openssl/test/root.pem" >>ca-file
            "resource:extra/openssl/test/dh1024.pem" >>dh-file
            "password" >byte-array >>password
        [
            "127.0.0.1" 0 <inet4> <secure> ascii <server> [
                dup addr>> addrspec>> port>> "port" get fulfill
                accept [
                    class word-name write
                ] curry with-stream
            ] with-disposal
        ] with-secure-context
    ] "SSL server test" spawn drop
] unit-test

[ "secure" ] [
    <secure-config> [
        "127.0.0.1" "port" get ?promise <inet4> <secure> ascii <client> drop contents
    ] with-secure-context
] unit-test

! Now, see what happens if the server closes the connection prematurely
[ ] [ <promise> "port" set ] unit-test

[ ] [
    [
        <secure-config>
            "resource:extra/openssl/test/server.pem" >>key-file
            "resource:extra/openssl/test/root.pem" >>ca-file
            "resource:extra/openssl/test/dh1024.pem" >>dh-file
            "password" >byte-array >>password
        [
            "127.0.0.1" 0 <inet4> <secure> ascii <server> [
                dup addr>> addrspec>> port>> "port" get fulfill
                accept drop
                [
                    dup in>> stream>> handle>> f >>connected drop
                    "hello" over stream-write dup stream-flush
                ] with-disposal
            ] with-disposal
        ] with-secure-context
    ] "SSL server test" spawn drop
] unit-test

[
    <secure-config> [
        "127.0.0.1" "port" get ?promise <inet4> <secure> ascii <client> drop contents
    ] with-secure-context
] [ premature-close = ] must-fail-with

! Now, try validating the certificate. This should fail because its
! actually an invalid certificate
[ ] [ <promise> "port" set ] unit-test

[ ] [
    [
        <secure-config>
            "resource:extra/openssl/test/server.pem" >>key-file
            "resource:extra/openssl/test/root.pem" >>ca-file
            "resource:extra/openssl/test/dh1024.pem" >>dh-file
            "password" >byte-array >>password
        [
            "127.0.0.1" 0 <inet4> <secure> ascii <server> [
                dup addr>> addrspec>> port>> "port" get fulfill
                accept drop dispose
            ] with-disposal
        ] with-secure-context
    ] "SSL server test" spawn drop
] unit-test

[
    <secure-config> [
        "localhost" "port" get ?promise <inet> <secure> ascii
        <client> drop dispose
    ] with-secure-context
] [ certificate-verify-error? ] must-fail-with
