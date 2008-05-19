USING: io.sockets.secure io.encodings.ascii alien.strings
openssl namespaces accessors tools.test continuations kernel ;

openssl secure-socket-backend [
    [ ] [
        <secure-config>
            "resource:extra/openssl/test/server.pem" >>key-file
            "resource:extra/openssl/test/root.pem" >>ca-file
            "resource:extra/openssl/test/dh1024.pem" >>dh-file
            "password" ascii string>alien >>password
        [ ] with-secure-context
    ] unit-test

    [
        <secure-config>
            "resource:extra/openssl/test/server.pem" >>key-file
            "resource:extra/openssl/test/root.pem" >>ca-file
            "wrong password" ascii string>alien >>password
        [ ] with-secure-context
    ] must-fail
] with-variable
