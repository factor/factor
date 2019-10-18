USING: io.sockets.secure io.encodings.ascii alien.strings
openssl namespaces accessors tools.test continuations kernel ;

openssl secure-socket-backend [
    [ ] [
        <secure-config>
            "vocab:openssl/test/server.pem" >>key-file
            "vocab:openssl/test/root.pem" >>ca-file
            "vocab:openssl/test/dh1024.pem" >>dh-file
            "password" >>password
        [ ] with-secure-context
    ] unit-test

    [
        <secure-config>
            "vocab:openssl/test/server.pem" >>key-file
            "vocab:openssl/test/root.pem" >>ca-file
            "wrong password" >>password
        [ ] with-secure-context
    ] must-fail
] with-variable
