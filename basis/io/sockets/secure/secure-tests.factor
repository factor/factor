IN: io.sockets.secure.tests
USING: accessors kernel io.sockets io.sockets.secure system tools.test ;

[ "hello" 24 ] [ "hello" 24 <inet> <secure> [ host>> ] [ port>> ] bi ] unit-test

[ ] [
    <secure-config>
        "vocab:openssl/test/server.pem" >>key-file
        "vocab:openssl/test/dh1024.pem" >>dh-file
        "password" >>password
    [ ] with-secure-context
] unit-test

[ t ] [ os windows? ssl-certificate-verification-supported? or ] unit-test
