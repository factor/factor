IN: io.sockets.secure.tests
USING: accessors kernel io.sockets io.sockets.secure tools.test ;

[ "hello" 24 ] [ "hello" 24 <inet> <secure> [ host>> ] [ port>> ] bi ] unit-test

[ ] [
    <secure-config>
        "resource:extra/openssl/test/server.pem" >>key-file
        "resource:extra/openssl/test/dh1024.pem" >>dh-file
        "password" >>password
    [ ] with-secure-context
] unit-test
